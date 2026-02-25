<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.expense.model.Category, com.expense.dao.DatabaseConnection" %>
<%
    if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; }
    List<Category> categories = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM categories");
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) categories.add(new Category(rs.getInt("id"), rs.getString("name")));
    } catch (Exception e) { e.printStackTrace(); }
    java.time.LocalDate today = java.time.LocalDate.now();
    String error = request.getParameter("error");
%>

<div class="row justify-content-center">
<div class="col-lg-7">

<div class="mb-4">
    <h1 style="font-family:'DM Sans',sans-serif;font-size:1.3rem;font-weight:700;color:#1A1A1A;margin-bottom:2px;">Add Transaction</h1>
    <p style="font-size:0.78rem;color:#8A8A9A;margin:0;">Record a new expense to your account</p>
</div>

<% if (error != null) { %>
    <div class="alert-bank danger">
        <i class="bi bi-exclamation-octagon-fill"></i>
        <% if ("missing_fields".equals(error)) { %>All fields are required.
        <% } else if ("invalid_amount".equals(error)) { %>Amount must be greater than zero.
        <% } else { %>Failed to add transaction. Please try again.<% } %>
    </div>
<% } %>

<!-- Transaction type strip -->
<div style="display:flex;gap:8px;margin-bottom:20px;">
    <div style="flex:1;background:#FFF9F9;border:2px solid #8B0000;border-radius:10px;padding:12px 16px;text-align:center;cursor:pointer;">
        <i class="bi bi-arrow-up-circle-fill" style="color:#8B0000;font-size:1.1rem;display:block;margin-bottom:4px;"></i>
        <span style="font-size:0.78rem;font-weight:700;color:#8B0000;">Expense</span>
    </div>
</div>

<div class="bank-card">
    <div class="bank-card-header">
        <div class="bank-card-title"><i class="bi bi-plus-circle-fill"></i> Transaction Details</div>
        <span style="font-size:0.72rem;color:#8A8A9A;">All fields required</span>
    </div>
    <div class="bank-card-body">
        <form action="AddExpenseServlet" method="post">

            <div class="mb-3">
                <label class="form-label" for="title">Description</label>
                <input type="text" id="title" name="title" class="form-control"
                       placeholder="e.g. Grocery shopping, Electricity bill" required>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label class="form-label" for="amount">Amount</label>
                    <div style="position:relative;">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-weight:700;color:#8B0000;font-size:1rem;">&#8377;</span>
                        <input type="number" id="amount" name="amount" class="form-control"
                               step="0.01" min="0.01" placeholder="0.00"
                               style="padding-left:28px;" required>
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="date">Date</label>
                    <input type="date" id="date" name="date" class="form-control"
                           value="<%= today %>" required>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label" for="categoryId">Category</label>
                <select id="categoryId" name="categoryId" class="form-select" required>
                    <option value="" disabled selected>— Select category —</option>
                    <% for (Category c : categories) { %>
                        <option value="<%= c.getId() %>"><%= c.getName() %></option>
                    <% } %>
                </select>
            </div>

            <!-- Category chips -->
            <div style="background:#F8F9FA;border:1px solid #E2E5EA;border-radius:8px;padding:12px 14px;margin-bottom:22px;">
                <div style="font-size:0.68rem;color:#8A8A9A;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:8px;">Categories</div>
                <div style="display:flex;flex-wrap:wrap;gap:6px;">
                    <span class="cat-badge housing"><i class="bi bi-house-fill"></i> Housing</span>
                    <span class="cat-badge food"><i class="bi bi-cup-hot-fill"></i> Food</span>
                    <span class="cat-badge transport"><i class="bi bi-car-front-fill"></i> Transport</span>
                    <span class="cat-badge shopping"><i class="bi bi-bag-fill"></i> Shopping</span>
                    <span class="cat-badge entertainment"><i class="bi bi-film"></i> Entertainment</span>
                    <span class="cat-badge health"><i class="bi bi-heart-pulse-fill"></i> Health</span>
                    <span class="cat-badge investments"><i class="bi bi-graph-up-arrow"></i> Investments</span>
                    <span class="cat-badge default"><i class="bi bi-grid-fill"></i> Others</span>
                </div>
            </div>

            <div style="display:flex;gap:10px;">
                <button type="submit" class="btn-maroon">
                    <i class="bi bi-check-circle-fill"></i> Record Transaction
                </button>
                <a href="ViewExpensesServlet" class="btn-outline">
                    <i class="bi bi-arrow-left"></i> Cancel
                </a>
            </div>
        </form>
    </div>
</div>

<div style="display:flex;align-items:center;gap:8px;margin-top:14px;padding:10px 14px;background:#F8F9FA;border:1px solid #E2E5EA;border-radius:8px;">
    <i class="bi bi-shield-check" style="color:#8B0000;"></i>
    <span style="font-size:0.72rem;color:#8A8A9A;">Your transaction data is encrypted and stored securely.</span>
</div>

</div>
</div>
