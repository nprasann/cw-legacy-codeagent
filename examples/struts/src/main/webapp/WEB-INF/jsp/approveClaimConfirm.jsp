<%--
  approveClaimConfirm.jsp
  -----------------------
  Confirmation page rendered after a successful approval.

  LEGACY PATTERNS DEMONSTRATED
   - Reads attributes the Action stuck onto request scope by name -
     no model object, just stringly-typed lookups.
   - No XSS escaping on user-provided fields (APPROVED_BY).
--%>
<html>
<head><title>Approve Claim - Confirmation</title></head>
<body>
<h1>Claim Approved</h1>

<p>
  Claim <b><%= request.getAttribute("claimId") %></b> has been approved.
</p>
<ul>
  <li>Status:        <%= request.getAttribute("statusCd") %></li>
  <li>Approved By:   <%= request.getAttribute("approvedBy") %></li>
  <li>Approved Amt:  <%= request.getAttribute("approvedAmt") %></li>
</ul>

<p><a href="/billing/index.jsp">Back to Billing Home</a></p>
</body>
</html>
