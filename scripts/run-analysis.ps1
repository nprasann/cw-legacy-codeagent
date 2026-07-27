<#
.SYNOPSIS
    Legacy Code AI Assistant - analysis launcher.

.DESCRIPTION
    Inspects a legacy source file (COBOL, JCL, copybook, Struts 1
    Action/Form/config, JSP, T-SQL DDL/stored proc), determines which
    agent and prompt template to use, discovers relevant /knowledge
    grounding sources, and prints a copy-paste ready Copilot Chat prompt.

    This script does NOT call any model. It is a CLI router that turns
    "what do I do with this file?" into "paste this into Copilot Chat".

.PARAMETER Path
    Path to the legacy source file you want analyzed.
    Repo-relative or absolute.

.PARAMETER Mode
    Force a specific analysis mode. Optional. One of:
      explain  - LegacyCodeAgent walkthrough          (default for code files)
      review   - ReviewAgent risk + modernization     (default for diffs)
      ground   - KnowledgeAgent grounded Q&A
      batch    - Batch job analysis (JCL + COBOL + SPs)
      schema   - Non-normalized SQL Server schema analysis
      struts   - Struts 1 request lifecycle trace
      auto     - Infer from file (default)

.PARAMETER Question
    Optional free-text question to append to the generated prompt.
    Useful for narrowing scope or asking "why" alongside "what".

.PARAMETER NoCopy
    By default the script tries to copy the prompt to the clipboard
    (when Set-Clipboard is available). Use -NoCopy to suppress this.

.EXAMPLE
    ./scripts/run-analysis.ps1 -Path examples/cobol/NB_POST.CBL
    # -> picks LegacyCodeAgent + prompts/explain-cobol.md

.EXAMPLE
    ./scripts/run-analysis.ps1 -Path examples/sql/schema.sql -Mode schema
    # -> picks LegacyCodeAgent + prompts/analyze-sql-schema.md

.EXAMPLE
    ./scripts/run-analysis.ps1 `
        -Path examples/struts/src/main/java/com/example/legacy/billing/action/ApproveClaimAction.java `
        -Mode review `
        -Question "Focus on backward-compat with NB_POST_NIGHTLY."

.NOTES
    Repo: https://github.com/nprasann/cw-legacy-codeagent
    Docs: docs/usage.md, docs/agent-routing.md
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Path,

    [ValidateSet('auto','explain','review','ground','batch','schema','struts')]
    [string] $Mode = 'auto',

    [string] $Question = '',

    [switch] $NoCopy
)

# ---------------------------------------------------------------------------
# 0. Locate the repo root (the directory containing .github/copilot/)
# ---------------------------------------------------------------------------
function Get-RepoRoot {
    $here = $PSScriptRoot
    if (-not $here) { $here = (Get-Location).Path }
    $cur = Get-Item -LiteralPath $here
    while ($cur) {
        if (Test-Path (Join-Path $cur.FullName '.github/copilot')) {
            return $cur.FullName
        }
        if ($null -eq $cur.Parent) { break }
        $cur = $cur.Parent
    }
    throw "Could not locate repo root (no .github/copilot/ found above '$here')."
}

$RepoRoot = Get-RepoRoot

function To-Rel([string]$p) {
    $full = (Resolve-Path -LiteralPath $p -ErrorAction Stop).Path
    $root = (Resolve-Path -LiteralPath $RepoRoot).Path
    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return ($full.Substring($root.Length).TrimStart('\','/')).Replace('\','/')
    }
    return $full.Replace('\','/')
}

# ---------------------------------------------------------------------------
# 1. Resolve the input file and infer its kind
# ---------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $Path)) {
    Write-Error "Input file not found: $Path"
    exit 2
}

$absPath = (Resolve-Path -LiteralPath $Path).Path
$relPath = To-Rel $absPath
$ext     = [System.IO.Path]::GetExtension($absPath).ToLowerInvariant()
$base    = [System.IO.Path]::GetFileName($absPath)

# Peek at first ~80 lines for content-based detection (Struts vs generic Java, etc.)
$head = ''
try { $head = (Get-Content -LiteralPath $absPath -TotalCount 80 -ErrorAction Stop) -join "`n" }
catch { $head = '' }

function Test-Match($pattern) { return [bool]([regex]::IsMatch($head, $pattern, 'IgnoreCase')) }

