# Legacy Knowledge Copilot — Hackathon Pitch Deck

> 11 slides · 3–5 minute pitch · presenter-ready.
> Repo: [cw-legacy-codeagent](../README.md) · Demo script: [demo-script.md](./demo-script.md)
>
> **PowerPoint version:** [pitch-deck.pptx](./pitch-deck.pptx) (regenerate with
> [`scripts/build-pitch-deck.ps1`](../scripts/build-pitch-deck.ps1) — requires
> PowerPoint / Microsoft 365).
>
> **Live presenter run-of-show:** [presenter-notes.md](./presenter-notes.md) —
> slide-by-slide *say this / do this / paste this* with backup demos and
> recovery one-liners. Speak from that file.

---

## Slide 1 — Title

### Legacy Knowledge Copilot
**The AI that finally understands your COBOL, your Struts 1, and your retiring SMEs.**

- A multi-agent GitHub Copilot assistant for legacy enterprise systems.
- Built on `github/awesome-copilot` conventions. Runs in VS Code.
- 100% grounded. 0% hallucinated.
- This project will be added to the Awesome GitHub Copilot Project list:
  https://awesome-copilot.github.com

> **Speaker notes (≈20s)**
> Hi, I'm here to show you Legacy Knowledge Copilot. In the next four minutes I'll show you how a multi-agent AI assistant turns impenetrable legacy code, plus the tribal knowledge that's about to walk out the door at retirement, into reviewable, citable, change-ready insight — without leaving VS Code. Let's go.

---

## Slide 2 — The Problem

### The legacy iceberg

- **220+ billion lines of COBOL** still run payments, claims, benefits, tax.
- Tens of thousands of **Struts 1.x** apps past end-of-life.
- **Median COBOL engineer is 55+.** SMEs retire faster than they're replaced.
- **Documentation is missing, stale, or contradictory.**
- A 5-line change can blow up a $40M nightly batch run.

> **Speaker notes (≈30s)**
> Every enterprise here is sitting on a generational cliff. There are over 220 billion lines of COBOL still running the world's payments and benefits systems. Most large enterprises still depend on a Struts 1.x app that's past end-of-life. And the people who actually understand those systems are retiring faster than we can replace them. The documentation is either missing or wrong. And because legacy stacks are tightly coupled, a five-line patch can break the overnight batch and trigger a forty-million-dollar incident. This is not a future problem. This is now.

---

## Slide 3 — Why Generic AI Falls Short

### "Just use Copilot" — but Copilot wasn't trained on *your* legacy

- GitHub Copilot was trained on GitHub. **GitHub doesn't have your COBOL.**
- It doesn't have your tribal Slack threads, your retired-SME interviews, or your "do not touch" invariants.
- Generic AI **invents** plausible-sounding answers. Compliance can't approve "plausible."
- Legacy work needs **auditable** answers, not autocomplete.

> **Speaker notes (≈25s)**
> The natural first reaction is: just use Copilot. But Copilot was trained on GitHub — and GitHub doesn't have your COBOL. It doesn't have the tribal Slack thread from 2014 explaining why a certain status code means "do not post." Generic AI will give you a confident, plausible answer — and in regulated industries, plausible is not approvable. We need *auditable*.

---

## Slide 4 — The Solution

### Legacy Knowledge Copilot

A multi-agent AI assistant that:

1. **Reads** COBOL, JCL, Struts 1, JSPs, non-normalized SQL Server, T-SQL stored procs.
2. **Grounds** every answer in curated tribal docs, technical papers, runbooks.
3. **Reviews** legacy code with a *risk* lens — distinguishes "bad code" from "load-bearing code."
4. **Plans** modernization incrementally (strangler-fig, characterization tests, phased rollout).
5. **Cites** every grounded claim and labels confidence — `grounded | partial | inferred`.

> **Speaker notes (≈25s)**
> So we built Legacy Knowledge Copilot. It reads the legacy stacks Copilot wasn't trained on. It grounds every answer in a curated knowledge base. It reviews code with a legacy-aware risk lens — it knows the difference between bad code and load-bearing code. It plans modernization safely. And — this is the important part — every single claim is cited, and every answer has a confidence label. Auditable.

---

## Slide 5 — How It Works

### Three agents · Eight skills · One knowledge base

```
@legacy-code   →  reads & explains legacy source
@knowledge     →  grounds answers in /knowledge with citations
@review        →  legacy-aware code review + modernization scoring

Skills: COBOL flow · Struts 1 lifecycle · Batch job analysis
        SQL schema analysis · Code review · Knowledge grounding
        Modernization · Legacy code explanation

Knowledge: tribal/  technical-papers/  runbooks/  do-not-touch/
```

