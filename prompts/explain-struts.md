# Prompt — Explain a Struts 1 Request Lifecycle

> Agent: `@legacy-code` (LegacyCodeAgent)
> Skill: Struts 1 Request Lifecycle Analysis, Legacy Code Explanation
> Use when a developer needs to trace a single `*.do` request from URL
> to JSP / Tile response in an Apache Struts 1.0 app.

---

## Copy-paste prompt

```
@legacy-code Trace the Struts 1.0 request lifecycle below end-to-end
for a developer who has never used Struts. Be precise about which
class / file owns each step.

TARGET
- Entry point: <URI like /approveClaim.do | Action class | JSP>
- Action class:        <path/to/SomethingAction.java>
- Form bean:           <path/to/SomethingForm.java>
- struts-config.xml:   <path/to/WEB-INF/struts-config.xml>
- validation.xml (opt):<path/to/WEB-INF/validation.xml>
- web.xml:             <path/to/WEB-INF/web.xml>
- JSP(s) reached:      <path/to/WEB-INF/jsp/*.jsp>

GROUNDING (use /knowledge first, then code)
- /knowledge/technical-papers/** for Struts 1 lifecycle background.
- /knowledge/tribal/**           for module-specific quirks, "do not touch".
- /knowledge/design-docs/**      for intent of the screen / flow.
- Cite every grounded claim as [knowledge/<folder>/<file>.md#<anchor>].

OUTPUT CONTRACT (use these exact section headers)
1. Summary
   - 1-3 sentences. Business purpose of the screen, then mechanics.

2. Request Map
   - Numbered steps: Browser -> ActionServlet (web.xml *.do) ->
     ActionMapping (struts-config.xml) -> ActionForm reset/populate ->
     validate() -> Action.execute() -> findForward -> JSP / Tile render.

3. Mapping Details (struts-config.xml)
   - Table: path / type / name (form) / scope / validate / input /
     forwards (success | input | failure | custom).

4. Form Binding Table
   - Table: Form field / HTTP param name / ActionForm property /
     Java type / Declarative rule (validation.xml) / Programmatic rule
     (validate()) / Notes (primitive defaults, reset() behavior).

5. Validation Path
   - Order of evaluation: declarative vs programmatic.
   - Flag duplicated or drifted rules between validation.xml and
     ActionForm.validate().

6. Action.execute() Walkthrough
   - Numbered steps. Call out:
     - Inputs read from request, session, application scope.
     - Side effects (JDBC, stored procs, session writes, file I/O).
     - Forward selection logic and the magic forward names used.

7. Forward Graph
   - Mermaid `flowchart LR` of all possible outcomes (success / input /
     failure / global-forward) and the JSP / Tile each resolves to.

8. View Layer
   - JSPs / Tiles rendered. Note key tags used (<html:form>, <bean:write>,
     <logic:iterate>) and any XSS / escaping concerns.

9. Cross-Cutting Concerns
   - Filters, interceptors, session usage (especially scope="session"
     form-beans), shared resources, security gaps (CSRF, auth).

10. Legacy-isms
    - Bullet list of anti-patterns (god Action, SQL injection, hard-coded
      credentials, swallowed exceptions, etc.) with severity hint.

11. Modern Analogy
    - One paragraph mapping the flow to a modern equivalent
      (e.g., Spring Boot @Controller + DTO + @Service + Thymeleaf/React).

12. Open Questions
    - Things only an SME can answer; propose new /knowledge files.

13. Confidence
    - grounded | partial | inferred.

14. Gaps
    - Missing /knowledge files that SHOULD exist for this screen.
```

---

## Notes for the requester

- Attach the Action, Form, `struts-config.xml`, and target JSP(s) for the
  best trace.
- For a screen with multiple submit paths, ask for **Section 7
  (Forward Graph)** first and follow up per branch.
