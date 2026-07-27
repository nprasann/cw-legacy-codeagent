# Speaker Notes - WA State AI Code Camp Story Script

## Slide 1 - Legacy Knowledge Copilot

Good morning. I want to start with a situation that will feel familiar to a lot of public-sector technology teams.

You open a system that has been quietly doing important work for years. Maybe it supports claims, benefits, licensing, payments, or nightly reporting. It still runs. People depend on it. But the original developers are gone, the documentation is uneven, and the business rules are scattered across code, runbooks, and memory.

This project is called Legacy Knowledge Copilot. It is a GitHub Copilot-based assistant for understanding those systems before we change them. The repo is available at https://github.com/nprasann/cw-legacy-codeagent, and this project will be added to the Awesome GitHub Copilot Project list at https://awesome-copilot.github.com.

## Slide 2 - The Problem

The problem is not simply that legacy code is old. The problem is that legacy systems often carry public services, and the knowledge around those systems is fragile.

A new developer may be able to read modern JavaScript or Python all day, but then they run into COBOL, JCL, Struts 1, or a stored procedure with business rules embedded in column names and status codes. At that point, the real question becomes: who knows what this does, and how confident are we before we touch it?

That creates pressure on senior staff and subject-matter experts. They become the path for every explanation, every review, every modernization decision. The project is designed to reduce that pressure without pretending AI replaces their judgment.

## Slide 3 - Why Generic AI Is Not Enough

Generic AI can explain code. Sometimes it explains code very well. But in this setting, sounding confident is not enough.

If an assistant says, "this status code probably means hold," I need to know whether that came from a source, from the code, or from a guess. If we are changing a system that affects real services, we need answers that can be reviewed.

So this project focuses on grounded answers. When the assistant knows something from a knowledge file, it cites it. When it is missing evidence, it says that. When it is inferring, it labels the answer as inferred instead of dressing it up as fact.

## Slide 4 - The Solution

Legacy Knowledge Copilot uses three focused agents.

The first agent reads the legacy source. It explains COBOL, JCL, Struts, JSPs, SQL Server schemas, and stored procedures in language a modern developer can follow.

The second agent grounds the answer in the repository's knowledge base. That can include tribal notes, runbooks, technical papers, and do-not-touch rules.

The third agent reviews risk. It looks for security issues, correctness issues, and blast radius. Most importantly, it treats legacy code as load-bearing code. It does not assume the cleanest rewrite is the safest next step.

## Slide 5 - Architecture

The architecture is intentionally simple.

A developer works in VS Code with GitHub Copilot Chat. The repo contains agent instructions, reusable skills, example legacy systems, and a knowledge folder. The assistant uses those files as its operating model.

That matters because the improvement process is familiar. If a team learns a new business rule, it can add a knowledge file. If a prompt needs to be clearer, it can be reviewed like code. If a do-not-touch invariant matters, it can live in the repository instead of in one person's memory.

## Slide 6 - Demo 1

The first demo starts with a COBOL nightly posting program.

I ask the assistant to explain the program end to end and pull tribal context for magic status codes like A, R, H, and Z9.

The key moment is Z9. The assistant should not invent what that means. It should find the tribal knowledge note in the repo, cite it, and tell us how confident it is.

That is the difference between "AI gave me an answer" and "AI gave me an answer I can inspect." The citation lets a reviewer click through and see the source.

## Slide 7 - Demo 2

The second demo moves from explanation to risk.

Here, the assistant reviews a Struts action and the stored procedure it calls. That path matters because a web action can affect database state, and database state can affect a nightly batch downstream.

The assistant flags security and correctness concerns, but the more interesting part is that it checks documented invariants. It is not just saying, "Here is cleaner code." It is asking, "What behavior do we need to preserve?"

That is the kind of help modernization teams need.

## Slide 8 - Demo 3

The third demo looks at a non-normalized SQL Server schema.

This is where many teams get stuck. The schema may not declare every relationship. A field may carry multiple meanings. A status flag may hide business routing logic.

The assistant turns that into a map: a column dictionary, inferred relationships, overloaded fields, and a modernization plan ranked by value and blast radius.

The goal is not to rewrite everything. The goal is to sequence safer improvements.

## Slide 9 - Why This Fits Washington State

For Washington State teams, the value is not novelty. The value is service continuity and workforce empowerment.

Responsible AI should help employees do careful work faster. It should help new staff learn systems safely. It should preserve institutional knowledge. And it should make answers reviewable instead of mysterious.

That is why this project is framed around citations, confidence, and gaps. Those are not extra features. They are the trust layer.

## Slide 10 - Repository Pattern

One thing I like about this project is that it does not require a new platform to understand the pattern.

The repo itself is the pattern. Agents live in `.github/copilot`. Knowledge lives in `knowledge`. Demo assets live in `examples`. Presentation and usage materials live in `docs`.

That means the project can grow through normal GitHub practices. Teams can add knowledge, review prompt changes, and improve demo workflows over time.

## Slide 11 - Roadmap

The next step is ingestion and automation.

Today, knowledge files are curated by hand. That is a good starting point because it keeps the sources intentional. Over time, the project could ingest reviewed PDFs, Word documents, or runbooks and turn them into structured knowledge files.

From there, static analyzers could map dependencies, characterization tests could protect behavior, and GitHub Actions could bring this review model into pull requests.

## Slide 12 - Close

The closing idea is simple: legacy is not bad code. It is load-bearing code.

In public service, those systems often exist because they still do important work. We should modernize them, but we should do it with care.

Legacy Knowledge Copilot helps teams read the system, preserve what experts know, cite the evidence, and choose safer next steps.

That is the story: not AI replacing expertise, but AI helping us keep expertise alive long enough for the next team to use it well.
