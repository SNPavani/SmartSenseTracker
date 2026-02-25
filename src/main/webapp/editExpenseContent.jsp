<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.expense.model.Category, com.expense.model.Expense, com.expense.dao.DatabaseConnection" %>
<%
    if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; }
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) { response.sendRedirect("ViewExpensesServlet"); return; }
    int expenseId;
    try { expenseId = Integer.parseInt(idParam); } catch (NumberFormatException e) { response.sendRedirect("ViewExpensesServlet"); return; }

    Expense expense = null;
    List<Category> categories = new ArrayList<>();

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT id, title, amount, expense_date, category_id FROM expenses WHERE id=? AND user_id=?")) {
        ps.setInt(1, expenseId); ps.setInt(2, (int) session.getAttribute("userId"));
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                expense = new Expense();
                expense.setId(rs.getInt("id")); expense.setTitle(rs.getString("title"));
                expense.setAmount(rs.getDouble("amount")); expense.setDate(rs.getDate("expense_date"));
                expense.setCategoryId(rs.getInt("category_id"));
            }
        }
        try (PreparedStatement ps2 = conn.prepareStatement("SELECT id, name FROM categories");
             ResultSet rs2 = ps2.executeQuery()) {
            while (rs2.next()) categories.add(new Category(rs2.getInt("id"), rs2.getString("name")));
        }
    } catch (Exception e) { e.printStackTrace(); }

    if (expense == null) { response.sendRedirect("ViewExpensesServlet"); return; }
    String error = request.getParameter("error");
%>

<div class="row justify-content-center">
<div class="col-lg-7">

<div class="mb-4">
    <h1 style="font-family:'DM Sans',sans-serif;font-size:1.3rem;font-weight:700;color:#1A1A1A;margin-bottom:2px;">Edit Transaction</h1>
    <p style="font-size:0.78rem;color:#8A8A9A;margin:0;">Modifying Transaction ID #<%= String.format("%04d", expense.getId()) %></p>
</div>

<% if (error != null) { %>
    <div class="alert-bank danger">
        <i class="bi bi-exclamation-octagon-fill"></i>
        <% if ("invalid_amount".equals(error)) { %>Amount must be greater than zero.
        <% } else { %>Failed to update. Please try again.<% } %>
    </div>
<% } %>

<div class="bank-card">
    <div class="bank-card-header">
        <div class="bank-card-title"><i class="bi bi-pencil-fill"></i> Update Details</div>
        <div style="background:#FFF9F9;border:1px solid rgba(139,0,0,0.15);border-radius:6px;padding:4px 10px;">
            <span style="font-size:0.7rem;color:#8B0000;font-weight:700;">TXN #<%= String.format("%04d", expense.getId()) %></span>
        </div>
    </div>
    <div class="bank-card-body">
        <form action="EditExpenseServlet" method="post">
            <input type="hidden" name="expenseId" value="<%= expense.getId() %>">

            <div class="mb-3">
                <label class="form-label" for="title">Description</label>
                <input type="text" id="title" name="title" class="form-control"
                       value="<%= expense.getTitle() %>" required>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label class="form-label" for="amount">Amount</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-weight:700;color:#8B0000;font-size:1rem;">&#8377;</span>
                        <input type="number" id="amount" name="amount" class="form-control"
                               step="0.01" min="0.01"
                               value="<%= String.format("%.2f", expense.getAmount()) %>"
                               style="padding-left:28px;" required>
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="date">Date</label>
                    <input type="date" id="date" name="date" class="form-control"
                           value="<%= expense.getDate() %>" required>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label" for="categoryId">Category</label>
                <select id="categoryId" name="categoryId" class="form-select" required>
                    <% for (Category c : categories) { %>
                        <option value="<%= c.getId() %>" <%= c.getId() == expense.getCategoryId() ? "selected" : "" %>>
                            <%= c.getName() %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div style="display:flex;gap:10px;">
                <button type="submit" class="btn-maroon">
                    <i class="bi bi-check-circle-fill"></i> Save Changes
                </button>
                <a href="ViewExpensesServlet" class="btn-outline">
                    <i class="bi bi-x-circle"></i> Cancel
                </a>
            </div>
        </form>
    </div>
</div>

<div style="display:flex;align-items:center;gap:8px;margin-top:14px;padding:10px 14px;background:#F8F9FA;border:1px solid #E2E5EA;border-radius:8px;">
    <i class="bi bi-shield-check" style="color:#8B0000;"></i>
    <span style="font-size:0.72rem;color:#8A8A9A;">All changes are saved securely and applied immediately.</span>
</div>

</div>
</div>
