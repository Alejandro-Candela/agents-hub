---
name: market-research
description: Market and competitor deep research from the live web — finds direct competitors, adjacent/substitute products and open-source alternatives, then compares positioning, pricing, features, channels, traction and weaknesses with every fact sourced. Use when asked for "competitor analysis", "who are my competitors", "market research", "competitive landscape", "similar products to X", "alternatives to X", "positioning", "pricing comparison", or "market sizing". Also run as a step by the `seo-content-strategy`, `reddit-growth` and `creator-outreach` skills.
---

# Market Research

Marketing plans built only on the competitors the user already knows miss the ones that actually win their buyers' searches, threads and sponsorships. This skill searches the web for the real landscape — identical products, adjacent or substitute products, and open-source alternatives — and turns it into inputs a marketing plan can use. Every fact is sourced; nothing is filled in from memory.

## Step 1 — Intake (short)

If another marketing skill (`seo-content-strategy`, `reddit-growth`, `creator-outreach`) already ran its intake in this session, reuse those answers. Ask only what is still missing, in **one batched round** (Claude Code: `AskUserQuestion`; otherwise chat). Never invent the answers.

1. **Product.** What it is, URL if any.
2. **Value prop.** One line: what it does, for whom, better than what.
3. **Target customer.** Segment, company size or consumer profile.
4. **Geography and language.** Which markets matter; research in those languages too.
5. **Known competitors.** Any the user already tracks (optional — seeds, not the whole list).

## Step 2 — Check your tools first

Before searching, check which web tools the harness actually exposes: `WebSearch`/`WebFetch`, or search MCPs such as `duckduckgo-search` and `fetch`. If none is available, say so plainly, stop the research step, and offer the user a query list to run themselves. **Never pretend to have searched** or present remembered facts as fresh research.

## Step 3 — Search, then iterate to saturation

Start broad, then expand from each competitor found. Query patterns (adapt wording to the user's language and market):

- Category and problem: `<category> software`, `<category> tool`, `<problem> tool`, `best <category> for <segment>`.
- Competitor-seeded: `alternatives to <competitor>`, `<competitor> vs`, `<competitor> competitors`.
- Directories: G2, Capterra, Product Hunt, AlternativeTo, GitHub topics (`topic:<category>`, `awesome-<category>` lists) for open-source alternatives; app stores for B2C.
- Buyer voice: `site:reddit.com <problem> recommend`, `site:reddit.com <competitor> alternative`.
- Funding and size signals: Crunchbase-style profiles, funding announcements, LinkedIn company pages.

Loop: every new competitor seeds a fresh `alternatives to X` / `X vs` search. Stop when new searches stop surfacing new names (saturation) or at **~15–25 candidates**, whichever comes first. Classify each as **direct**, **adjacent/substitute** (solves the same job differently, including spreadsheets, agencies or doing nothing), or **open-source**. Shortlist **5–8** for deep profiling, explaining why each made the cut (closest to the user's offer, most visible to the same buyers, or most instructive).

## Step 4 — Profile each shortlisted competitor

Capture, each with its source URL:

| Field | What to record |
|---|---|
| URL | Homepage |
| Positioning | Their own one-liner, quoted from the site |
| Target segment | Who they explicitly sell to |
| Pricing | Model (seat, usage, flat, freemium, open-core) and visible price points |
| Key features | The 3–5 they lead with |
| Channels | Visible use of SEO content (blog, comparison pages), Reddit presence, creators/sponsorships/podcasts/newsletters, ads |
| Traction | Review counts and ratings, GitHub stars, funding, team size |
| Weaknesses | Recurring complaints from reviews and Reddit threads, quoted or paraphrased with link |

Rules: anything you could not find is **"not found"**, never guessed. Prices and features change — record the **date researched** at the top of the report.

## Step 5 — Synthesis

1. **Competitive matrix** — one table, competitors as rows, the fields above (condensed) as columns, the user's product as the first row.
2. **Positioning gaps / white space** — segments, use cases or price points nobody serves well, backed by the weaknesses found.
3. **Pricing benchmark** — range and median for comparable tiers; where the user's price sits.
4. **Channel map** — which channels each competitor uses, and which ones the category under-uses (the cheapest place to compete).
5. **Implications for the marketing plan** — 3–6 concrete points the calling skill can act on.
6. **Market sizing (optional)** — only if sourced data exists (analyst reports, public filings, credible estimates with links). Otherwise state "no sourced sizing data found" rather than estimating.

## Output

Ask whether the user wants the report saved as a markdown file (and where) or kept in chat. Either way it contains: date researched, tools used, the full candidate list with classification, the shortlist profiles with sources, and the synthesis. When called from another skill, hand the synthesis back to that skill's next step instead of ending the conversation.
