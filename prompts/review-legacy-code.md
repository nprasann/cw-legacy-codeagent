# Prompt — Review Legacy Code

> Agent: `@review` (ReviewAgent), with `@legacy-code` and `@knowledge` as needed.
> Skill: Code Review (Legacy-Focused), Modernization Suggestions, Knowledge Grounding
> Use for diffs, single files, or whole modules touching Struts 1, COBOL,
> JCL, or T-SQL.

---

## Copy-paste prompt

```
@review Perform a legacy-aware code review on the change set below.
Distinguish between "bad code" and "load-bearing legacy" - the
latter must be preserved unless an SME-approved modernization plan
exists in /knowledge.

TARGET
- Type:  <diff | file | module>
- Ref:   <path | PR id | commit range>
- Language(s): <java/struts1 | cobol | jcl | tsql | jsp>
- Reviewer intent: <e.g., bug fix | refactor | perf | security | modernization>

REVIEW LENSES (apply all that are relevant)
- Security        (SQL injection, hard-coded creds, auth, input handling)
- Correctness     (transaction boundaries, error handling, race conditions)
- Performance     (N+1, cursors, missing indexes, full table scans)
- Maintainability (god objects, dead code, duplicated rules, magic numbers)
- Backward compat (impact on overnight batches, downstream consumers)
- Concurrency     (locking, NOLOCK, single-row trigger assumptions)

GROUNDING (use /knowledge before flagging)
- /knowledge/do-not-touch/**    HARD invariants; flag any violation as blocker.
- /knowledge/runbooks/**        operational guarantees the change must preserve.
- /knowledge/design-docs/**     intent the change must remain consistent with.
- /knowledge/tribal/**          SME context on why a pattern exists.
- Cite every grounded claim as [knowledge/<folder>/<file>.md#<anchor>].
- If you flag a pattern that may be intentional, check /knowledge first;
  do not call it out as a defect without checking.

OUTPUT CONTRACT (use these exact section headers)
1. Summary
   - 2-4 sentences. What the change does and the overall risk posture.

2. Findings
   - One row per finding, in this format:
     [severity] [category] <message> (file:line)
     severity: blocker | major | minor | nit
     category: security | correctness | performance | maintainability |
               backward-compat | concurrency | style

3. Risk Hotspots
   - Ranked list with rationale. Include blast radius
     (online | batch | DB | shared) for each.

4. Behavioral Preservation Check
   - Does this change alter observable behavior? If yes, list each
     behavior delta with the evidence.

5. Required Safety Nets
   - Characterization tests, feature flags, dual-writes, shadow runs,
     canary plan. Be specific (file/test names where possible).

6. Do-Not-Touch Violations
   - List any violations of /knowledge/do-not-touch/** with citations.
     Mark them as blockers.

7. Modernization Opportunities (advisory)
   - Table: Opportunity / Value (1-5) / Blast radius (1-5) /
     Effort (1-5) / Recommended sequencing.
   - Do NOT propose changes that violate do-not-touch.

8. Approval Recommendation
   - One of: approve | request-changes | block.
   - One paragraph rationale.

9. Confidence
   - grounded | partial | inferred.

10. Gaps
    - Missing /knowledge files needed to review this change confidently,
      with proposed paths.
```

---

## Notes for the requester

- For PR reviews, paste the unified diff or attach the changed files.
- For module-level reviews, narrow `Review lenses` to the top 2-3 to
  avoid noisy findings.
- To explicitly allow behavior change, replace the default with:
  `Behavior change is acceptable; call it out in Section 4 and require
  safety nets in Section 5.`