> **Speaker notes (≈30s)**
> Three specialized agents. Eight reusable skills. One curated knowledge base. `@legacy-code` reads and explains the source. `@knowledge` grounds answers in tribal docs, runbooks, and technical papers — with citations. `@review` does the risk-aware code review and modernization scoring. The agents compose — they call each other when context is needed — and there's a deterministic routing layer published in the repo so it's not a black box.

---

## Slide 6 — Architecture (one diagram)

### Multi-agent, grounded, in VS Code

```
Developer in VS Code
        │
   Copilot Chat
        │
   Agent Router  ──►  @legacy-code  ──┐
        │            @knowledge      │──►  Skills
        │            @review         ──┘       │
        │                                      ▼
        └──────────────────────────►  /knowledge (tribal · runbooks · papers · do-not-touch)
```

- Zero infra. Just VS Code + Copilot Chat.
- Awesome-copilot conventions. Extensible by drop-in.

> **Speaker notes (≈20s)**
> Architecturally, this is intentionally boring. There's no new infrastructure to deploy. You install VS Code, install Copilot, clone the repo, and you're done. Following awesome-copilot conventions means every new agent, skill, or knowledge source is a drop-in file.

---

## Slide 7 — Demo (Part 1)

### Explain a 28-year-old COBOL batch — grounded

**Open:** `examples/cobol/NB_POST.CBL`
**Prompt:**
```
@legacy-code Explain examples/cobol/NB_POST.CBL end-to-end.
Pull tribal context for magic status codes ('A','R','H','Z9').
Cite every grounded claim.
```

**Watch the output for:**
- A clean division map + control-flow diagram.
- A magic-code table where `Z9` is **cited** to the SME note in `knowledge/tribal/`.
- A `Gaps` section telling you what knowledge is still missing.

> **Speaker notes (≈45s)**
> Live demo. This is a 28-year-old nightly billing batch nobody on the team has read. I paste one prompt. Watch — it gives me a division map, a control-flow diagram, and then *this* table of magic codes. See that row for `Z9`? It didn't guess. It pulled the meaning from a tribal note an SME wrote, and it cited the file. Compliance can click that link. That's the difference between AI guessing and an auditable answer. And notice the "Gaps" section at the bottom — the assistant tells me what knowledge is *missing*. That's a flywheel: every gap becomes a knowledge file, which grounds the next answer.

---

## Slide 8 — Demo (Part 2)

### Catch a cross-layer risk before it ships

**Open:** `examples/struts/.../ApproveClaimAction.java`
**Prompt:**
```
@review Review this Action and the stored procedure it calls.
Lenses: security, correctness, backward-compat with the
overnight NB_POST_NIGHTLY batch.
Honor /knowledge/do-not-touch.
```

**Findings:**
- `[blocker] [security] SQL injection`
- `[blocker] [security] Hard-coded credentials`
- `[major] [correctness] No transaction boundary`
- ✅ Did NOT violate the `Z9` invariant — checked `/knowledge`.

> **Speaker notes (≈40s)**
> Same assistant, different agent. I switch to `@review` and ask it to review the Struts Action that talks to the database. Look at the severity ladder — blocker, major. It catches the SQL injection. It catches the hard-coded credentials. But more importantly, it tells me — explicitly — that it did *not* recommend any change that would violate the `Z9` invariant we saw in the first demo. Because it consulted `/knowledge/do-not-touch`. That's a veto rule baked into the orchestration. The agent literally cannot recommend something the SMEs said is off-limits.

---

## Slide 9 — Demo (Part 3) + Differentiators

### Make sense of a non-normalized schema in 20 seconds

**Prompt:** `@legacy-code Analyze examples/sql/schema.sql ...`
**Output:** column dictionary, **inferred foreign keys** the DBA never declared, decoded `ROUTING_FLAGS` bitfield, and a value-vs-blast-radius normalization roadmap.

### Why we're different

- 🎯 **Built for legacy** — not a generic "explain my code" tool.
- 📎 **Cited, not invented** — every claim links back to `/knowledge`.
- 🛑 **Veto rules** — `do-not-touch` invariants are honored, not ignored.
- 🧩 **Composable** — new stacks (DB2, CICS, SSIS) are a folder + a skill.
- 🪶 **Zero infra** — VS Code + Copilot. Ship today.

