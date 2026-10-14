---
name: design-fidelity-review
description: Compare a built web page against its design reference (Stitch screenshot or HTML, Figma export, mockup PNG) at desktop, tablet, and mobile widths, and review scroll-driven motion for narrative, pacing, density, and reduced-motion behavior. Use whenever someone asks "does the build match the design", "compare against the mockup/Stitch/Figma", "check the port", "review the scroll animations", "is the motion too much", or has just ported a generated design into code and wants it checked, even if they don't say "fidelity". Not for static review of UI source (web-design-guidelines), Lighthouse or Core Web Vitals (web-quality-audit), exploratory bug hunting (dogfood), or building the motion itself (scrollytelling).
---

# Design fidelity review

Checks a rendered page against two things code review can't see: the design it was supposed to reproduce, and how its motion feels as you scroll. It produces evidence (screenshots, measured values) and a ranked list of deltas, not a score.

Two modes. Run whichever the request implies; run both if the page has a reference and scroll-driven motion and the user asked for a general review.

| Mode | Needs | Answers |
|------|-------|---------|
| **Visual** | Running page + a design reference | Where does the build drift from the design, and does it hold up at every width? |
| **Motion** | Running page with scroll-driven animation | Does the motion serve the story, is it paced and restrained, does it degrade cleanly? |

## Before you start

1. **Get a URL.** A local dev server is the normal case. If nothing is running, ask how to start it rather than guessing a command.
2. **Get the reference** (visual mode). Accept a PNG/JPG, a Stitch export (HTML + screenshot), or a Figma frame export. Note the width each reference was drawn at; that width is the only one you can compare strictly.
3. **Pick the browser tool.** Prefer Playwright MCP (`browser_navigate`, `browser_resize`, `browser_take_screenshot`, `browser_evaluate`, `browser_emulate_media`). Fall back to Chrome DevTools MCP (`navigate_page`, `resize_page`, `take_screenshot`, `evaluate_script`, `emulate`). If neither is available, say so and stop; reasoning about JSX is not a substitute for looking at the page.
4. **Save evidence** named `<mode>-<width>-<section>.png` and list the paths in the report. Playwright MCP only writes inside its own output directory (`.playwright-mcp/` in the working directory); save there and move the files to a scratch directory afterwards, so screenshots of a client's site never sit in a repo.

## Visual mode

### Breakpoints

Default widths: **1440** (desktop), **768** (tablet), **390** (mobile). Use the project's own breakpoints if it defines them.

- At the reference's width: compare strictly. Every visible difference is a candidate finding.
- At other widths with no reference: you can't claim drift from a design that doesn't exist. Check only for breakage: horizontal overflow, overlapping or clipped elements, text that wraps into nonsense, unreadable sizes, tap targets under 24×24px, sections that vanished.

### What to compare

Work top to bottom, section by section. Full-page screenshots hide detail; capture viewport-height slices at the same scroll offsets as the reference.

1. **Layout and structure.** Section order, column count, alignment axes, element presence. Missing or reordered sections are the most expensive drift.
2. **Spacing rhythm.** Gaps between sections and within groups. Measure with `getBoundingClientRect()` rather than eyeballing; report the values.
3. **Typography.** Family, size, weight, line-height, letter-spacing of headings and body. Read them from `getComputedStyle()` on representative elements.
4. **Color.** Backgrounds, text, accents, borders. Read computed values. A near-match (e.g. `#1a1a1a` vs `#111111`) is low severity unless it breaks contrast.
5. **Imagery and icons.** Correct asset, crop, aspect ratio, placeholder images left in.
6. **Copy.** Lorem ipsum, truncated headings, text that differs from the reference.

If the reference is HTML (Stitch exports one), extract its tokens directly: open it in the browser and read computed styles from the same elements. Comparing measured values against measured values is far more reliable than comparing against a PNG.

### Severity

- **High**: missing/reordered section, broken layout at any width, wrong brand color or typeface, unreadable text.
- **Medium**: spacing or type-scale drift a designer would notice at a glance, wrong image crop, component variant mismatch.
- **Low**: sub-4px offsets, near-identical colors, minor radius or shadow differences.

Don't report anti-aliasing, font-rendering, or sub-pixel differences between a design tool and a browser. They are noise, and burying real findings under them is the most common way this review loses its value.

## Motion mode

Scroll-driven motion is judged on whether it helps someone follow the page. Spectacle that fights the content is a defect, even if it's well built.

### Capture

1. Load at 1440 and 390 widths.
2. Scroll in steps of roughly half a viewport, screenshotting each step. This is the storyboard you review.
3. At each step, record what is animating: `document.getAnimations().filter(a => a.playState === 'running').length`, plus the animated properties if you can read them.
4. Repeat the scroll with `prefers-reduced-motion: reduce` emulated.

### What to judge

1. **Narrative.** Can you state what each section is trying to say? Does its motion reinforce that, or is it decoration? Is there a clear order of chapters?
2. **Pacing.** How many viewport-heights does each chapter consume? A chapter that takes three screens of scrolling for one sentence is too slow; key content flashing by in under half a screen is too fast.
3. **Density.** Count concurrent animations per step. More than two or three competing focal movements is overload. Particle effects, streaks, and parallax layers count individually toward the noise even when they're cheap to render.
4. **Readability.** Is text ever moving, fading, or overlapped by animation while the reader needs to read it?
5. **Control.** Is native scroll preserved? Flag scroll-jacking: non-passive `wheel` or `touchmove` listeners, `overflow: hidden` on `html` or `body`, or scroll position being set programmatically during normal scrolling.
6. **Reduced motion.** With the preference on, all content must still appear, nothing should stay invisible waiting for an animation, and parallax, shake, and large movements should be gone. Content stuck at `opacity: 0` is high severity: it's invisible to exactly the users who asked for less motion.
7. **Safety.** Anything flashing more than 3 times per second is high severity (WCAG 2.3.1). Screen shake and large zooms are vestibular triggers; check that they're optional or absent under reduced motion.

Frame rate and jank belong to `web-quality-audit` (performance traces). If motion feels janky, note it and hand off rather than diagnosing it here.

## Report

Use this structure:

```markdown
## Design fidelity review: <page>

**URL:** … · **Reference:** <file>, drawn at <width>px · **Tool:** Playwright MCP
**Evidence:** <scratch dir>

### Visual: <N> findings
| # | Sev | Width | Section | Reference | Build (measured) | Likely source |
|---|-----|-------|---------|-----------|------------------|---------------|
| 1 | High | 390 | Pricing | 3 cards stacked | cards overflow, 412px wide | `components/Pricing.tsx` grid |

### Motion: <N> findings
| # | Sev | Step / section | Observation | Why it matters | Suggested change |
|---|-----|----------------|-------------|----------------|------------------|

### Reduced motion
Pass / fail, with the specific elements that misbehave.

### Not checked
Widths without a reference (breakage-only), states not reached (auth, forms), anything skipped and why.
```

Order findings by severity. For each, say where in the code the fix likely lives when you can find it; a quick search for the section's heading text or class name usually locates it. Report what you measured, not what you assume. If a value couldn't be read, say so.
