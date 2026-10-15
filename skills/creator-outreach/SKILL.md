---
name: creator-outreach
description: Plan and run partnerships with content creators and influencers — finding the right creators, vetting audiences, outreach messages, briefs, deal structures, legal disclosure, and measuring results. Interviews the user about product, audience, goals and budget before proposing a plan. Use when asked about "influencer marketing", "work with creators", "YouTubers/TikTokers/LinkedIn creators", "sponsor a newsletter/podcast", "creator outreach", "UGC", "affiliate program for creators", or "find influencers for X".
---

# Creator Outreach

Creator marketing works when the creator's audience is the buyer and the creator genuinely uses the product. Follower count is the least important number. This skill always starts with an intake, because a B2B consultancy and a consumer app need entirely different creators, channels and deal structures.

## Step 1 — Intake (mandatory, before any plan)

Ask before you plan. Use the harness's structured question tool if it has one (Claude Code: `AskUserQuestion`); otherwise ask in chat. Ask the **blocking** questions in one compact round, wait, then follow up on gaps. Never invent the answers.

**Blocking:**
1. **Product and offer.** What is it, price point, URL, and is there a free tier or trial a creator can actually use?
2. **Model and goal.** B2B leads, B2C sales, SaaS signups, or awareness? What does success look like in numbers, and over what period?
3. **Audience.** Who buys, which countries and languages, which platforms they actually consume (LinkedIn, YouTube, TikTok, Instagram, podcasts, newsletters, X)?
4. **Budget.** Cash budget per month or campaign, and willingness to pay per result (affiliate/rev-share) vs flat fees vs product-only.
5. **Who runs it.** Who sends outreach, negotiates, and reviews content — and how many hours per week?

**Ask if relevant:** creators the user already follows or whose audience overlaps; past campaigns and results; claims that are regulated (health, finance, AI capabilities); brand guardrails; whether the user wants to be a creator themselves (founder-led content is often the cheapest channel for B2B).

If the user won't answer, proceed with an explicit **Assumptions** list at the top of the output.

## Step 2 — Market and competitor research

Run the `market-research` skill (via the `Skill` tool when available; otherwise follow `skills/market-research/SKILL.md`), reusing the intake answers above instead of re-asking. Skip only if the user explicitly says they already have a current competitor analysis — then ask for it and use that. Use the output for: **which creators, newsletters and podcasts competitors sponsor** (proven audience fit, and a read on what those creators charge and how often they take sponsors), which platforms the category under-uses, and the positioning gaps a creator brief should lead with. Feed the sponsor list into Step 4 as starting candidates, still vetted like any other.

## Step 3 — Pick the channel by model

| Model | Usually works best | Typical deal |
|---|---|---|
| B2B services / consultancy | LinkedIn creators, niche newsletters, industry podcasts, co-hosted webinars | Flat fee per sponsored issue/episode, or co-created content |
| B2B SaaS / dev tools | YouTube tutorials, dev newsletters, technical creators on X/LinkedIn | Flat fee + affiliate, free accounts |
| B2C | TikTok, Instagram, YouTube Shorts, UGC creators | Product seeding, flat fee, affiliate codes |

Prefer **micro and niche creators** (roughly 5k–100k followers) with high engagement and an audience that matches the buyer over large generic accounts.

## Step 4 — Find and vet

Find: search each platform for the problem keywords, look at who the target audience follows and who competitors sponsor, newsletter directories, podcast guest lists. Vet each candidate on: audience match (comments from real buyers?), engagement rate vs follower count, posting consistency, past sponsorships (too many = fatigued audience), brand safety (scan recent content), and fake-follower signals (sudden follower spikes, generic comments). Record everything in a sheet; never fabricate follower or engagement numbers — mark unknowns.

## Step 5 — Outreach

Short, personal, specific: reference one piece of their content and why their audience fits, what is offered (be concrete about money or terms), and an easy next step. No mass templates; send in small batches and follow up once after ~5 business days. Run drafts through `deslopify` and match register with the `email` skill for email outreach.

## Step 6 — Brief and contract

Brief: goal, key message (one), what the product does for their audience, must-say facts and must-not-say claims, CTA with tracked link or code, deliverables and dates, review process (light — creators know their audience better than the brand does), and usage rights if the brand wants to reuse the content as ads.

Contract essentials: deliverables, payment and timing, exclusivity window (if any), usage rights and duration, disclosure obligation, approval and correction process.

## Step 7 — Disclosure (non-negotiable)

Every paid or gifted promotion must be clearly disclosed by the creator, on the platform's native paid-partnership label where one exists, plus plain wording ("ad", "sponsored", "#publicidad"). Relevant frameworks — verify the current text before advising, do not quote from memory:
- **EU:** Unfair Commercial Practices Directive (hidden advertising is a banned practice).
- **Spain:** Ley General de Comunicación Audiovisual and its implementing rules for high-reach creators ("usuarios de especial relevancia"), and the Autocontrol influencer code of conduct.
- **US:** FTC Endorsement Guides.

The brand shares liability for undisclosed promotion. Never suggest "make it look organic" arrangements. For AI-product claims, run them past `ai-compliance-audit` first.

## Output

1. Assumptions (if any).
2. Channel recommendation with the reason tied to the intake answers.
3. Creator shortlist template (or filled list if research tools are available) with vetting columns.
4. 2 outreach drafts and 1 brief.
5. Measurement plan: unique links/codes per creator, cost per lead/signup/sale, and a decision rule for renewing a creator after the first deal.
