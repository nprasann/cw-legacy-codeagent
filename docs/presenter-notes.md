# Presenter Run-of-Show — Legacy Knowledge Copilot

> Speak from this. Open it on a second screen during the pitch.
> Companion to: [pitch-deck.pptx](./pitch-deck.pptx) · [pitch-deck.md](./pitch-deck.md) · [demo-script.md](./demo-script.md)
>
> Target runtime: **4:00** (works in 3:00 with the "tight cut" notes).
> Format: every slide has **say this**, **do this**, and the **exact prompt** to paste.

---

## 0. T-30 minutes — Pre-flight (do this before you walk on stage)

1. **Plug in. Disable sleep.** Close Slack, email, calendar, recording apps that steal focus.
2. **Open PowerPoint** → [docs/pitch-deck.pptx](./pitch-deck.pptx) → **Slideshow → From Beginning** to verify it renders, then exit. Bring up **Presenter View** when you actually start.
3. **Open VS Code** in this repo. In a second window, open **only these tabs** in this order so the demo doesn't fumble:
   1. [examples/cobol/NB_POST.CBL](../examples/cobol/NB_POST.CBL)
   2. [knowledge/tribal/nb-post-z9-special-hold.md](../knowledge/tribal/nb-post-z9-special-hold.md)
   3. [examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java](../examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java)
   4. [examples/sql/usp_PostClaimApproval.sql](../examples/sql/usp_PostClaimApproval.sql)
   5. [examples/sql/schema.sql](../examples/sql/schema.sql)
   6. [docs/agent-routing.md](./agent-routing.md) *(backup tab for Q&A)*
4. **Open the Copilot Chat panel.** `Ctrl+Alt+I`. Confirm **"Use workspace context"** is checked.
5. **Bump font sizes for the room**: `Ctrl+Shift+P` → `Editor Font Zoom: Reset`, then `Ctrl+=` a few times until the back row can read.
6. **Pre-load the clipboard.** Run the CLI helper once so the first demo's prompt is already on your clipboard if Copilot Chat freezes:
   ```powershell
   $env:Path = "C:\Program Files\Git\cmd;" + $env:Path
   cd C:\Users\WASHINGTON-DCYFU04\Documents\AI_Projects\cw-legacy-codeagent
   ./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL
   ```
7. **Verify the deck artifact** exists and opens:
   ```powershell
   Get-Item .\docs\pitch-deck.pptx
   ```
8. **Stopwatch / timer** visible to you only (phone face-down on the lectern works).
9. **Drink water.** Take three slow breaths. You've got this.

> Need to regenerate the deck after edits? Run:
> ```powershell
> ./scripts/build-pitch-deck.ps1
> ```

---

## 1. Slide 1 — Title (0:00–0:20)

**ON SCREEN:** "Legacy Knowledge Copilot — the AI that finally understands your COBOL, your Struts 1, and your retiring SMEs."

**DO:**
- Don't read the title. Look at the room.
- Click forward only when you've finished your opening line.

**SAY (≈20s):**
> "Hi — I'm here to show you Legacy Knowledge Copilot. In the next four minutes I'll show you how a multi-agent AI assistant turns impenetrable legacy code, plus the tribal knowledge that's about to walk out the door at retirement, into reviewable, citable, change-ready insight — without leaving VS Code. Let's go."

**PACING CUE:** at 0:20 advance.

---

## 2. Slide 2 — The Problem (0:20–0:50)

**ON SCREEN:** the legacy iceberg bullets (220B lines of COBOL, retiring SMEs, etc.)

**DO:** keep eye contact with the room. Point at the "$40M batch run" line.

**SAY (≈30s):**
> "Every enterprise here is sitting on a generational cliff. Over **220 billion lines of COBOL** still run the world's payments and benefits systems. Most large enterprises still depend on a Struts 1.x app past end-of-life. And the people who actually understand those systems are retiring faster than we can replace them. Documentation is missing or wrong. And because legacy stacks are tightly coupled, **a five-line patch can break the overnight batch and trigger a forty-million-dollar incident.** This is not a future problem. This is now."

**PACING CUE:** at 0:50 advance.

---

## 3. Slide 3 — Why Generic AI Falls Short (0:50–1:15)

**ON SCREEN:** "GitHub Copilot was trained on GitHub. GitHub doesn't have your COBOL."

**DO:** pause after "auditable." Let it land.

**SAY (≈25s):**
> "The natural first reaction is — *just use Copilot*. But Copilot was trained on GitHub, and GitHub doesn't have your COBOL. It doesn't have the tribal Slack thread from 2014 explaining why a certain status code means 'do not post.' Generic AI gives you a confident, plausible answer. In regulated industries, plausible is not approvable. We need **auditable**."

