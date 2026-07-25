# Page Patterns

## Design language: derive it, don't invent it

Read the downloaded screenshots (as images) before styling. Pull background tones, accent
colors, typography feel (serif marketing text? rounded sans?) from the app's own store
assets into the CSS variables at the top of `styles-starter.css`. The site should look
like the app's world, and screenshots should look native on the page, not pasted on.

## Landing page section recipe (in order) — design system v2

1. **Hero** — monospace eyebrow, display-type H1 (gradient-italic accent phrase), lead,
   store CTA + anchor CTA, proof row (content stats; stars only with real rating volume),
   and a RAW app screenshot inside the CSS device frame with glow blobs behind.
2. **Live demo** — a working micro-interaction from the app's world (quiz, picker,
   phrase choice) in the `.demo-card`/`.quiz` component. The conversion centerpiece.
3. **How it works** — 3 numbered steps (CSS counter renders 01/02/03), real features.
4. **Bento grid** — big 2x2 wedge tile with an angled raw mini-screenshot, a giant stat
   tile, a REAL review quote tile (never fabricate; no reviews -> content stat), 2-3
   plain tiles. `rv` class for scroll reveal.
5. **Guides** — editorial index rows grouped by category (`.guide-group` > `.guide-cat`
   + `.guide-grid` with `<!-- CAT:x -->` markers). Row markup contract per guide:
   `.guide-card > .tag + h3 + p + .more` (the publish script inserts exactly this).
6. **FAQ** — `<details>` accordions; answers self-contained + "Learn more" to guides;
   mirrored into FAQPage JSON-LD.
7. **CTA band** — radial-glow dark card, urgency headline, store button repeat.
8. **Footer** — brand, guide links by category, store link, Terms/Privacy.

## Guide page formula

The searcher typed a question. The page earns its ranking by answering it better than
what currently ranks — and earns the install by showing the app as the way to act on the
answer. Order is everything:

1. H1 = the question/keyword, near the front. One-sentence promise under it.
2. **The substance** (60–70% of the page): the rules, the table, the numbers, the method.
   This must stand alone — a reader who never installs anything should still be glad they
   came. Include at least one real data table or structured list.
3. **The product integration** (`article-cta` block): "here's how to actually do this
   daily" — feature description + screenshot + store button. Written as the natural next
   step, never as an interruption of the answer.
4. A closing practical section (drill, self-test, plan, common mistakes).
5. **Related guides** (2–3 links) + 1–2 contextual in-body links to sibling guides.

Length: 600–900 words of real content. Title ≤ 60 chars; meta description 140–160 chars
with an implicit call to action.

## Category architecture (topic clusters)

Group guides into 3–5 categories (e.g. Grammar / Vocabulary / Speaking / Method). Each
category can grow to ~10 articles. Category hub pages only earn their existence at 4+
articles — below that, the grouped landing-page grid is the hub. Interlink within
categories densely, across categories sparingly.

## FAQ ↔ guide symmetry

Every guide gets a FAQ entry on the index; every FAQ entry links to a guide (or the store
for product questions like pricing). This gives each target query two shots: the guide
ranks for it, and the FAQ snippet answers it directly on the index.

## Mobile pass (mandatory before every deploy)

Most traffic is phones; a desktop-only check WILL ship broken layouts (learned on
here.lyncil.com: sideways-pannable page on iOS + clipped bento tiles). Two checks:

1. **Overflow probe** — inject into a copy of the page, render headless, read the output:
   any element wider than the viewport, or `scrollWidth > clientWidth` on
   `documentElement`, means iOS Safari can pan the whole page sideways. Decorative
   absolute elements (hero glows) are the usual culprits — the starter's
   `html,body { overflow-x: clip }` handles them; don't remove it.

   ```js
   window.addEventListener('load', () => {
     const vw = document.documentElement.clientWidth;
     const out = [`SCROLLW=${document.documentElement.scrollWidth} VIEWPORT=${vw}`];
     document.querySelectorAll('*').forEach(el => {
       const r = el.getBoundingClientRect();
       if (r.right > vw + 1 || r.left < -1)
         out.push(`OVER ${el.tagName}.${el.className} ${Math.round(r.left)}..${Math.round(r.right)}`);
     });
     document.body.appendChild(Object.assign(document.createElement('pre'),
       { id: 'dbgout', textContent: out.join('\n') }));
   });
   ```
   Run with `chrome --headless --dump-dom --window-size=390,900 --virtual-time-budget=4000`
   and grep for `dbgout`.

2. **Eyeball the phone layout** — full-page screenshot at narrow width and actually READ
   it top to bottom. Caveat: headless Chrome clamps the window to ≥500px wide, so
   screenshots at `--window-size=390,...` render a 500px layout clipped to 390 — text
   clipped at the right edge in such a shot may be an artifact, and sub-500px behavior
   must be reasoned from the media queries (or checked on a real device/simulator).
   Watch for: fixed-height grid tiles with more copy than fits (the starter collapses the
   bento to one column below 560px), an oversized hero device frame pushing the headline
   below the fold, and content-heavy tiles whose text underlaps absolutely-positioned
   mini-shots.
