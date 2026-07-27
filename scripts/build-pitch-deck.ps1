<#
.SYNOPSIS
    Build docs/pitch-deck.pptx from the structured Legacy Knowledge Copilot
    pitch deck. Uses PowerPoint COM automation (Microsoft 365 / Office).

.DESCRIPTION
    This script does NOT parse markdown. It contains the slide content
    inline as PowerShell data so the resulting deck is deterministic,
    well-typed, and survives future edits to docs/pitch-deck.md.

    Each slide has a title, bullet body, and presenter notes that are
    placed in the Notes pane.

.PARAMETER OutPath
    Output .pptx path. Default: docs/pitch-deck.pptx

.PARAMETER ShowApp
    Make the PowerPoint window visible while building (default: hidden).

.EXAMPLE
    ./scripts/build-pitch-deck.ps1

.EXAMPLE
    ./scripts/build-pitch-deck.ps1 -OutPath docs/pitch-deck.pptx -ShowApp
#>

[CmdletBinding()]
param(
    [string] $OutPath,
    [switch] $ShowApp
)

$ErrorActionPreference = 'Stop'

# Resolve script + output paths defensively (PSScriptRoot can be empty in some hosts)
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $OutPath) { $OutPath = Join-Path $ScriptDir '..\docs\pitch-deck.pptx' }

Add-Type -AssemblyName Microsoft.Office.Interop.PowerPoint -ErrorAction SilentlyContinue | Out-Null

$OutPath = [System.IO.Path]::GetFullPath($OutPath)
New-Item -ItemType Directory -Force -Path (Split-Path $OutPath -Parent) | Out-Null
if (Test-Path -LiteralPath $OutPath) { Remove-Item -LiteralPath $OutPath -Force }

# PowerPoint enums (avoid namespace dependency)
$ppLayoutTitle           = 1
$ppLayoutText            = 2   # Title + content
$msoFalse                = 0
$msoTrue                 = -1
$ppSaveAsOpenXMLPresentation = 24