**PACING CUE:** at 1:15 advance.

---

## 4. Slide 4 — The Solution (1:15–1:40)

**ON SCREEN:** five-bullet pitch (reads, grounds, reviews, plans, cites).

**DO:** quick five-finger count as you hit each verb — reads, grounds, reviews, plans, cites.

**SAY (≈25s):**
> "So we built Legacy Knowledge Copilot. It **reads** the legacy stacks Copilot wasn't trained on. It **grounds** every answer in a curated knowledge base. It **reviews** code with a legacy-aware risk lens — it knows the difference between bad code and load-bearing code. It **plans** modernization safely. And — this is the important part — every single claim is **cited**, and every answer has a confidence label. Auditable."

**PACING CUE:** at 1:40 advance.

---

## 5. Slide 5 — How It Works (1:40–2:10)

**ON SCREEN:** three agents + eight skills + knowledge base.

**DO:** point at each agent name on screen as you say it.

**SAY (≈30s):**
> "Three specialized agents. Eight reusable skills. One curated knowledge base. **`@legacy-code`** reads and explains the source. **`@knowledge`** grounds answers in tribal docs, runbooks, and technical papers — with citations. **`@review`** does the risk-aware code review and modernization scoring. The agents compose — they call each other when context is needed — and the routing layer is published in the repo, so it's not a black box."

**PACING CUE:** at 2:10 advance.

---

## 6. Slide 6 — Architecture (2:10–2:30) — *tight-cut: skip*

**ON SCREEN:** the simple ASCII flow + "zero infra."

**DO:** if running tight on time, **skip this slide** — the message is already implicit.

**SAY (≈20s):**
> "Architecturally, this is intentionally boring. There's no new infrastructure to deploy. You install VS Code, install Copilot, clone the repo, and you're done. Following awesome-copilot conventions means every new agent, skill, or knowledge source is a drop-in file."

**PACING CUE:** at 2:30 advance to **Demo 1**.

---

## 7. Slide 7 — DEMO 1: COBOL + tribal grounding (2:30–3:15) ⭐

> **This is the money shot. If only one demo lands, it's this one.**

### Switch to VS Code

**DO:**
1. `Alt+Tab` to VS Code.
2. Click the tab for [examples/cobol/NB_POST.CBL](../examples/cobol/NB_POST.CBL).
3. Scroll to paragraph `2100-VALIDATE-INVOICE` so the `Z9` branch is visible.

**SAY (≈10s):**
> "This is a 28-year-old nightly billing batch nobody on the team has read. Watch what happens with one prompt."

### Paste the prompt

**DO:** open Copilot Chat. Paste:

```
@legacy-code Explain examples/cobol/NB_POST.CBL end-to-end.
Use prompts/explain-cobol.md as the output contract.
Pull tribal context from /knowledge/tribal for any magic status codes
('A','R','H','Z9') and for the preserved GO TO branch.
Cite every grounded claim.
```

> 💡 If Copilot has already been warmed up, just press **↑** in chat to recall this exact prompt.

### While Copilot streams (the gold)

**DO:**
- Don't be silent. Narrate.
- When the **magic-code table** appears, point at the `Z9` row.
- When the **citation link** `knowledge/tribal/nb-post-z9-special-hold.md` appears, **click it** to open the SME note in a split editor.

**SAY (≈25s while streaming):**
> "Look — it gives me a division map and a control-flow diagram. Then this table of magic codes. See that row for **`Z9`**? It didn't guess. It pulled the meaning from a tribal note an SME wrote, and **it cited the file.** [click the link] Compliance can click that link. That is the difference between AI guessing and an auditable answer."

### Close the demo

**DO:** scroll to the bottom of the Copilot response to the `Gaps` section.

**SAY (≈10s):**
> "And notice the **Gaps** section — the assistant tells me what knowledge is missing. That's the flywheel: every gap becomes a knowledge file, which grounds the next answer."

**PACING CUE:** at 3:15 advance to **Demo 2**.

---

## 8. Slide 8 — DEMO 2: Cross-layer review (3:15–3:55) ⭐

### Switch tabs

**DO:**
1. Click the [ApproveClaimAction.java](../examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java) tab.
2. Briefly highlight the `unsafeSql` string-concat block so the SQL injection is visible.

**SAY (≈10s):**
> "Same assistant, different agent. Here's the Struts 1 path when a user clicks 'Approve.' It also kicks off a stored procedure that feeds the COBOL batch we just explained."

### Paste the prompt

**DO:** paste into Copilot Chat:

