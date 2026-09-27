---
name: bug-report-writer
description: >
  Turns a loose complaint about a broken tool into a structured, Slack-ready
  bug report in a six-section format (Description, Steps to
  Reproduce, Expected Behavior, Actual Result, Additional Information, Request
  for Solution). Interviews the reporter for what is missing first, so
  developers get something reproducible instead of "it doesn't work". Use
  whenever someone reports that a system is broken, erroring, hanging, or
  behaving unexpectedly — an internal tool, n8n, Notion, Jira, Supabase, a
  client system, any internal tool. Trigger on "write a bug report", "report
  this bug", "file a bug", "something is broken", "X doesn't work", "I'm
  getting an error in X", "the upload keeps failing", "Fehler melden", "das
  funktioniert nicht" — and also when someone merely describes a malfunction
  without ever saying "bug". Output is always English. Not for feature requests
  (use apli-use-case-submitter), meeting action items (tasks-to-jira-tickets),
  or creating the issue in Jira (jira-sync).
metadata:
  version: "1.0"
  category: operations
  updated: "2026-08"
disable-model-invocation: true
---

# Bug Report Writer

A good bug report is a gift to whoever has to fix it. A bad one costs two
days of back-and-forth. The difference is almost never effort — it is that
the reporter knows things they never thought to write down: which browser,
what the error actually said, whether it happens every time, what they had
already tried.

Your job is to pull those things out, then compress them into the
six-section format below. You are writing for a developer who has never seen
this system, has no access to the reporter's screen, and needs to reproduce
the problem in under five minutes.

## Workflow

1. **Read what the reporter already gave you.** Slack messages, screenshots,
   error text, a verbal grumble — extract everything usable before asking
   anything. Nobody enjoys being asked what they just said.
2. **Ask one focused round of questions** for the gaps that matter (see
   below). One round, not a ping-pong — people abandon interviews.
3. **Draft the report** in the exact structure below.
4. **Run the self-check**, then hand it over with a note on what to attach.

## The interview

Ask only what is missing, grouped in a single message, numbered so the
reporter can answer selectively. Say plainly which answers you need and which
would just be nice, so a busy person can give you three lines and still get a
usable report.

These are the gaps worth chasing, roughly in order of how often they are the
thing that unblocks the developer:

- **The exact error text.** Verbatim, including any error code or ID. "An
  error appeared" is nearly useless; `Failed to execute 'removeChild' on
  'Node'` points straight at a line of code. Ask them to copy it or screenshot
  it.
- **Environment.** Browser and version, operating system, device, and whether
  they were on VPN. A bug that only appears in one browser looks like a broken
  feature until the browser is named, at which point it becomes a one-line fix.
- **Steps, in order, from a clean start.** Walk them back: what did they click
  first? What file or input did they use, and how big was it?
- **Frequency and scope.** Every time, or once? Only them, or colleagues too?
  Only with one file, or all files? A bug that happens once in ten tries needs
  a different investigation than one that happens always.
- **What they already tried.** Workarounds, retries, different sizes,
  different browsers. This is the most-often-omitted and most-valuable
  section — it tells the developer where not to look.
- **Impact.** Is this blocking their work, a client deadline, or merely
  annoying? Developers triage on this, and the reporter is the only one who
  knows.
- **When it started.** First noticed today? After a release? Did it ever work?
- **What they want to happen.** The "Request for Solution" is theirs to make,
  not yours to invent.

For the closed questions — browser, frequency, blocking or not — offer the
options rather than leaving a blank, if your environment lets you ask
multiple-choice questions. People answer those instantly and skip open ones.

If the reporter cannot answer something, that is fine and worth recording:
"Error text not captured — reporter will add screenshot" is honest and tells
the developer to wait for it. Never fill a gap with a plausible guess. An
invented error message or an assumed browser sends someone hunting for a bug
that does not exist, and it destroys trust in every other line of the report.

## Output structure

Use these six sections, in this order, with these exact headings. Keep it
scannable — this lands in a Slack channel where people read on phones.

```
*Description:*
[2-4 sentences: who was doing what, in which system, and what went wrong.
Third person, present tense. Enough context that a stranger understands the
situation without asking.]

*Steps to Reproduce:*
1. [One action per step, starting from a clean state. Name the system, the
   entry point, and the actual data used.]
2. ...

*Expected Behavior:*
[One or two sentences. What the system should have done.]

*Actual Result:*
[One or two sentences plus the verbatim error, in `code formatting` if short.]

*Additional Information:*
• [What was already tried, and the result]
• [Scope: who else is affected, which browsers, which files]
• [When it started, frequency, workaround in use]
• [Impact, if it is blocking someone or something]