# ---------------------------------------------------------------------------
# Slide content (mirrors docs/pitch-deck.md, condensed for slide form)
# ---------------------------------------------------------------------------
$slides = @(
    @{
        Layout = $ppLayoutTitle
        Title  = 'Legacy Knowledge Copilot'
        Body   = @(
            'The AI that finally understands your COBOL, your Struts 1, and your retiring SMEs.',
            '',
            'A multi-agent GitHub Copilot assistant for legacy enterprise systems.',
            'Built on github/awesome-copilot conventions. Runs in VS Code.',
            '100% grounded. 0% hallucinated.'
        )
        Notes  = "Hi, I'm here to show you Legacy Knowledge Copilot. In the next four minutes I'll show you how a multi-agent AI assistant turns impenetrable legacy code, plus the tribal knowledge that's about to walk out the door at retirement, into reviewable, citable, change-ready insight - without leaving VS Code. Let's go."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'The Problem: The Legacy Iceberg'
        Body   = @(
            '220+ billion lines of COBOL still run payments, claims, benefits, tax.',
            'Tens of thousands of Struts 1.x apps past end-of-life.',
            'Median COBOL engineer is 55+. SMEs retire faster than they are replaced.',
            'Documentation is missing, stale, or contradictory.',
            'A 5-line change can blow up a $40M nightly batch run.'
        )
        Notes  = "Every enterprise here is sitting on a generational cliff. Over 220 billion lines of COBOL still run the world's payments and benefits systems. Most large enterprises still depend on a Struts 1.x app past end-of-life. And the people who understand those systems are retiring faster than we can replace them. Documentation is missing or wrong. And because legacy stacks are tightly coupled, a five-line patch can break the overnight batch and trigger a forty-million-dollar incident. This is not a future problem. This is now."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'Why Generic AI Falls Short'
        Body   = @(
            'GitHub Copilot was trained on GitHub. GitHub does not have your COBOL.',
            'It does not have your tribal Slack threads, retired-SME interviews, or "do not touch" invariants.',
            'Generic AI invents plausible answers. Compliance cannot approve "plausible."',
            'Legacy work needs auditable answers, not autocomplete.'
        )
        Notes  = "The natural first reaction is: just use Copilot. But Copilot was trained on GitHub - and GitHub does not have your COBOL. It does not have the tribal Slack thread from 2014 explaining why a certain status code means 'do not post.' Generic AI gives you a confident, plausible answer. In regulated industries, plausible is not approvable. We need auditable."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'The Solution'
        Body   = @(
            'Reads COBOL, JCL, Struts 1, JSPs, non-normalized SQL Server, T-SQL stored procs.',
            'Grounds every answer in curated tribal docs, technical papers, runbooks.',
            'Reviews legacy code with a risk lens - distinguishes "bad code" from "load-bearing code."',
            'Plans modernization incrementally - strangler-fig, characterization tests, phased rollout.',
            'Cites every grounded claim and labels confidence: grounded | partial | inferred.'
        )
        Notes  = "So we built Legacy Knowledge Copilot. It reads the legacy stacks Copilot was not trained on. It grounds every answer in a curated knowledge base. It reviews code with a legacy-aware risk lens - it knows the difference between bad code and load-bearing code. It plans modernization safely. And every single claim is cited, and every answer has a confidence label. Auditable."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'How It Works: 3 Agents, 8 Skills, 1 Knowledge Base'
        Body   = @(
            '@legacy-code  -  reads and explains legacy source',
            '@knowledge    -  grounds answers in /knowledge with citations',
            '@review       -  legacy-aware code review + modernization scoring',
            '',
            'Skills: COBOL flow, Struts 1 lifecycle, batch job analysis, SQL schema analysis,',
            '        code review, knowledge grounding, modernization, legacy code explanation.',
            'Knowledge: tribal / technical-papers / runbooks / do-not-touch.'
        )
        Notes  = "Three specialized agents. Eight reusable skills. One curated knowledge base. @legacy-code reads and explains the source. @knowledge grounds answers in tribal docs, runbooks, and technical papers - with citations. @review does the risk-aware code review and modernization scoring. The agents compose - they call each other when context is needed - and there is a deterministic routing layer published in the repo so it is not a black box."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'Architecture: Multi-agent, Grounded, in VS Code'
        Body   = @(
            'Developer in VS Code -> Copilot Chat -> Agent Router',
            '                  -> @legacy-code | @knowledge | @review',
            '                  -> Skills -> /knowledge (tribal | runbooks | papers | do-not-touch)',
            '',
            'Zero infrastructure. Just VS Code + Copilot Chat.',
            'Awesome-copilot conventions. Extensible by drop-in.'
        )
        Notes  = "Architecturally, this is intentionally boring. There is no new infrastructure to deploy. You install VS Code, install Copilot, clone the repo, and you are done. Following awesome-copilot conventions means every new agent, skill, or knowledge source is a drop-in file."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'Demo 1: Explain a 28-Year-Old COBOL Batch - Grounded'
        Body   = @(
            'Open: examples/cobol/NB_POST.CBL',
            '',
            'Prompt:',
            '@legacy-code Explain examples/cobol/NB_POST.CBL end-to-end.',
            'Pull tribal context for magic status codes (A,R,H,Z9). Cite every grounded claim.',
            '',
            'Watch for: division map, control-flow diagram,',
            'magic-code table where Z9 is CITED to knowledge/tribal,',
            'and a Gaps section listing what is still missing.'
        )
        Notes  = "Live demo. This is a 28-year-old nightly billing batch nobody on the team has read. I paste one prompt. Watch - it gives me a division map, a control-flow diagram, and a table of magic codes. See that row for Z9? It did not guess. It pulled the meaning from a tribal note an SME wrote, and it cited the file. Compliance can click that link. That is the difference between AI guessing and an auditable answer. And notice the 'Gaps' section at the bottom - the assistant tells me what knowledge is missing. That is a flywheel: every gap becomes a knowledge file, which grounds the next answer."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'Demo 2: Catch a Cross-Layer Risk Before It Ships'
        Body   = @(
            'Open: examples/struts/.../ApproveClaimAction.java',
            '',
            'Prompt:',
            '@review Review this Action and the stored procedure it calls.',
            'Lenses: security, correctness, backward-compat with NB_POST_NIGHTLY.',
            'Honor /knowledge/do-not-touch.',
            '',
            'Findings:',
            '[blocker] [security] SQL injection',
            '[blocker] [security] Hard-coded credentials',
            '[major]   [correctness] No transaction boundary',
            'Did NOT violate the Z9 invariant - checked /knowledge.'
        )
        Notes  = "Same assistant, different agent. I switch to @review and ask it to review the Struts Action that talks to the database. Look at the severity ladder - blocker, major. It catches the SQL injection. It catches the hard-coded credentials. But more importantly, it tells me - explicitly - that it did not recommend any change that would violate the Z9 invariant we saw in the first demo. Because it consulted /knowledge/do-not-touch. That is a veto rule baked into the orchestration. The agent literally cannot recommend something the SMEs said is off-limits."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'Demo 3 + Why We Win'
        Body   = @(
            'Prompt: @legacy-code Analyze examples/sql/schema.sql ...',
            'Output: column dictionary, inferred foreign keys, decoded ROUTING_FLAGS bitfield,',
            'and a value-vs-blast-radius normalization roadmap.',
            '',
            'Why we are different:',
            'Built for legacy - not a generic "explain my code" tool.',
            'Cited, not invented - every claim links back to /knowledge.',
            'Veto rules - do-not-touch invariants are honored.',
            'Composable - new stacks (DB2, CICS, SSIS) = folder + skill.',
            'Zero infra - VS Code + Copilot. Ship today.'
        )
        Notes  = "One more demo - I throw a non-normalized SQL Server schema at it. In twenty seconds I get a column dictionary, foreign keys it inferred from join evidence even though the DBA never declared them, the bitfield decoded, and a ranked normalization roadmap. So what is different? We are built for legacy. We cite instead of invent. We honor do-not-touch invariants. We are composable. And there is zero infrastructure - you can ship this today."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'Real-World Impact'
        Body   = @(
            'Onboard to a legacy module in minutes - not weeks.',
            'Catch blast-radius issues at PR time - not at 2 AM in production.',
            'Turn one SME notebook into a queryable knowledge graph.',
            'Make modernization a roadmap - not a rewrite.',
            '',
            'Before:  Senior SME bottleneck, doc rot, "do not touch", failed rewrites.',
            'After:   Self-serve grounded answers, knowledge promoted on every Gap,',
            '         cited explanations, risk-scored changes, strangler-fig plans that ship.'
        )
        Notes  = "What does this unlock? Onboarding to a legacy module in minutes instead of weeks. Catching blast-radius issues at PR time instead of at two AM in production. Turning one retiring SME's notebook into a queryable knowledge graph the whole team can use. And making modernization a roadmap of small, safe steps - instead of a rewrite that fails. That is the prize."
    },
    @{
        Layout = $ppLayoutText
        Title  = 'Roadmap and Close'
        Body   = @(
            '30 days  -  KnowledgeIngestor skill (PDF / Confluence / Word -> headered markdown).',
            '90 days  -  Static analyzers (Struts graph, COBOL PERFORM/CALL, T-SQL deps);',
            '            characterization-test generator; one-click modernization briefs.',
            'Beyond   -  MainframeAgent (VSAM/DB2/IMS/CICS), DataAgent (SSIS/DataStage/Informatica),',
            '            GitHub Actions PR reviewer, VS Code extension, voice-mode SME capture.',
            '',
            'Legacy is not bad code. It is load-bearing code.',
            'We make it readable, reviewable, and ready for the next 20 years.',
            '',
            'github.com/washington-dcyf-u04_clabs/cw-legacy-codeagent'
        )
        Notes  = "In thirty days we ship the knowledge ingestor - drop a PDF in, get a headered markdown file out. In ninety, we wire in static analyzers and a characterization-test generator. Beyond that, mainframe and ETL stacks, a GitHub Actions PR reviewer, and voice-mode SME capture. To close: legacy is not bad code, it is load-bearing code. We make it readable, reviewable, and ready for the next twenty years. Repo is open. Thank you."
    }
)

