package com.example.legacy.billing.action;

import javax.servlet.http.HttpServletRequest;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;

/**
 * ApproveClaimForm
 * ----------------
 * Classic Struts 1.0 ActionForm bean. Populated automatically from
 * request parameters via BeanUtils.
 *
 * LEGACY PATTERNS DEMONSTRATED
 * ----------------------------
 *  1. Primitive fields (double) cannot represent "absent" - default
 *     0.0 silently passes validation.
 *  2. validate() duplicates rules also declared in validation.xml.
 *  3. reset() is a no-op, so stale values from a prior request can
 *     leak when scope="session" (configured in struts-config.xml).
 *  4. No DTO separation: the ActionForm is what the JSP renders AND
 *     what the database update reads.
 */
public class ApproveClaimForm extends ActionForm {

    private String claimId;
    private String approverId;
    private double approvedAmount;  // LEGACY: primitive => no "null" state
    private String comments;

    public String getClaimId()          { return claimId; }
    public void   setClaimId(String v)  { this.claimId = v; }

    public String getApproverId()         { return approverId; }
    public void   setApproverId(String v) { this.approverId = v; }

    public double getApprovedAmount()         { return approvedAmount; }
    public void   setApprovedAmount(double v) { this.approvedAmount = v; }

    public String getComments()          { return comments; }
    public void   setComments(String v)  { this.comments = v; }

    @Override
    public void reset(ActionMapping mapping, HttpServletRequest request) {
        // LEGACY: no-op reset - stale session-scoped form values can leak.
    }

    @Override
    public ActionErrors validate(ActionMapping mapping,
                                 HttpServletRequest request) {
        ActionErrors errors = new ActionErrors();
        if (claimId == null || claimId.trim().length() == 0) {
            errors.add("claimId",
                new ActionMessage("error.claimId.required"));
        }
        if (approverId == null || approverId.trim().length() == 0) {
            errors.add("approverId",
                new ActionMessage("error.approverId.required"));
        }
        if (approvedAmount < 0) {
            errors.add("approvedAmount",
                new ActionMessage("error.amount.negative"));
        }
        return errors;
    }
}
