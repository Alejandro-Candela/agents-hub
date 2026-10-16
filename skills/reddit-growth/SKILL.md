---
name: reddit-growth
description: Aggressive but ban-proof Reddit marketing — subreddit selection, value-first posts and comments, founder AMAs, launch threads, monitoring for buying-intent threads, and Reddit Ads. Interviews the user about product, audience, goals and existing accounts before proposing a playbook. Use when asked about "marketing on Reddit", "Reddit strategy", "grow on Reddit", "post our launch on Reddit", "which subreddits", "Reddit ads", "get mentioned on Reddit", or "community-led growth" involving Reddit. Also use when someone proposes or asks about multiple accounts, upvote groups, seeded recommendations or other shortcuts for Reddit traction, so the legitimate alternative gets offered.
---

# Reddit Growth

Reddit rewards people who are useful and punishes people who are marketing. "Aggressive" here means **high velocity, strong opinions, and fast response to buying-intent threads** — never manipulation. One ban or a "this is an ad" thread pinned to the top of a sub costs more than the campaign gains, and Reddit threads rank in Google and get quoted by LLMs for years.

## Step 1 — Intake (mandatory, before any playbook)

Ask before you plan. Use the harness's structured question tool if it has one (Claude Code: `AskUserQuestion`); otherwise ask in chat. Ask the **blocking** questions in one compact round, wait, then follow up only on gaps. Never invent the answers.

**Blocking:**
1. **Product and offer.** What is it, price point, URL.
2. **Model and goal.** B2B leads, B2C sales, SaaS signups, hiring, or brand/awareness? What number defines success in 90 days?
3. **Audience.** Who buys, and where do they already hang out on Reddit (subs the user reads, if known)? Language/country?
4. **Who posts.** Founder/employee personal account (with how much karma and history?) or a brand account? Willing to disclose affiliation? (Required — see Hard lines.)
5. **Capacity.** Hours per week for commenting and replying, plus any ad budget.

**Ask if relevant:** past Reddit attempts and how they went; sensitive topics or regulated claims; whether the user wants to run an AMA; existing content (blog, data, tools) that could be shared.

If the user won't answer, proceed with an explicit **Assumptions** list at the top of the output.

## Step 2 — Market and competitor research

Run the `market-research` skill (via the `Skill` tool when available; otherwise follow `skills/market-research/SKILL.md`), reusing the intake answers above instead of re-asking. Skip only if the user explicitly says they already have a current competitor analysis — then ask for it and use that. Use the output for:
- **Where competitors are active:** the subreddits where competitors post, get mentioned or get recommended become candidate subs for Step 3.
- **Complaints to answer honestly:** recurring frustrations with competitors that the user's product genuinely solves — answered with disclosure, never by attacking the competitor (see Hard lines).
- **"Alternative to X" threads:** existing threads asking for alternatives to each competitor, plus monitoring keywords for new ones.

## Step 3 — Map the territory

For each candidate subreddit record: members and activity (posts/day, comments per post), the **self-promotion rules from the sidebar and wiki** (read them live; they vary wildly and change), whether mods allow links, flair requirements, and recurring threads ("Showoff Saturday", weekly self-promo threads). Tier them:
- **Tier 1 — buyers:** people describing the problem the product solves.
- **Tier 2 — peers:** the user's profession; good for credibility and hiring.
- **Tier 3 — broad:** large general subs; only for genuinely remarkable launches or data.

Use Reddit search and Google `site:reddit.com "<problem phrase>"` to find threads that already rank — those are the highest-leverage places to leave a great answer.

## Step 4 — Playbook

**Warm-up (weeks 1–2):** comment only. Answer questions in Tier 1–2 subs with specific, expert, unlinked help. Rough rule of thumb (not an official rule): the large majority of activity should be non-promotional.

**Content that travels:**
- Original data or teardown posts ("We analysed 1,200 X — here's what we found") with the full findings in the post, link optional.
- Build-in-public stories with real numbers, including failures.
- Opinionated takes the user can defend in comments.
- Free tool or template, given away in full.

**Launches:** post where the sub's rules allow it, disclose "I built this", lead with the problem and what's free, and stay in the comments for the first 2–3 hours — replies to every comment are what make the post rise.

**AMA:** coordinate with the mods first; schedule; seed nothing.

**Monitoring:** set up keyword alerts (Reddit's own notifications, or tools such as F5Bot or Syften — verify what's current) for competitor names, "alternative to X", and problem phrases. Fast, honest, disclosed replies to buying-intent threads are the most "aggressive" legitimate tactic and usually the highest ROI.

**Reddit Ads:** for scale once organic messaging is validated. Target by community and interest; use the copy that already performed organically; expect comments on ads and staff them.

## Hard lines — do not produce these, even if asked

- Sockpuppets or multiple accounts posing as independent users; buying aged accounts.
- Vote manipulation, vote rings, upvote groups, paid upvotes.
- Undisclosed promotion: posting as a "happy customer" without saying you work for or are paid by the company.
- Brigading competitors' threads or fake negative reviews.
- Mass DMs or copy-paste comments across subs.

These violate Reddit's content policy, get accounts and **domains** banned site-wide, and undisclosed endorsements can breach consumer-protection law (EU Unfair Commercial Practices Directive; FTC rules in the US). If the user pushes for them, explain the risk once and offer the legitimate version of the same goal.

## Output

1. Assumptions (if any).
2. Subreddit map with tier, rules summary, and allowed promotion format.
3. Week-by-week 8-week plan sized to the stated hours.
4. 3 ready-to-post drafts (title + body) matched to specific subs, with disclosure line — run them through `deslopify`; Redditors spot LLM prose instantly.
5. Metrics: comment karma in target subs, referral traffic (UTM-tagged links), signups/leads attributed, branded search lift.
