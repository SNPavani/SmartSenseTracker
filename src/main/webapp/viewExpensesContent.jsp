<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.expense.model.Expense, java.util.Locale" %>
<%
    if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; }
    List<Expense> expenses = (List<Expense>) request.getAttribute("expenses");
    double total = 0;
    if (expenses != null) for (Expense exp : expenses) total += exp.getAmount();

    java.util.Map<String, String> catIcons = new java.util.HashMap<>();
    catIcons.put("Housing","bi-house-fill"); catIcons.put("Food","bi-cup-hot-fill");
    catIcons.put("Transportation","bi-car-front-fill"); catIcons.put("Shopping","bi-bag-fill");
    catIcons.put("Entertainment","bi-film"); catIcons.put("Health","bi-heart-pulse-fill");
    catIcons.put("Investments","bi-graph-up-arrow"); catIcons.put("Others","bi-grid-fill");

    java.util.Map<String, String> catClass = new java.util.HashMap<>();
    catClass.put("Housing","housing"); catClass.put("Food","food");
    catClass.put("Transportation","transport"); catClass.put("Shopping","shopping");
    catClass.put("Entertainment","entertainment"); catClass.put("Health","health");
    catClass.put("Investments","investments"); catClass.put("Others","default");

    String success = request.getParameter("success");
    String error   = request.getParameter("error");
%>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 style="font-family:'DM Sans',sans-serif;font-size:1.3rem;font-weight:700;color:#1A1A1A;margin-bottom:2px;">
            Transaction History
        </h1>
        <p style="font-size:0.78rem;color:#8A8A9A;margin:0;">All your recorded expenses</p>
    </div>
    <a href="AddExpenseServlet" class="btn-maroon">
        <i class="bi bi-plus-lg"></i> Add Transaction
    </a>
</div>

<% if ("deleted".equals(success)) { %>
    <div class="alert-bank success"><i class="bi bi-check-circle-fill"></i> Transaction deleted successfully.</div>
<% } else if ("updated".equals(success)) { %>
    <div class="alert-bank success"><i class="bi bi-check-circle-fill"></i> Transaction updated successfully.</div>
<% } else if ("added".equals(success)) { %>
    <div class="alert-bank success"><i class="bi bi-check-circle-fill"></i> Transaction added successfully.</div>
<% } %>
<% if ("delete".equals(error) || "not_found".equals(error)) { %>
    <div class="alert-bank danger"><i class="bi bi-exclamation-octagon-fill"></i> Operation failed. Please try again.</div>
<% } %>

<!-- Summary Strip -->
<div style="display:flex;gap:12px;margin-bottom:20px;">
    <div style="background:#FFF9F9;border:1px solid rgba(139,0,0,0.15);border-radius:10px;padding:14px 20px;display:flex;align-items:center;gap:12px;">
        <i class="bi bi-wallet2" style="color:#8B0000;font-size:1.1rem;"></i>
        <div>
            <div style="font-size:0.68rem;color:#8A8A9A;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;">Total Outflow</div>
            <div style="font-size:1.05rem;font-weight:700;color:#8B0000;">&#8377;<%= String.format(Locale.US, "%,.2f", total) %></div>
        </div>
    </div>
    <div style="background:#F0F2F5;border:1px solid #E2E5EA;border-radius:10px;padding:14px 20px;display:flex;align-items:center;gap:12px;">
        <i class="bi bi-receipt" style="color:#1A5276;font-size:1.1rem;"></i>
        <div>
            <div style="font-size:0.68rem;color:#8A8A9A;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;">Transactions</div>
            <div style="font-size:1.05rem;font-weight:700;color:#1A1A1A;"><%= expenses != null ? expenses.size() : 0 %></div>
        </div>
    </div>
</div>

<!-- Table -->
<div class="bank-card">
    <div class="bank-card-header">
        <div class="bank-card-title"><i class="bi bi-list-ul"></i> All Transactions</div>
    </div>

    <% if (expenses == null || expenses.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state-icon"><i class="bi bi-inbox"></i></div>
            <div class="empty-state-title">No Transactions Found</div>
            <div class="empty-state-sub">Start adding expenses to see your transaction history</div>
            <a href="AddExpenseServlet" class="btn-maroon" style="font-size:0.825rem;padding:9px 18px;">
                <i class="bi bi-plus-lg"></i> Add First Transaction
            </a>
        </div>
    <% } else { %>
        <div style="overflow-x:auto;">
            <table class="txn-table">
                <thead>
                    <tr>
                        <th>Transaction</th>
                        <th>Date</th>
                        <th>Category</th>
                        <th style="text-align:right;">Amount</th>
                        <th style="text-align:center;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Expense exp : expenses) {
                        String cat  = exp.getCategory() != null ? exp.getCategory() : "Others";
                        String icon = catIcons.getOrDefault(cat, "bi-grid-fill");
                        String cls  = catClass.getOrDefault(cat, "default");
                    %>
                    <tr>
                        <td>
                            <div style="display:flex;align-items:center;gap:12px;">
                                <div class="txn-icon">
                                    <i class="bi <%= icon %>"></i>
                                </div>
                                <div>
                                    <div class="txn-title"><%= exp.getTitle() %></div>
                                    <div class="txn-id">ID #<%= String.format("%04d", exp.getId()) %></div>
                                </div>
                            </div>
                        </td>
                        <td style="font-size:0.845rem;color:#4A4A4A;font-weight:500;"><%= exp.getDate() %></td>
                        <td><span class="cat-badge <%= cls %>"><i class="bi <%= icon %>" style="font-size:0.65rem;"></i> <%= cat %></span></td>
                        <td style="text-align:right;" class="amount-debit">- &#8377;<%= String.format(Locale.US, "%,.2f", exp.getAmount()) %></td>
                        <td style="text-align:center;">
                            <div style="display:flex;align-items:center;justify-content:center;gap:6px;">
                                <a href="EditExpenseServlet?id=<%= exp.getId() %>" class="btn-edit-soft">
                                    <i class="bi bi-pencil"></i> Edit
                                </a>
                                <a href="DeleteExpenseServlet?id=<%= exp.getId() %>"
                                   class="btn-danger-soft"
                                   onclick="return confirm('Delete this transaction?');">
                                    <i class="bi bi-trash"></i> Delete
                                </a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="3" style="font-weight:700;">Total Balance Outflow</td>
                        <td style="text-align:right;font-size:1rem;">&#8377;<%= String.format(Locale.US, "%,.2f", total) %></td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    <% } %>
</div>
