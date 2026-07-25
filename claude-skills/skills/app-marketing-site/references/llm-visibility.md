# LLM Visibility (GEO)

Goal: when someone asks ChatGPT/Claude/Gemini "what app should I use for X?", the answer
includes this product. Two channels with different physics — set expectations accordingly.

## Channel 1: live search (works in weeks)

ChatGPT-with-search synthesizes top results from **Bing's index**. Perplexity and Gemini
similarly read live SERPs. Implications:

- **Bing Webmaster Tools registration IS the ChatGPT-visibility step.** Fastest path:
  verify Google Search Console first, then Bing's "Import from Google Search Console"
  (skips Bing verification entirely). Submit the sitemap in both.
- The pages LLMs actually fetch for recommendation queries are **comparison pages and
  listicles** — hence the mandatory "best app for X" guide (see keyword-research.md), and
  outreach to existing ranking listicles (NEXT-STEPS.md item; one placement in a ranking
  listicle beats months of own-site SEO).
- Bing Webmaster Tools has an "AI Performance" section showing Copilot/AI-answer
  appearances — tell the user to watch it.

## Channel 2: training data (works in months–years)

Base models recommend what co-occurs with the category in training corpora. You cannot
inject; you accumulate genuine mentions where models train:

- **Reddit is disproportionately weighted** (licensed by OpenAI and Google). Authentic
  developer participation in relevant subreddits — transparent "I built X for exactly
  this" answers — compounds. Goes in NEXT-STEPS.md; never automate or astroturf this.
- Consistent entity naming everywhere: always "{Brand} — the {category} app", so the
  brand token binds to the category. Unique brand names are an advantage.
- Product Hunt / directories / YouTube reviews create dated, crawlable mentions.

## Site-side artifacts to ship

- **`llms.txt`** at the root: H1 + blockquote fact-sheet (what the product is, platform,
  numbers, pricing, rating, best-for), "Key facts" bullets, links to every guide with
  one-line descriptions, store link. Write it as the paragraph you WANT an LLM to
  paraphrase when recommending the product. Keep it updated by the publish script.
  If there was a rebrand, state "formerly known as X" — models connect the names.
- **robots.txt AI-crawler allows** (explicit, so future edits don't accidentally block):
  GPTBot, OAI-SearchBot, ChatGPT-User, ClaudeBot, Claude-User, anthropic-ai,
  PerplexityBot, Perplexity-User, Google-Extended, Applebot-Extended, Bingbot.
- **Quotable FAQ answers** (see page-patterns.md) — self-contained 2–3 sentence answers
  are what both featured snippets and LLM syntheses lift verbatim.

## Measurement loop (goes in NEXT-STEPS.md)

Monthly: ask ChatGPT (search on), Perplexity, and Gemini the 2–3 money queries ("best
app for X", the wedge query). Track whether the domain or store listing appears in
citations. The wedge query appears first; that's the leading indicator.