> **Speaker notes (≈30s)**
> One more demo — I throw a non-normalized SQL Server schema at it. In twenty seconds I get a column dictionary, foreign keys it *inferred* from join evidence even though the DBA never declared them, the bitfield decoded, and a ranked normalization roadmap. So what's different? We're built for legacy. We cite instead of invent. We honor do-not-touch invariants. We're composable. And there's zero infrastructure — you can ship this today.

---

## Slide 10 — Impact

### Real-world impact, real numbers

- **Onboard to a legacy module in minutes** — not weeks.
- **Catch blast-radius issues at PR time** — not at 2 AM in production.
- **Turn one SME's notebook into a queryable knowledge graph.**
- **Make modernization a roadmap, not a rewrite.**

| Before | After |
|--------|-------|
| Senior SME bottleneck on every change | Self-serve grounded answers |
| Documentation rot | Knowledge promoted on every Gap |
| "Don't touch it, nobody knows what it does" | Cited explanations + risk-scored changes |
| Big-bang rewrites that fail | Strangler-fig plans that ship |

> **Speaker notes (≈30s)**
> What does this unlock? Onboarding to a legacy module in minutes instead of weeks. Catching blast-radius issues at PR time instead of at two AM in production. Turning one retiring SME's notebook into a queryable knowledge graph the whole team can use. And making modernization a roadmap of small, safe steps — instead of a rewrite that fails. That's the prize.

---

## Slide 11 — Roadmap & Close

### What's next

**30 days** — `KnowledgeIngestor` skill (PDF/Confluence/Word → headered markdown).
**90 days** — Static analyzers (Struts graph, COBOL `PERFORM/CALL`, T-SQL deps) feeding the agents; characterization-test generator; one-click modernization briefs.
**Beyond** — `MainframeAgent` (VSAM/DB2/IMS/CICS), `DataAgent` (SSIS/DataStage/Informatica), GitHub Actions PR reviewer, VS Code extension with citation panel, voice-mode SME capture.

### One line

> **Legacy isn't bad code. It's load-bearing code. We make it readable, reviewable, and ready for the next 20 years.**

🔗 [github.com/nprasann/cw-legacy-codeagent](https://github.com/nprasann/cw-legacy-codeagent)

Awesome GitHub Copilot Project list:
https://awesome-copilot.github.com

> **Speaker notes (≈25s)**
> In thirty days we ship the knowledge ingestor — drop a PDF in, get a headered markdown file out. In ninety, we wire in static analyzers and a characterization-test generator. Beyond that, mainframe and ETL stacks, a GitHub Actions PR reviewer, and voice-mode SME capture. To close: legacy isn't bad code, it's load-bearing code. We make it readable, reviewable, and ready for the next twenty years. Repo's open. Thank you.

---

## Appendix — Pacing & Backup

### Pacing target (4:00 total)

| Slide | Time | Cumulative |
|------:|-----:|-----------:|
| 1 Title              | 0:20 | 0:20 |
| 2 Problem            | 0:30 | 0:50 |
| 3 Why generic fails  | 0:25 | 1:15 |
| 4 Solution           | 0:25 | 1:40 |
| 5 How it works       | 0:30 | 2:10 |
| 6 Architecture       | 0:20 | 2:30 |
| 7 Demo 1 (COBOL)     | 0:45 | 3:15 |
| 8 Demo 2 (Review)    | 0:40 | 3:55 |
| 9 Demo 3 + Diff      | 0:30 | 4:25 |
| 10 Impact            | 0:30 | 4:55 |
| 11 Roadmap + close   | 0:25 | 5:20 |

Trim slides 6 and 9 for a tight 3-minute version.

### Backup prompts (judge Q&A)

- "Show me an incident scenario." → `@knowledge NB_POST_NIGHTLY failed at step 040 — what does the runbook say?`
- "Can it scope a migration?" → `@review Score modernization opportunities for the Approve Claim flow. Suggest a strangler-fig boundary toward Spring Boot.`
- "What if the knowledge is empty?" → run any prompt — confidence label says `inferred` and `Gaps` lists exactly what's needed.
- "How is routing decided?" → open [docs/agent-routing.md](./agent-routing.md) and show the flowchart.

### Recovery one-liners

- Copilot slow → "While that streams, here's the prompt and the expected sections."
- Wrong agent → re-prompt with `[ReviewAgent]` prefix.
- Network down → walk the mermaid diagrams in `docs/agent-routing.md`.

### Cheat-sheet one-liners (memorize)

- *"Citations turn AI answers into auditable answers."*
- *"Tribal knowledge becomes an asset, not a retirement risk."*
- *"Legacy isn't bad code — it's load-bearing code."*
- *"Three agents, one workflow, zero hallucinations on the things that matter."*