```
@review Review examples/struts/.../ApproveClaimAction.java and the SP
it calls, examples/sql/usp_PostClaimApproval.sql.
Use prompts/review-legacy-code.md.
Lenses: security, correctness, backward-compat with the overnight
NB_POST_NIGHTLY batch. Honor any do-not-touch entries in /knowledge.
```

> 💡 If you need to save 10 seconds, swap the prompt for the CLI-generated one:
> ```powershell
> ./scripts/run-analysis.ps1 `
>     -Path examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java `
>     -Mode review
> ```
> The prompt lands on your clipboard. Then paste into Copilot Chat.

### While Copilot streams

**DO:**
- Read out the severity badges as they appear: "blocker… blocker… major."
- When the **Do-Not-Touch Violations** section says "none — Z9 invariant respected," point at it.

**SAY (≈30s while streaming):**
> "Look at the severity ladder — **blocker, blocker, major.** It caught the SQL injection. It caught the hard-coded credentials. It caught the missing transaction boundary. But here's the killer feature — see this line? **It tells me — explicitly — that it did *not* recommend any change that would violate the `Z9` invariant we saw in the first demo.** Because it consulted `/knowledge/do-not-touch`. That's a veto rule baked into the orchestration. The agent literally cannot recommend something the SMEs said is off-limits."

**PACING CUE:** at 3:55 advance to **Demo 3**.

---

## 9. Slide 9 — DEMO 3 + Differentiators (3:55–4:25) — *tight-cut: skip the live demo, just show the slide*

### Switch tabs (only if time permits)

**DO:** click [examples/sql/schema.sql](../examples/sql/schema.sql).

**SAY (≈15s):**
> "One more — non-normalized SQL Server schema. Wide tables, no foreign keys, magic codes, bitfields in a `CHAR` column. Classic. One prompt."

**PROMPT (only if live):**
```
@legacy-code Analyze examples/sql/schema.sql.
Use prompts/analyze-sql-schema.md. Focus on BILLING.CLAIM: column
dictionary, implicit FKs, overloaded ROUTING_FLAGS, and ranked
normalization opportunities that honor /knowledge/do-not-touch.
```

**SAY (≈15s — read this even if you skipped the live run):**
> "In twenty seconds I get a column dictionary, foreign keys the assistant **inferred** from join evidence even though the DBA never declared them, the bitfield decoded, and a ranked normalization roadmap. So what's different? **Built for legacy. Cited, not invented. Veto rules. Composable. Zero infrastructure** — you can ship this today."

**PACING CUE:** at 4:25 advance.

---

## 10. Slide 10 — Impact (4:25–4:55) — *tight-cut: 15s version*

**ON SCREEN:** before/after table.

**SAY (≈30s — full):**
> "What does this unlock? **Onboarding to a legacy module in minutes instead of weeks.** **Catching blast-radius issues at PR time instead of at two AM in production.** Turning one retiring SME's notebook into a queryable knowledge graph the whole team can use. And making modernization a roadmap of small, safe steps — instead of a rewrite that fails. That's the prize."

**SAY (≈15s — tight cut):**
> "Onboard in minutes. Catch risk at PR time. Turn one notebook into a team-wide knowledge graph. Make modernization a roadmap, not a rewrite."

**PACING CUE:** at 4:55 advance.

---

## 11. Slide 11 — Roadmap + Close (4:55–5:20)

**ON SCREEN:** 30 / 90 / Beyond roadmap and the closing tagline.

**DO:**
- Slow down on the last sentence. Look at the room.
- Hold the slide while you say "Thank you."
- Don't ask if there are questions until you've finished the line.

**SAY (≈25s):**
> "In **30 days** we ship the knowledge ingestor — drop a PDF in, get a headered markdown file out. In **90**, we wire in static analyzers and a characterization-test generator. **Beyond that**, mainframe and ETL stacks, a GitHub Actions PR reviewer, and voice-mode SME capture. To close: **legacy isn't bad code, it's load-bearing code. We make it readable, reviewable, and ready for the next twenty years.** Repo's open. Thank you."

---

## 12. Q&A — Backup demos (post-pitch)

Keep these ready. They make the assistant feel deeper than the four minutes showed.

### "What if the knowledge isn't there yet?"
**Run:**
```
@knowledge What does CUST_FLAGS bit 3 mean?
```
**Point at:** `Confidence: inferred` and the `Gaps` list showing the missing file path. That *is* the answer — the assistant tells you what to write.

### "Can it scope a real migration?"
**Run:**
```
@review Score modernization opportunities for the Approve Claim flow.
Suggest a strangler-fig boundary toward Spring Boot. Output: value
(1-5), blast radius (1-5), effort (1-5), recommended sequencing.
```

