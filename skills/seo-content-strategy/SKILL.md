---
name: seo-content-strategy
description: SEO strategy beyond technical fixes — search intent, keyword research, topic clusters, content briefs, link earning, and visibility in AI answer engines. Interviews the user about product, audience and goals before recommending anything. Use when asked to "grow organic traffic", "what should we write about", "keyword research", "content strategy", "rank for X", "topic clusters", "content brief", "link building", "get cited by ChatGPT/Perplexity", or "SEO plan". For crawlability, meta tags, structured data and other on-page/technical fixes, use the `seo` skill instead.
---

# SEO Content Strategy

The `seo` skill makes a site indexable. This one decides **what to publish, for whom, and why it should rank**. A strategy built on guessed inputs is worse than none: it burns months of writing on keywords nobody converts on. So this skill always starts with an intake.

## Step 1 — Intake (mandatory, before any recommendation)

Ask before you plan. Use the harness's structured question tool if it has one (Claude Code: `AskUserQuestion`); otherwise ask in chat. Ask the **blocking** questions in one compact round, wait, then follow up only on what the answers leave open. Never invent the answers.

**Blocking — no strategy without these:**
1. **Product and offer.** What is sold, to whom, at what price point? URL if one exists.
2. **Business model and conversion.** B2B leads (demo/call), B2C purchase, SaaS signup, newsletter, or affiliate/ads? What counts as one conversion?
3. **Audience.** Who searches, in which language(s) and countries? What do they call the problem (their words, not ours)?
4. **Starting point.** New domain or existing? If existing: Google Search Console access, current monthly organic clicks, rough number of indexed pages.
5. **Capacity.** Who writes, how many pieces per month, budget for tools/freelancers/links, and the time horizon for results.

**Ask if relevant:**
- Top 3 competitors the user loses deals to (not who they admire).
- Subject-matter expertise in-house (needed for E-E-A-T on YMYL topics: health, finance, legal).
- Assets: original data, case studies, a product with a free tier or tool, founder with a public profile.
- Constraints: regulated claims, brand voice, languages that must ship together.

If the user declines to answer ("just give me something"), proceed but open the output with an explicit **Assumptions** list and mark every recommendation that depends on one.

## Step 2 — Market and competitor research

Run the `market-research` skill (via the `Skill` tool when available; otherwise follow `skills/market-research/SKILL.md`), reusing the intake answers above instead of re-asking. Skip only if the user explicitly says they already have a current competitor analysis — then ask for it and use that. Use the output for:
- **Competitor keyword and content gaps:** the comparison, alternatives and problem pages competitors publish (or don't), feeding the gap analysis in Step 3.
- **Winnable SERPs:** queries where the ranking competitors are weak (thin pages, complaints the user's product answers, no "X alternative" page) versus SERPs owned by entrenched players the user cannot outrank soon.

## Step 3 — Diagnose with data, not intuition

- Existing site: pull Search Console first (queries with impressions but position 8–30 are the cheapest wins; pages losing clicks year-on-year are the cheapest fixes). Use Ahrefs/Semrush/similar only if the user has access — never fabricate volumes or difficulty scores. If no data source is available, say so and rank opportunities qualitatively.
- Inspect the live SERP for each candidate keyword: what format ranks (guide, list, tool, product page, forum thread, video)? If Reddit/forums dominate, a polished article may lose; flag the `reddit-growth` skill.
- Gap analysis: queries competitors rank for that map to the user's offer.

## Step 4 — Map intent to the funnel

| Intent | Example | Content type | Conversion role |
|---|---|---|---|
| Transactional / commercial | "X pricing", "best X for Y", "X vs Y", "X alternative" | comparison, alternatives, pricing, landing pages | Highest. Build these first for B2B and SaaS. |
| Problem-aware | "how to fix Y", "why does Y happen" | guide that introduces the product as the fix | Medium, scales traffic |
| Informational / top-of-funnel | "what is Y" | glossary, explainer | Low conversion; build only with spare capacity or for authority |

Prioritise by **business value × ranking feasibility × effort**, not by search volume. A 50-search/month "X alternative" keyword usually beats a 5,000-search "what is X".

## Step 5 — Topic clusters

One pillar page per core problem, 5–15 supporting pages, each answering one intent; every supporting page links to the pillar and to 2–3 siblings with descriptive anchors. One primary keyword per URL — two pages targeting the same intent cannibalise each other.

## Step 6 — Content briefs

Each brief contains: primary keyword + intent, target reader and the job they are doing, what the current top 3 results miss (the angle), required original element (data, screenshot, worked example, expert quote — something an LLM can't produce from the same SERP), outline, internal links in/out, CTA matched to intent, and success metric. Run drafts through `deslopify`; generic AI prose is what Google's helpful-content systems and readers both discount.

## Step 7 — Authority and link earning

Earn links with assets people cite: original research/data, free tools, templates, strong opinions with evidence. Distribution channels: digital PR to journalists, guest appearances (podcasts beat guest posts), partner and integration pages, community presence (`reddit-growth`), creators (`creator-outreach`). **Do not recommend** buying links, PBNs, or link exchanges at scale — Google's spam policies penalise them and the penalty lands on the user's domain.

## Step 8 — AI answer engines

LLM-powered search (Google AI Overviews, ChatGPT search, Perplexity) cites pages that state facts plainly, answer the question in the first paragraph, carry original data, and are mentioned on third-party sites (Reddit, reviews, comparison articles). Same fundamentals; weight brand mentions and quotable, self-contained answers higher. Crawler access and `llms.txt` belong to the `seo` skill.

## Output

1. Assumptions (if any) and the data sources actually used.
2. Prioritised opportunity list (keyword/cluster, intent, why it's winnable, effort).
3. 90-day calendar sized to the stated capacity.
4. 2–3 full briefs for the top items.
5. KPIs per stage: impressions and positions (month 1–3), clicks (3–6), conversions from organic (6+). Say plainly that new domains rarely see meaningful traffic before month 3–6.