# ---------------------------------------------------------------------------
# Build the deck
# ---------------------------------------------------------------------------
Write-Host "Launching PowerPoint..." -ForegroundColor Cyan
$ppApp = New-Object -ComObject PowerPoint.Application
if ($ShowApp) { $ppApp.Visible = $msoTrue } else { try { $ppApp.Visible = $msoTrue } catch {} }  # PPT often refuses fully hidden; tolerate

try {
    # Create a new blank presentation (16:9)
    $deck = $ppApp.Presentations.Add($msoTrue)
    $deck.PageSetup.SlideSize = 15  # ppSlideSizeOnScreen16x9

    for ($i = 0; $i -lt $slides.Count; $i++) {
        $s = $slides[$i]
        $slide = $deck.Slides.Add($i + 1, $s.Layout)

        # Title
        if ($slide.Shapes.HasTitle) {
            $slide.Shapes.Title.TextFrame.TextRange.Text = $s.Title
            $slide.Shapes.Title.TextFrame.TextRange.Font.Bold = $msoTrue
            $slide.Shapes.Title.TextFrame.TextRange.Font.Size = 32
        }

        # Body (placeholder index 2 on Title+Content layouts)
        if ($s.Layout -ne $ppLayoutTitle) {
            $body = $null
            foreach ($shape in $slide.Shapes) {
                if ($shape.HasTextFrame -and $shape.Name -notlike '*Title*') {
                    $body = $shape; break
                }
            }
            if ($null -ne $body) {
                $tf = $body.TextFrame
                $tr = $tf.TextRange
                $tr.Text = ($s.Body -join "`r")
                $tr.Font.Size = 18
                $tr.ParagraphFormat.Bullet.Visible = $msoFalse
            }
        } else {
            # Title-slide subtitle: second placeholder
            $sub = $null
            foreach ($shape in $slide.Shapes) {
                if ($shape.HasTextFrame -and $shape.Name -notlike '*Title*') {
                    $sub = $shape; break
                }
            }
            if ($null -ne $sub) {
                $sub.TextFrame.TextRange.Text = ($s.Body -join "`r")
                $sub.TextFrame.TextRange.Font.Size = 18
            }
        }

        # Speaker notes
        if ($slide.HasNotesPage -and $s.Notes) {
            $notesShape = $slide.NotesPage.Shapes.Placeholders.Item(2)
            $notesShape.TextFrame.TextRange.Text = $s.Notes
            $notesShape.TextFrame.TextRange.Font.Size = 14
        }

        Write-Host (" + slide {0,2} : {1}" -f ($i + 1), $s.Title) -ForegroundColor DarkGreen
    }

    # Save as .pptx
    Write-Host "Saving -> $OutPath" -ForegroundColor Cyan
    $deck.SaveAs($OutPath, $ppSaveAsOpenXMLPresentation)
    $deck.Close()
    Write-Host "Done." -ForegroundColor Green
}
finally {
    try { $ppApp.Quit() } catch { Start-Sleep -Milliseconds 500; try { $ppApp.Quit() } catch {} }
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppApp) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
