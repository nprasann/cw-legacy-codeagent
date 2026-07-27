# scripts/

Developer-facing CLI helpers that pair with the
**cw-legacy-codeagent** Copilot assistant.

## Inventory

| Script | Purpose | Quick start |
|--------|---------|-------------|
| [run-analysis.ps1](./run-analysis.ps1) | Inspects a legacy file, infers the right agent + prompt template, and prints a copy-paste ready Copilot Chat prompt. Acts as a CLI "router" for the assistant. | `./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL` |
| [build-pitch-deck.ps1](./build-pitch-deck.ps1) | Generates [docs/pitch-deck.pptx](../docs/pitch-deck.pptx) from the structured Legacy Knowledge Copilot pitch. 11 slides + presenter notes. Requires PowerPoint (Microsoft 365 / Office). | `./scripts/build-pitch-deck.ps1` |

> The scripts intentionally do **not** call any model. They guide the
> developer to the right Copilot prompt and assemble grounding context.
> Keeps the assistant deterministic and reviewable.

## Conventions

- Windows PowerShell 5.1 and PowerShell 7+ compatible.
- No external module dependencies.
- Scripts emit to STDOUT only; copy / pipe as needed.
- All paths in output are repo-relative.
