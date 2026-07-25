# Prints the App Store Connect state needed for a release audit in one shot:
# live + editable version (state, selected build), latest builds, pending review
# submissions, and the age rating declaration.
#
# Run from the iOS project root (the dir with Gemfile + fastlane/):
#   LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 bundle exec ruby <this file> [bundle_id]
#
# bundle_id defaults to the app_identifier in ./fastlane/Appfile.
# API key: ENV["ASC_API_KEY_PATH"] or ~/.fastlane/key.json (same as fastlane-shared).

require "spaceship"
require "json"

def attrs_of(model)
  h = {}
  model.instance_variables.each { |v| h[v.to_s.delete("@")] = model.instance_variable_get(v) }
  h.reject { |k, val| val.nil? || %w[id reverse_attr_map].include?(k) }
end

bundle_id = ARGV[0]
if bundle_id.nil? || bundle_id.empty?
  appfile = File.read("fastlane/Appfile") rescue abort("ERROR: no bundle_id arg and no fastlane/Appfile")
  bundle_id = appfile[/app_identifier[ (]+["']([^"']+)["']/, 1] or abort("ERROR: app_identifier not found in Appfile")
end

key_path = ENV["ASC_API_KEY_PATH"] || File.expand_path("~/.fastlane/key.json")
Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.from_json_file(key_path)

app = Spaceship::ConnectAPI::App.find(bundle_id) or abort("ERROR: app #{bundle_id} not found on ASC")
puts "APP: #{app.name} (#{app.id}) bundle_id=#{bundle_id}"

live = app.get_live_app_store_version
puts "LIVE: #{live ? "#{live.version_string} state=#{live.app_store_state}" : 'none'}"

edit = app.get_edit_app_store_version
if edit
  build = edit.build rescue nil
  puts "EDIT: #{edit.version_string} state=#{edit.app_store_state} release_type=#{edit.release_type}"
  puts "EDIT_BUILD: #{build ? build.version : 'NONE SELECTED'}"
else
  puts "EDIT: none (create one in ASC or via deliver before pushing version-level metadata)"
end

# get_builds pages through everything regardless of limit — slice client-side
app.get_builds(sort: "-uploadedDate", includes: "preReleaseVersion").first(5).each do |b|
  v = b.pre_release_version&.version rescue "?"
  puts "BUILD: v#{v} (#{b.version}) state=#{b.processing_state} uploaded=#{b.uploaded_date}"
end

# NOTE: Spaceship::ConnectAPI::ReviewSubmission.all does not exist (fastlane ≥2.23x);
# the instance method on App is the working API.
subs = app.get_review_submissions(filter: { "platform" => "IOS" }) rescue []
pending = subs.select { |s| %w[READY_FOR_REVIEW WAITING_FOR_REVIEW IN_REVIEW UNRESOLVED_ISSUES].include?(s.state) }
puts pending.empty? ? "REVIEW_SUBMISSION: none pending" : pending.map { |s| "REVIEW_SUBMISSION: #{s.id} state=#{s.state}" }.join("\n")

info = (app.fetch_edit_app_info rescue nil) || (app.fetch_live_app_info rescue nil)
decl = info&.fetch_age_rating_declaration rescue nil
puts "AGE_RATING: #{decl ? JSON.generate(attrs_of(decl)) : 'NOT DECLARED'}"
