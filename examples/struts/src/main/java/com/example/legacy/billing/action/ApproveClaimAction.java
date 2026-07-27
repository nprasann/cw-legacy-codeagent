package com.example.legacy.billing.action;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

/**
 * ApproveClaimAction
 * ------------------
 * Classic Struts 1.0 Action that "approves" a claim by calling a
 * stored procedure and forwarding to a JSP.
 *
 * LEGACY PATTERNS DEMONSTRATED
 * ----------------------------
 *  1. God Action - business logic, DB access, and view selection
 *     all live in execute().
 *  2. Direct JDBC with DriverManager and hard-coded credentials
 *     (in real systems these were often pulled from a properties
 *     file checked into source control).
 *  3. SQL string concatenation - classic SQL injection sink.
 *  4. Session abuse: storing entire domain objects (and a JDBC
 *     Connection!) on HttpSession across requests.
 *  5. Catch-all exception handling that swallows root causes and
 *     forwards to a generic error page.
 *  6. Forwards chosen via magic strings ("success", "input",
 *     "failure") that must match struts-config.xml exactly.
 *  7. No transaction boundary around the multi-statement update.
 *
 * Map to modern equivalent:
 *  - Spring Boot @RestController with @Transactional service,
 *    DTOs, parameterized SQL or JPA, no shared mutable session.
 */
public class ApproveClaimAction extends Action {

    // LEGACY: hard-coded credentials. Modern: externalized config + secret store.
    private static final String JDBC_URL  =
        "jdbc:sqlserver://legacy-db:1433;databaseName=BILLING";
    private static final String JDBC_USER = "billing_app";
    private static final String JDBC_PASS = "ChangeMe123!";

    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        ApproveClaimForm f = (ApproveClaimForm) form;
        HttpSession session = request.getSession(true);

        // LEGACY: programmatic validation duplicating validation.xml.
        ActionMessages errors = new ActionMessages();
        if (f.getClaimId() == null || f.getClaimId().trim().length() == 0) {
            errors.add("claimId",
                new ActionMessage("error.claimId.required"));
        }
        if (f.getApprovedAmount() < 0) {
            errors.add("approvedAmount",
                new ActionMessage("error.amount.negative"));
        }
        if (!errors.isEmpty()) {
            saveErrors(request, errors);
            return mapping.findForward("input");
        }

        Connection conn = null;
        try {
            // LEGACY: per-request DriverManager connection, no pool.
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS);

            // LEGACY: stash on session for the JSP to render. This Connection
            // will leak if the user never reaches the next page.
            session.setAttribute("legacyDbConn", conn);

            // ---- SQL INJECTION HOTSPOT ----
            // The approver id is concatenated straight from the form.
            String approver = f.getApproverId();
            String unsafeSql =
                "UPDATE BILLING.CLAIM " +
                "   SET STATUS_CD = 'A', " +
                "       APPROVED_AMT = " + f.getApprovedAmount() + ", " +
                "       APPROVED_BY  = '" + approver + "', " +
                "       APPROVED_DT  = GETDATE() " +
                " WHERE CLAIM_ID = '" + f.getClaimId() + "'";
            // LEGACY: ad-hoc Statement, no PreparedStatement, no transaction.
            conn.createStatement().executeUpdate(unsafeSql);

            // LEGACY: business rule call via stored procedure that itself
            // mutates several other tables and triggers an overnight
            // batch reconciliation. Tight coupling, hard to test.
            try (PreparedStatement cs = conn.prepareStatement(
                    "{ call usp_PostClaimApproval(?, ?) }")) {
                cs.setString(1, f.getClaimId());
                cs.setString(2, approver);
                cs.execute();
            }

            // LEGACY: look up the result to render confirmation. Sharing the
            // same Connection across statements without a transaction means
            // a mid-flight failure leaves the row half-updated.
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT CLAIM_ID, STATUS_CD, APPROVED_AMT, APPROVED_BY " +
                    "  FROM BILLING.CLAIM WHERE CLAIM_ID = ?")) {
                ps.setString(1, f.getClaimId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("claimId",     rs.getString(1));
                        request.setAttribute("statusCd",    rs.getString(2));
                        request.setAttribute("approvedAmt", rs.getDouble(3));
                        request.setAttribute("approvedBy",  rs.getString(4));
                    }
                }
            }

            return mapping.findForward("success");

        } catch (SQLException sqle) {
            // LEGACY: catch-all that loses stack on the way to the JSP.
            request.setAttribute("legacyError", sqle.getMessage());
            return mapping.findForward("failure");
        } catch (Exception e) {
            request.setAttribute("legacyError", e.getMessage());
            return mapping.findForward("failure");
        } finally {
            // LEGACY: only sometimes closed - because we also stashed it on
            // the session above, closing here can break the JSP that tries
            // to render data from the same connection.
            // (Intentionally left as-is to demonstrate the bug.)
        }
    }
}