*Request for Solution:*
[One line: what the reporter is asking the team to do.]
```

Practical points that decide whether this report works:

- **Slack bold is single asterisks** (`*Description:*`), not double. Deliver it
  that way so it renders on paste. If the reporter says it is going into Jira,
  Notion, or a document instead, switch to standard markdown headings.
- **Description is context, not diagnosis.** Reporters usually arrive with a
  theory ("the 200-page limit must be broken"). Theories are welcome but they
  belong in Additional Information, labelled as a suspicion. If the theory
  quietly becomes the Description, the developer inherits the wrong hypothesis
  and stops looking.
- **Steps must survive a stranger.** Read them back as if you had never used
  the system. If a step assumes knowledge the reporter has and the developer
  does not — a bookmark, a saved filter, a particular test account — spell it
  out.
- **Actual Result is what happened, Expected Behavior is what should have.**
  If those two sentences say the same thing in different words, the report is
  not yet saying anything.
- **Request for Solution asks for an outcome**, not an implementation, unless
  the reporter genuinely knows the system. "Support PDFs over 200 pages, or
  give a clear error at upload" is actionable. "Refactor the parser" from a
  non-engineer is noise.
- **Keep it short.** No section over five lines. If Additional Information runs
  long, the least useful bullets go.

## Worked example

An illustrative case — the tool and details here are invented, so treat this as
a shape to copy rather than a real incident.

Reporter's raw input:

> I can't get the internal expense portal to accept my receipts. It uploads the
> PDF fine but then it errors out when I submit and nothing gets filed. Tried a
> few different receipts. Screenshot attached.

What the interview added: Firefox on Windows 11; the verbatim error from the
screenshot; three receipts tried, all failing; a colleague who submitted
successfully the same morning; the reporter's last successful submission was in
July; and a month-end deadline making it blocking.

Finished report:

```
*Description:*
The reporter is unable to submit expense claims in the internal expense portal.
Receipt PDFs attach without a problem, but submitting the claim produces an
error and no claim is created. The reporter has reproduced this with three
different receipts.

*Steps to Reproduce:*
1. Open the internal expense portal in Firefox on Windows 11.
2. Create a new expense claim and complete the required fields.
3. Attach a receipt as a PDF (approx. 1 MB).
4. Click Submit and observe the error message.

*Expected Behavior:*
The claim should be created and appear in the reporter's list of submitted
claims, awaiting approval.

*Actual Result:*
An error appears and no claim is created: `TypeError: Cannot read properties of
null (reading 'status')`.

*Additional Information:*
• Reproduced with three different receipt PDFs, so the failure is not tied to
  one file.
• A colleague submitted a claim successfully the same morning, so the portal is
  not down for everyone.
• The reporter's own last successful submission was in July; this is the first
  attempt since.
• Blocking: the claim covers travel that has to be filed before month-end.

*Request for Solution:*
Identify why submission fails for this account, and surface a specific message
instead of a generic error when it does.
```

Notice what the interview earned. The reporter's first sentence supports no
investigation at all. The verbatim error points at a null object rather than at
the PDF the reporter blamed; one colleague succeeding rules out a full outage
and points at the account or session; three files failing rules out the file.
And "blocking, month-end" is the only reason this gets picked up today rather
than next sprint.

More examples — a one-line complaint with almost nothing in it, and a German
report rendered into English — are in `references/examples.md`. Read that file
when the input is unusually thin or not in English.

## Before you hand it over

Check these four things. They catch nearly everything that goes wrong:

1. **Reproducible?** Could someone with no context follow the steps and see
   the same failure? If not, which step is missing?
2. **Nothing invented?** Every fact traces back to something the reporter said
   or a file they shared. Gaps are marked as gaps.
3. **No sensitive data?** Bug reports go into open channels. Strip client
   names, personal data, credentials, API keys, and customer content from
   error dumps and screenshots — replace with `[client name]` or a redaction
   note. This matters legally, not just as etiquette.
4. **English, and short enough to read on a phone?**

Then tell the reporter, in one line each:

- What to attach — screenshot of the error, the offending file if it can be
  shared, a browser console log if they can get one.
- Where it should go — ask the reporter, and do not name a channel yourself.
  your client runs several tools, ownership shifts, and a report posted in the wrong
  place is a report nobody owns. The reporter knows which team or thread this
  belongs to; if they do not, tell them to check with the tool's owner rather
  than guessing.
- Anything still open that they need to fill in.

If they want it in Jira rather than Slack, hand off to the `jira-sync` skill
once the text is agreed; do not rebuild the ticket yourself.
