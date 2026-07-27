# Prompt Templates

Copy-paste ready prompt templates for the **cw-legacy-codeagent** assistant
in GitHub Copilot Chat (VS Code).

Each template:

- Names the agent (`@legacy-code`, `@knowledge`, `@review`) it expects.
- Tells the assistant where to look in [`/knowledge`](../knowledge/) for grounding.
- Locks the response to a structured output contract so answers are reviewable.
- Requires confidence labels (`grounded | partial | inferred`) and an explicit
  gaps list when sources are missing.

## Index

| Template | Use case |
|----------|----------|
| [explain-cobol.md](./explain-cobol.md)           | Explain a COBOL program end-to-end. |
| [analyze-batch.md](./analyze-batch.md)           | Analyze an offline batch job (JCL + COBOL + SPs). |
| [explain-struts.md](./explain-struts.md)         | Trace a Struts 1 request lifecycle. |
| [review-legacy-code.md](./review-legacy-code.md) | Legacy-aware code review for a diff, file, or module. |
| [analyze-sql-schema.md](./analyze-sql-schema.md) | Analyze a non-normalized MS SQL Server schema. |

## How to use

1. Open the template, copy its content.
2. Replace the `<placeholders>` with concrete file paths / job names / scope.
3. Paste into Copilot Chat with the relevant files attached or workspace
   context enabled.
4. If `@handles` aren't honored in your environment, prefix the prompt with
   `[LegacyCodeAgent]`, `[KnowledgeAgent]`, or `[ReviewAgent]`.

## Conventions

- Anything cited from `/knowledge` MUST be linked as
  `[knowledge/<folder>/<file>.md#<anchor>]`.
- Every answer ends with **Confidence** and **Gaps** sections.
- Templates default to **preserve observable behavior** — change-of-behavior
  refactors must be explicitly requested.