$kind = 'unknown'
switch ($ext) {
    '.cbl'  { $kind = 'cobol' }
    '.cob'  { $kind = 'cobol' }
    '.cpy'  { $kind = 'copybook' }
    '.jcl'  { $kind = 'jcl' }
    '.sql'  {
        if (Test-Match 'CREATE\s+(PROCEDURE|TRIGGER|FUNCTION)|\bAS\s+BEGIN\b|\bDECLARE\s+\w+\s+CURSOR\b') {
            $kind = 'tsql-proc'
        } else {
            $kind = 'tsql-schema'
        }
    }
    '.java' {
        if (Test-Match 'org\.apache\.struts\.action\.Action(?:Form|Mapping|Servlet|Forward)?') {
            $kind = 'struts-action'
        } else { $kind = 'java' }
    }
    '.xml'  {
        if ($base -ieq 'struts-config.xml')   { $kind = 'struts-config' }
        elseif ($base -ieq 'validation.xml')  { $kind = 'struts-validation' }
        elseif ($base -ieq 'web.xml')         { $kind = 'web-xml' }
        else                                  { $kind = 'xml' }
    }
    '.jsp'  { $kind = 'jsp' }
    '.diff' { $kind = 'diff' }
    '.patch'{ $kind = 'diff' }
    default { $kind = 'unknown' }
}

# ---------------------------------------------------------------------------
# 2. Infer the analysis mode (agent + prompt template) from kind, unless forced
# ---------------------------------------------------------------------------
function Resolve-Mode {
    param([string]$kind, [string]$forced)

    if ($forced -ne 'auto') { return $forced }

    switch ($kind) {
        'cobol'             { return 'explain' }   # promoted to 'batch' if JCL is alongside
        'copybook'          { return 'explain' }
        'jcl'               { return 'batch'   }
        'tsql-proc'         { return 'explain' }
        'tsql-schema'       { return 'schema'  }
        'struts-action'     { return 'struts'  }
        'struts-config'     { return 'struts'  }
        'struts-validation' { return 'struts'  }
        'web-xml'           { return 'struts'  }
        'jsp'               { return 'struts'  }
        'java'              { return 'explain' }
        'diff'              { return 'review'  }
        default             { return 'explain' }
    }
}

$EffectiveMode = Resolve-Mode -kind $kind -forced $Mode

# COBOL + sibling JCL? Promote to full batch analysis when in auto mode.
if ($Mode -eq 'auto' -and $kind -eq 'cobol') {
    $dir = Split-Path -Parent $absPath
    if (Get-ChildItem -LiteralPath $dir -Filter *.JCL -ErrorAction SilentlyContinue) {
        $EffectiveMode = 'batch'
    }
}

# ---------------------------------------------------------------------------
# 3. Pick the agent handle, prompt template, and headline
# ---------------------------------------------------------------------------
$Plan = switch ($EffectiveMode) {
    'explain' { @{ Agent='@legacy-code'; Template='prompts/explain-cobol.md';      Headline='Explain legacy code'        } }
    'batch'   { @{ Agent='@legacy-code'; Template='prompts/analyze-batch.md';      Headline='Analyze offline batch job'  } }
    'struts'  { @{ Agent='@legacy-code'; Template='prompts/explain-struts.md';     Headline='Trace Struts 1 request flow'} }
    'schema'  { @{ Agent='@legacy-code'; Template='prompts/analyze-sql-schema.md'; Headline='Analyze SQL Server schema'  } }
    'review'  { @{ Agent='@review';      Template='prompts/review-legacy-code.md'; Headline='Legacy-aware code review'   } }
    'ground'  { @{ Agent='@knowledge';   Template='prompts/explain-cobol.md';      Headline='Grounded Q&A from /knowledge'} }
}

# Tweak per kind for clarity (template stays generic)
if ($EffectiveMode -eq 'explain' -and $kind -in @('tsql-proc','java')) {
    $Plan.Template = 'prompts/review-legacy-code.md'  # better starting contract
    $Plan.Headline = "Explain $kind"
}

# ---------------------------------------------------------------------------
# 4. Discover candidate grounding sources under /knowledge
# ---------------------------------------------------------------------------
function Get-KeywordsFor {
    param([string]$baseName, [string]$kind)
    $tokens = @()
    $tokens += [System.IO.Path]::GetFileNameWithoutExtension($baseName)
    $tokens += $kind
    if ($kind -like 'struts*') { $tokens += 'struts1','jsp' }
    if ($kind -like 'tsql*')   { $tokens += 'sql-server','tsql','stored-procedure' }
    if ($kind -like 'cobol' -or $kind -eq 'copybook' -or $kind -eq 'jcl') {
        $tokens += 'cobol','batch','jcl'
    }
    return $tokens | Where-Object { $_ } | Select-Object -Unique
}

function Find-KnowledgeMatches {
    param([string[]]$keywords)
    $kbRoot = Join-Path $RepoRoot 'knowledge'
    if (-not (Test-Path $kbRoot)) { return @() }
    $hits = New-Object System.Collections.Generic.List[string]
    foreach ($f in Get-ChildItem -Path $kbRoot -Recurse -Filter *.md -File -ErrorAction SilentlyContinue) {
        if ($f.Name -ieq 'README.md') { continue }
        $content = ''
        try { $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop } catch { continue }
        foreach ($kw in $keywords) {
            if ($kw -and ($f.Name -match [regex]::Escape($kw) -or $content -match [regex]::Escape($kw))) {
                $hits.Add((To-Rel $f.FullName)) | Out-Null
                break
            }
        }
    }
    return ($hits | Select-Object -Unique)
}

