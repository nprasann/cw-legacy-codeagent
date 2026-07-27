<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%--
  approveClaim.jsp
  ----------------
  Submission form for the Approve Claim flow.

  LEGACY PATTERNS DEMONSTRATED
   - Custom Struts tag libraries (<html:form>, <html:text>).
   - Form posts to "/approveClaim.do" - the classic *.do mapping.
   - Errors rendered via <html:errors/> with no per-field placement.
--%>
<html>
<head><title>Approve Claim</title></head>
<body>
<h1>Approve Claim</h1>

<html:errors/>

<html:form action="/approveClaim">
  <table>
    <tr>
      <td><bean:message key="approveClaim.claimId"/>:</td>
      <td><html:text property="claimId" size="20" maxlength="12"/></td>
    </tr>
    <tr>
      <td><bean:message key="approveClaim.approverId"/>:</td>
      <td><html:text property="approverId" size="20" maxlength="8"/></td>
    </tr>
    <tr>
      <td><bean:message key="approveClaim.approvedAmount"/>:</td>
      <td><html:text property="approvedAmount" size="15"/></td>
    </tr>
    <tr>
      <td>Comments:</td>
      <td><html:textarea property="comments" rows="4" cols="40"/></td>
    </tr>
    <tr>
      <td colspan="2"><html:submit value="Approve"/></td>
    </tr>
  </table>
</html:form>

</body>
</html>
