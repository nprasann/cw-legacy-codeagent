# Struts 1.0 Example — Approve Claim Flow

A classic Apache Struts 1.0 request flow: form -> ActionForm -> Action ->
stored procedure -> JSP. Loaded with intentional legacy anti-patterns.

## Files

```
struts/
└── src/main/
    ├── java/com/example/legacy/billing/action/
    │   ├── ApproveClaimAction.java
    │   └── ApproveClaimForm.java
    └── webapp/WEB-INF/
        ├── struts-config.xml
        ├── validation.xml
        ├── web.xml
        └── jsp/
            ├── approveClaim.jsp
            └── approveClaimConfirm.jsp
```

## Request flow

```
Browser
   |  POST /approveClaim.do
   v
ActionServlet (web.xml *.do)
   |  resolves mapping in struts-config.xml
   v
ApproveClaimForm  <-- populated from request params
   |  reset() / validate() (declarative + programmatic)
   v
ApproveClaimAction.execute()
   |  JDBC update + stored proc + lookup
   v
findForward("success" | "input" | "failure")
   v
JSP (approveClaim.jsp / approveClaimConfirm.jsp / error.jsp)
```

## Legacy patterns to demo

- **God Action**: business logic + JDBC + view selection in `execute()`.
- **SQL injection** via string concatenation.
- **Hard-coded JDBC credentials** in source.
- **DriverManager per request** (no connection pool).
- **Session abuse**: stashing a JDBC `Connection` on `HttpSession`.
- **Duplicated validation**: `validation.xml` and `validate()` both define rules.
- **`scope="session"` form-bean** with no-op `reset()` -> stale data leakage.
- **No transaction boundary** around multi-statement update + stored proc.
- **Catch-all exception handling** losing root cause.
- **Magic forward names** that must match `struts-config.xml` exactly.
- **JSP with no XSS escaping** on user-provided fields.

## Suggested prompts

```
@legacy-code Trace the request flow for examples/struts/.../ApproveClaimAction
from /approveClaim.do through struts-config.xml to the JSP response.
Include the validation path and all possible forwards.

@review Review examples/struts/.../ApproveClaimAction.java. Focus on
security (SQL injection, credential handling), correctness (transaction
boundaries, resource leaks), and maintainability.

@review Score modernization opportunities for the Approve Claim flow.
Suggest a strangler-fig boundary toward Spring Boot.
```