### "How do the agents decide who handles what?"
**Open:** [docs/agent-routing.md](./agent-routing.md) and scroll to the routing flowchart and the file-type table.

### "Can a developer run it from the command line?"
**Run:**
```powershell
./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL
```
The CLI detects the file kind, picks the agent and prompt template, discovers `/knowledge` candidates, and copies a Copilot-ready prompt to the clipboard. Hand the lead engineer a one-liner instead of a presentation.

### "What happens if `/knowledge` is wrong?"
The `KnowledgeAgent` will flag the contradiction and ask for SME reconciliation. It never silently picks a side. *Show this if you have time:* run a `@knowledge` prompt and call out the `partial` confidence label.

### "How is this different from generic Copilot?"
> "Three things. **Grounding** — every claim cites a file in `/knowledge`. **Vetoes** — `do-not-touch` invariants are enforced by the `ReviewAgent`. **Composition** — agents call each other through documented contracts, so I can swap or add an agent without rewiring the rest."

---

## 13. If something goes wrong

| Failure | Fallback line | Action |
|---------|---------------|--------|
| Copilot hangs / slow stream | *"While that streams, here's what you're about to see..."* | Read aloud the **expected output** sections from this file. |
| Copilot returns wrong agent / off-topic | *"Let me be explicit about the agent..."* | Re-prompt prefixed with `[ReviewAgent]` or `[LegacyCodeAgent]`. |
| Network drops mid-pitch | *"Let me show you the wiring instead of the live model."* | Switch to [docs/agent-routing.md](./agent-routing.md) and walk the mermaid diagrams. Same story, no live model. |
| Wrong file open | *"Stick with me one second..."* | `Ctrl+P` and type `NB_POST` / `ApproveClaim` / `schema` — VS Code Quick Open is your friend. |
| Forgot the prompt | (no excuse needed) | Run `./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL` — it generates the prompt and puts it on your clipboard in one command. |
| Pitch running long | (don't apologize) | Skip Slide 6 and the live run on Slide 9. Keep Demo 1 and Demo 2 intact at all costs. |

---

## 14. Cheat-sheet one-liners (memorize these — use them anywhere)

- *"Citations turn AI answers into auditable answers."*
- *"Tribal knowledge becomes an asset, not a retirement risk."*
- *"Legacy isn't bad code — it's load-bearing code."*
- *"Three agents, one workflow, zero hallucinations on the things that matter."*
- *"Onboarding to a 28-year-old batch in 90 seconds."*

---

## 15. Pacing card (print and tape to the lectern)

| Time | Slide | Cue |
|-----:|-------|-----|
| 0:00 | 1 Title | "In the next four minutes…" |
| 0:20 | 2 Problem | "$40M batch run." |
| 0:50 | 3 Generic AI | "Plausible is not approvable." |
| 1:15 | 4 Solution | "Reads / grounds / reviews / plans / cites." |
| 1:40 | 5 How it works | Point at each agent. |
| 2:10 | 6 Architecture | *(skip if tight)* |
| 2:30 | **7 Demo 1** | `Alt+Tab` to VS Code. Paste prompt. |
| 3:15 | **8 Demo 2** | Re-prompt with `@review`. |
| 3:55 | 9 Demo 3 + Differentiators | Show schema OR just narrate. |
| 4:25 | 10 Impact | Before/after. |
| 4:55 | 11 Roadmap + close | "Load-bearing code." Thank you. |

---

## 16. Scripts you may invoke live (full reference)

```powershell
# Add Git to PATH for the session (if 'git' isn't found)
$env:Path = "C:\Program Files\Git\cmd;" + $env:Path

# Always work from the repo
cd C:\Users\WASHINGTON-DCYFU04\Documents\AI_Projects\cw-legacy-codeagent

# (1) Generate a Copilot prompt for ANY legacy file - copies to clipboard
./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL
./scripts/run-analysis.ps1 -Path examples/sql/schema.sql -Mode schema
./scripts/run-analysis.ps1 `
    -Path examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java `
    -Mode review `
    -Question "Focus on backward-compat with NB_POST_NIGHTLY."

# (2) Regenerate the deck after edits (requires PowerPoint / Microsoft 365)
./scripts/build-pitch-deck.ps1
# Output: docs/pitch-deck.pptx
```

> Pro move: in pre-flight, run `./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL` once. The Demo 1 prompt is now on your clipboard — `Ctrl+V` in Copilot Chat the moment you switch to VS Code. You'll look unreasonably smooth.
