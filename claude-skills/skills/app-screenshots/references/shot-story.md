# The shot story

Screenshots are the highest-leverage conversion asset on the product page. Design the *set*
as a narrative, not a tour of the UI.

## Principles

- **First three shots do the work.** Most users never swipe past the third; on the search
  results grid only 1–3 are visible. Each of the first three must sell one benefit and stand
  alone.
- **One idea per shot.** A benefit, not a feature dump. The screen is the evidence.
- **Benefit, not label.** The idea is "*Rediscover it when you least expect it*", the screen
  is a delivered capsule — not "Detail view".
- **Order by strength, then flow.** Hero (the single most compelling screen) first, then the
  core loop, then the payoff/differentiators.
- **Show the good state.** Full lists, subscribed (no lock icons), realistic-but-flattering
  content. Never an empty state as shot 1.
- **Localize the story too.** The demo *content* changes per locale (names, sample text);
  the *screens and order* stay the same.

## A repeatable 5-shot template (adapt per app)

1. **Hero** — the app's signature screen at its most alive (the one thing only this app does).
2. **Core action** — the primary thing users do, mid-flow, looking rich and easy.
3. **The hook** — the mechanic that makes it interesting (scheduling, streak, AI, privacy…).
4. **The payoff** — the reward state the user is buying (the result, the delivered thing).
5. **Differentiator / breadth** — variety, personalization, or a trust/quality signal.

## Patterns by category

- **Journaling / capsule / notes:** hero = a beautiful populated home; action = compose with
  rich media; hook = the twist (sealed-until-a-date, encryption); payoff = reading it back.
- **Habit / wellness / affirmations:** hero = today's focus/prompt; action = the session/
  player; hook = personalization or streak; payoff = progress/library.
- **Utility / productivity:** hero = the "after" (clean/organized result); action = the fast
  input; hook = automation; payoff = time saved / dashboard.
- **Social / content:** hero = the feed at its best; action = create/post; hook = discovery;
  payoff = engagement/notifications.

## Clean vs. caption (which stage owns what)

- **Clean** device screens are this skill's output: the screen's own header carries the
  message. Highest polish, least maintenance, best when the app's UI already says the
  benefit. Localizes for free (the app screen is already localized).
- **Caption** (a marketing headline band + background above the device frame) is added
  **downstream**, not here — typically in AppScreens, with the headline copy localized via
  its CSV flow. Use captions when the benefit isn't obvious from the screen alone, or the
  category expects it (games, some utilities). That whole stage — copywriting the headlines,
  highlighting the value word, localizing, and the AppScreens import format — is the sibling
  skill **`app-screenshots-captions`**.

Even if you'll add captions later, still design the shot *story* here (which screens, order,
demo content), because the caption headline and the screen must reinforce the same one idea.

## Apple hard rules (check before shipping)

- Sizes: supply the required 6.9"/6.5" iPhone set (App Store up-scales down where allowed);
  add iPad 13" if the app is universal. Confirm current requirements in App Store Connect.
- Max 10 per localization; the first is the default preview.
- No device frames that misrepresent, no pricing claims that aren't true, no fabricated
  ratings/reviews or fake system UI, no other platforms' trade dress.
