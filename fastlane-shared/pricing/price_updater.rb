require "spaceship"
require "net/http"
require "json"
require "date"
require "base64"

module AppStorePricing
  API_BASE = "https://api.appstoreconnect.apple.com".freeze
  INDEXES_DIR = File.expand_path("indexes", __dir__).freeze
  FX_API_URL = "https://open.er-api.com/v6/latest/USD".freeze
  UI = FastlaneCore::UI

  module_function

  def prompt_for_product(api_key_path:, app_bundle_id:)
    ensure_token(api_key_path)

    UI.message("Fetching subscriptions for #{app_bundle_id}…")
    subs = list_subscriptions(app_bundle_id)
    UI.user_error!("No subscriptions found in #{app_bundle_id}") if subs.empty?

    product_ids = subs.map { |s| s[:product_id] }.sort

    unless UI.interactive?
      UI.message("Available subscriptions in #{app_bundle_id}:")
      product_ids.each { |id| UI.message("  - #{id}") }
      UI.user_error!("Non-interactive mode: re-run with product:<product_id>")
    end

    UI.select("Pick a subscription:", product_ids)
  end

  def update_display_name(api_key_path:, app_bundle_id:, product_id:)
    ensure_token(api_key_path)

    sub_id = find_subscription_id(app_bundle_id, product_id)
    UI.user_error!("Subscription #{product_id} not found in #{app_bundle_id}") if sub_id.nil?

    localizations = fetch_localizations(sub_id)
    UI.user_error!("No localizations found for #{product_id}") if localizations.empty?

    UI.message("Current display names:")
    localizations.each { |loc| UI.message("  #{loc[:locale]}: #{loc[:name]}") }

    unless UI.interactive?
      UI.user_error!("Non-interactive mode: display name update requires a TTY")
    end

    updated = 0
    localizations.each do |loc|
      input = UI.input("  [#{loc[:locale]}] new name (empty=skip):")
      next if input.nil? || input.strip.empty?
      next if input == loc[:name]
      patch_localization_name(loc[:id], input)
      UI.success("    → #{input}")
      updated += 1
    end

    if updated.zero?
      UI.message("No display names changed.")
    else
      UI.success("Updated #{updated} locale(s).")
    end
  end

  def update(api_key_path:, app_bundle_id:, product_id:, base_usd:, index: "ppp", dry_run: true, mode: "tier")
    ensure_token(api_key_path)

    multipliers = load_index(index)
    fx_rates = mode == "fx" ? fetch_fx_rates : nil

    UI.message("Resolving subscription #{product_id} in #{app_bundle_id}…")
    sub_id = find_subscription_id(app_bundle_id, product_id)
    UI.user_error!("Subscription #{product_id} not found in #{app_bundle_id}") if sub_id.nil?

    UI.message("Fetching USA price points (anchor)…")
    usa_points = fetch_price_points(sub_id, "USA")
    UI.user_error!("No USA price points returned — cannot anchor.") if usa_points.empty?

    UI.message("Computing per-territory proposals (#{multipliers.size} territories, parallel, mode=#{mode})…")
    proposals, skipped = compute_proposals_parallel(
      sub_id, usa_points, multipliers, base_usd,
      mode: mode, fx_rates: fx_rates
    )

    print_table(proposals)
    unless skipped.empty?
      UI.important("Skipped #{skipped.size} territories: " +
                   skipped.map { |t, r| "#{t} (#{r})" }.join(", "))
    end

    if dry_run
      if UI.interactive? && !proposals.empty?
        unless UI.confirm("Apply these #{proposals.size} price changes?")
          UI.important("No changes applied.")
          return
        end
      else
        UI.important("Dry run only — no changes applied.")
        UI.important("Re-run with dry_run:false to apply.")
        return
      end
    end

    UI.message("Applying #{proposals.size} territory price updates…")
    start_date = (Date.today + 1).to_s
    proposals.each_with_index do |p, i|
      UI.message("  [#{i + 1}/#{proposals.size}] #{p[:territory]} → #{p[:local_price]} #{p[:local_currency]}")
      create_subscription_price(
        sub_id: sub_id,
        territory: p[:territory],
        price_point_id: p[:price_point_id],
        start_date: start_date
      )
    end
    UI.success("Updated #{proposals.size} territories.")
  end

  # === Auth ===

  def ensure_token(api_key_path)
    return if Spaceship::ConnectAPI.token
    UI.user_error!("API key not found at #{api_key_path}") unless File.exist?(api_key_path)
    Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.from_json_file(api_key_path)
  end

  def auth_headers
    {
      "Authorization" => "Bearer #{Spaceship::ConnectAPI.token.text}",
      "Accept" => "application/json"
    }
  end

  # === Index data ===

  def load_index(name)
    path = File.join(INDEXES_DIR, "#{name}.json")
    UI.user_error!("Index file not found: #{path}") unless File.exist?(path)
    raw = JSON.parse(File.read(path))
    data = raw["data"]
    UI.user_error!("Malformed index '#{name}': missing 'data' object") if data.nil? || data.empty?
    data
  end

  # === FX rates ===

  # Fetches live USD-base FX rates from open.er-api.com (free, no key, ~160
  # currencies). Used by mode:fx to convert the PPP-adjusted USD target into
  # local currency before snapping to the nearest App Store tier — this
  # bypasses Apple's cross-market tier mapping, which bakes in its own
  # implicit PPP for many currencies (KZT, INR, BRL…).
  def fetch_fx_rates
    UI.message("Fetching live USD FX rates from open.er-api.com…")
    uri = URI(FX_API_URL)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(Net::HTTP::Get.new(uri))
    end
    UI.user_error!("FX fetch failed: #{res.code} #{res.message}") unless res.is_a?(Net::HTTPSuccess)

    body = JSON.parse(res.body)
    if body["result"] != "success"
      UI.user_error!("FX fetch failed: #{body['error-type'] || 'unknown error'}")
    end

    rates = body["rates"]
    UI.user_error!("FX response missing 'rates'") if rates.nil? || rates.empty?

    UI.success("Loaded #{rates.size} FX rates (as of #{body['time_last_update_utc']})")
    rates
  end

  # === HTTP ===

  MAX_RATE_LIMIT_RETRIES = 5

  def http_get(path, params = {})
    uri = URI("#{API_BASE}#{path}")
    uri.query = URI.encode_www_form(params) unless params.empty?

    attempt = 0
    loop do
      req = Net::HTTP::Get.new(uri, auth_headers)
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

      if res.is_a?(Net::HTTPTooManyRequests) && attempt < MAX_RATE_LIMIT_RETRIES
        delay = (res["Retry-After"] || (2 ** attempt)).to_i
        delay = [delay, 1].max
        UI.message("  rate-limited; sleeping #{delay}s (attempt #{attempt + 1}/#{MAX_RATE_LIMIT_RETRIES})")
        sleep(delay)
        attempt += 1
        next
      end

      unless res.is_a?(Net::HTTPSuccess)
        UI.user_error!("ASC API GET #{path} failed: #{res.code} — #{res.body}")
      end
      return JSON.parse(res.body)
    end
  end

  def http_post(path, body)
    uri = URI("#{API_BASE}#{path}")
    headers = auth_headers.merge("Content-Type" => "application/json")
    req = Net::HTTP::Post.new(uri, headers)
    req.body = body.to_json
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    unless res.is_a?(Net::HTTPSuccess)
      UI.user_error!("ASC API POST #{path} failed: #{res.code} — #{res.body}")
    end
    JSON.parse(res.body)
  end

  def http_patch(path, body)
    uri = URI("#{API_BASE}#{path}")
    headers = auth_headers.merge("Content-Type" => "application/json")
    req = Net::HTTP::Patch.new(uri, headers)
    req.body = body.to_json
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    unless res.is_a?(Net::HTTPSuccess)
      UI.user_error!("ASC API PATCH #{path} failed: #{res.code} — #{res.body}")
    end
    JSON.parse(res.body)
  end

  # === Subscription lookup ===

  def find_subscription_id(bundle_id, product_id)
    list_subscriptions(bundle_id).find { |s| s[:product_id] == product_id }&.dig(:id)
  end

  def fetch_localizations(sub_id)
    res = http_get("/v1/subscriptions/#{sub_id}/subscriptionLocalizations", "limit" => 200)
    res["data"].map do |loc|
      {
        id: loc["id"],
        locale: loc["attributes"]["locale"],
        name: loc["attributes"]["name"]
      }
    end
  end

  def patch_localization_name(loc_id, new_name)
    body = {
      data: {
        type: "subscriptionLocalizations",
        id: loc_id,
        attributes: { name: new_name }
      }
    }
    http_patch("/v1/subscriptionLocalizations/#{loc_id}", body)
  end

  def list_subscriptions(bundle_id)
    apps = http_get("/v1/apps", "filter[bundleId]" => bundle_id)
    app = apps["data"]&.first
    return [] if app.nil?
    app_id = app["id"]

    result = []
    groups = http_get("/v1/apps/#{app_id}/subscriptionGroups", "limit" => 50)
    groups["data"].each do |group|
      subs = http_get("/v1/subscriptionGroups/#{group['id']}/subscriptions", "limit" => 200)
      subs["data"].each do |s|
        result << { id: s["id"], product_id: s["attributes"]["productId"] }
      end
    end
    result
  end

  # === Price points ===

  def fetch_price_points(sub_id, territory)
    points = []
    path = "/v1/subscriptions/#{sub_id}/pricePoints"
    params = { "filter[territory]" => territory, "limit" => 200 }

    loop do
      res = http_get(path, params)
      res["data"].each do |pp|
        points << { id: pp["id"], price: pp["attributes"]["customerPrice"] }
      end
      next_link = res.dig("links", "next")
      break if next_link.nil? || next_link.empty?

      uri = URI(next_link)
      path = uri.path
      params = URI.decode_www_form(uri.query || "").to_h
    end

    points
  end

  def nearest_price_point(price_points, target)
    price_points.min_by { |pp| (pp[:price].to_f - target).abs }
  end

  # Run per-territory proposal computation in a thread pool. Each territory
  # needs one HTTP fetch (the territory's full price-point list); doing them
  # serially for ~100 territories takes minutes. Threads + Net::HTTP release
  # the GIL on I/O so parallelism scales linearly until the ASC API rate-limits.
  def compute_proposals_parallel(sub_id, usa_points, multipliers, base_usd, mode: "tier", fx_rates: nil, concurrency: 4)
    queue = Queue.new
    multipliers.each_pair { |t, m| queue << [t, m] }

    proposals = []
    skipped = []
    results_mutex = Mutex.new
    progress_mutex = Mutex.new
    done = 0
    total = multipliers.size

    workers = Array.new(concurrency) do
      Thread.new do
        loop do
          territory, multiplier = queue.pop(true) rescue break

          target_usd = base_usd * multiplier
          anchor = nearest_price_point(usa_points, target_usd)

          if anchor.nil?
            results_mutex.synchronize { skipped << [territory, "no USA anchor"] }
          else
            territory_points, currency = fetch_territory_pricing(sub_id, territory)
            if territory_points.empty?
              results_mutex.synchronize { skipped << [territory, "no points in territory"] }
            else
              equivalent, reason = select_equivalent(
                mode: mode,
                anchor: anchor,
                territory_points: territory_points,
                target_usd: target_usd,
                currency: currency,
                fx_rates: fx_rates
              )

              if equivalent.nil?
                results_mutex.synchronize { skipped << [territory, reason] }
              else
                selected = snap_to_psych_price(equivalent, territory_points)

                results_mutex.synchronize do
                  proposals << {
                    territory: territory,
                    multiplier: multiplier,
                    target_usd: target_usd,
                    anchor_usd: anchor[:price].to_f,
                    local_price: selected[:price],
                    local_currency: currency,
                    price_point_id: selected[:id]
                  }
                end
              end
            end
          end

          progress_mutex.synchronize do
            done += 1
            UI.message("  [#{done}/#{total}] #{territory}") if done % 10 == 0 || done == total
          end
        end
      end
    end

    workers.each(&:join)
    [proposals, skipped]
  end

  # Pick the territory price point that should anchor the proposal.
  # - tier mode: match Apple's cross-market tier id (decode_tier). Inherits
  #   Apple's per-market price adjustments — e.g. a USA $22.99 tier maps to
  #   ₸3,550 in KAZ because that is how Apple grades the tier locally.
  # - fx mode: convert target_usd to local currency via live FX, then pick
  #   the nearest local tier. Ignores Apple's mapping; gives prices that
  #   track real exchange rates.
  def select_equivalent(mode:, anchor:, territory_points:, target_usd:, currency:, fx_rates:)
    case mode
    when "tier"
      anchor_tier = decode_tier(anchor[:id])
      eq = territory_points.find { |pp| decode_tier(pp[:id]) == anchor_tier } ||
           nearest_price_point(territory_points, target_usd)
      [eq, nil]
    when "fx"
      rate = fx_rates && fx_rates[currency]
      if rate.nil?
        [nil, "no fx rate for #{currency}"]
      else
        local_target = target_usd * rate.to_f
        [nearest_price_point(territory_points, local_target), nil]
      end
    else
      UI.user_error!("Unknown mode: #{mode} (expected 'tier' or 'fx')")
    end
  end

  # Snap the equivalent's local price to the nearest psych endpoint
  # ((X-1).99, X.49, X.99) and pick the closest tier from the already-fetched
  # territory points. For territories whose tier grid only offers integers
  # (JPY, KRW), nearest_price_point naturally returns the same tier — the
  # snap is a no-op rather than a special case.
  def snap_to_psych_price(equivalent, territory_points)
    natural = equivalent[:price].to_f
    return equivalent if natural <= 0

    rounded = nearest_psych_endpoint(natural)
    return equivalent if (rounded - natural).abs <= 0.001

    nearest_price_point(territory_points, rounded) || equivalent
  end

  def nearest_psych_endpoint(price)
    x = price.to_f.floor
    candidates = [x + 0.49, x + 0.99]
    candidates << x - 0.01 if x >= 1
    candidates.min_by { |c| (c - price).abs }
  end

  # Fetch all price points for a territory plus its currency code in a single
  # request (paginated). Returns [points_array, currency_string]. ASC API has
  # no `equivalentPricePoints` relationship for subscriptionPricePoints (only
  # for one-time IAPs), so we get the full list and match equivalents locally
  # via tier-id decoding.
  def fetch_territory_pricing(sub_id, territory)
    points = []
    currency = "?"
    path = "/v1/subscriptions/#{sub_id}/pricePoints"
    params = {
      "filter[territory]" => territory,
      "limit" => 200,
      "include" => "territory"
    }

    loop do
      res = http_get(path, params)
      if currency == "?"
        territory_data = res["included"]&.find { |i| i["type"] == "territories" }
        currency = territory_data&.dig("attributes", "currency") || "?"
      end
      res["data"].each do |pp|
        points << { id: pp["id"], price: pp["attributes"]["customerPrice"] }
      end
      next_link = res.dig("links", "next")
      break if next_link.nil? || next_link.empty?

      uri = URI(next_link)
      path = uri.path
      params = URI.decode_www_form(uri.query || "").to_h
    end

    [points, currency]
  end

  # Subscription price point IDs are base64-JSON of {"s": sub_id, "t":
  # territory, "p": tier}. The "p" identifies the tier and is shared across
  # equivalent price points in different territories.
  def decode_tier(price_point_id)
    JSON.parse(Base64.urlsafe_decode64(price_point_id))["p"]
  rescue StandardError
    nil
  end

  # === Apply ===

  # `preserveCurrentPrice: true` grandfathers existing subscribers at their
  # current price — the new price applies only to new subscribers. Without
  # this, increases trigger Apple's consent flow (and unsubscribe users who
  # don't opt in before renewal). Safer default for PPP rebalances.
  def create_subscription_price(sub_id:, territory:, price_point_id:, start_date:)
    body = {
      data: {
        type: "subscriptionPrices",
        attributes: { startDate: start_date, preserveCurrentPrice: true },
        relationships: {
          subscription: { data: { type: "subscriptions", id: sub_id } },
          subscriptionPricePoint: { data: { type: "subscriptionPricePoints", id: price_point_id } },
          territory: { data: { type: "territories", id: territory } }
        }
      }
    }
    http_post("/v1/subscriptionPrices", body)
  end

  # === Output ===

  def print_table(proposals)
    return if proposals.empty?
    UI.message("")
    UI.message(format("  %-5s  %-6s  %-10s  %-10s  %s",
                      "Terr", "Mult", "Target $", "Anchor $", "Local price"))
    UI.message("  " + ("-" * 55))
    proposals.sort_by { |p| p[:territory] }.each do |p|
      UI.message(format("  %-5s  %-6.2f  %-10.2f  %-10.2f  %s %s",
                        p[:territory], p[:multiplier], p[:target_usd],
                        p[:anchor_usd], p[:local_price], p[:local_currency]))
    end
    UI.message("")
  end
end