$keywords      = Get-KeywordsFor -baseName $base -kind $kind
$knowledgeHits = Find-KnowledgeMatches -keywords $keywords

# ---------------------------------------------------------------------------
# 5. Compose the Copilot prompt
# ---------------------------------------------------------------------------
function New-Prompt {
    param(
        [string]$agent,
        [string]$template,
        [string]$relPath,
        [string]$kind,
        [string[]]$hits,
        [string]$question
    )

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("$agent Please analyze the file below.")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('TARGET')
    [void]$sb.AppendLine("- File:        $relPath")
    [void]$sb.AppendLine("- Kind:        $kind")
    [void]$sb.AppendLine("- Contract:    $template (use these section headers)")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('GROUNDING (consult these before answering)')
    [void]$sb.AppendLine('- /knowledge/runbooks/**          operational truth')
    [void]$sb.AppendLine('- /knowledge/design-docs/**       documented intent')
    [void]$sb.AppendLine('- /knowledge/tribal/**            SME notes, magic codes')
    [void]$sb.AppendLine('- /knowledge/technical-papers/**  technology background')
    [void]$sb.AppendLine('- /knowledge/do-not-touch/**      invariants (must not violate)')
    if ($hits -and $hits.Count -gt 0) {
        [void]$sb.AppendLine('- Likely-relevant files (auto-discovered):')
        foreach ($h in $hits) { [void]$sb.AppendLine("    - $h") }
    }
    [void]$sb.AppendLine('- Cite every grounded claim as [knowledge/<folder>/<file>.md#<anchor>].')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('OUTPUT REQUIREMENTS')
    [void]$sb.AppendLine('- Follow the section headers from the contract above.')
    [void]$sb.AppendLine('- Default: preserve observable behavior; flag any behavior delta.')
    [void]$sb.AppendLine('- End with two sections: Confidence (grounded|partial|inferred) and Gaps.')
    if ($question) {
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('ADDITIONAL FOCUS')
        [void]$sb.AppendLine("- $question")
    }
    return $sb.ToString().TrimEnd()
}

$prompt = New-Prompt -agent $Plan.Agent -template $Plan.Template `
                     -relPath $relPath -kind $kind `
                     -hits $knowledgeHits -question $Question

# ---------------------------------------------------------------------------
# 6. Print the run summary + prompt
# ---------------------------------------------------------------------------
$sep = ('=' * 72)
Write-Host ''
Write-Host $sep -ForegroundColor DarkGray
Write-Host (' cw-legacy-codeagent  -  ' + $Plan.Headline) -ForegroundColor Cyan
Write-Host $sep -ForegroundColor DarkGray
Write-Host ''
Write-Host (' File      : ' + $relPath)
Write-Host (' Kind      : ' + $kind)
$modeSuffix = if ($Mode -eq 'auto') { ' (auto)' } else { ' (forced)' }
Write-Host (' Mode      : ' + $EffectiveMode + $modeSuffix)
Write-Host (' Agent     : ' + $Plan.Agent)
Write-Host (' Template  : ' + $Plan.Template)
if ($knowledgeHits.Count -gt 0) {
    Write-Host (' Knowledge : ' + $knowledgeHits.Count + ' candidate file(s)')
    foreach ($h in $knowledgeHits) { Write-Host '             - ' $h }
} else {
    Write-Host ' Knowledge : (no matches in /knowledge - answer will be partial or inferred)'
}
Write-Host ''
Write-Host ' HOW TO USE' -ForegroundColor Yellow
Write-Host '   1. Open the file in VS Code:  code ' $relPath
Write-Host '   2. Open Copilot Chat (Ctrl+Alt+I) with workspace context enabled.'
Write-Host '   3. Paste the prompt below (already on your clipboard if -NoCopy was not set).'
Write-Host '   4. Review the answer. Promote any Gaps into /knowledge per docs/grounding.md.'
Write-Host ''
Write-Host $sep -ForegroundColor DarkGray
Write-Host ' COPILOT PROMPT' -ForegroundColor Green
Write-Host $sep -ForegroundColor DarkGray
Write-Host ''
Write-Host $prompt
Write-Host ''
Write-Host $sep -ForegroundColor DarkGray

# ---------------------------------------------------------------------------
# 7. Try to copy to clipboard (best-effort)
# ---------------------------------------------------------------------------
if (-not $NoCopy) {
    try {
        if (Get-Command -Name Set-Clipboard -ErrorAction SilentlyContinue) {
            $prompt | Set-Clipboard
            Write-Host ' (prompt copied to clipboard)' -ForegroundColor DarkGreen
        } else {
            Write-Host ' (Set-Clipboard unavailable; copy manually)' -ForegroundColor DarkGray
        }
    } catch {
        Write-Host ' (clipboard copy failed; copy manually)' -ForegroundColor DarkGray
    }
}

Write-Host ''
