<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.expense.dao.DatabaseConnection" %>
<%
    if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; }
    int userId = (int) session.getAttribute("userId");
    double monthlyIncome = 0, expenseLimit = 0;
    String userName = "", userEmail = "";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT name, email, monthly_income, expense_limit FROM users WHERE id=?")) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            userName      = rs.getString("name");
            userEmail     = rs.getString("email");
            monthlyIncome = rs.getDouble("monthly_income");
            expenseLimit  = rs.getDouble("expense_limit");
        }
    } catch (Exception e) { e.printStackTrace(); }

    String success = request.getParameter("success");
    String error   = request.getParameter("error");
%>

<div class="mb-4">
    <h1 style="font-family:'DM Sans',sans-serif;font-size:1.3rem;font-weight:700;color:#1A1A1A;margin-bottom:2px;">Account Settings</h1>
    <p style="font-size:0.78rem;color:#8A8A9A;margin:0;">Manage your financial preferences and account details</p>
</div>

<% if ("saved".equals(success)) { %>
    <div class="alert-bank success"><i class="bi bi-check-circle-fill"></i> Settings saved successfully.</div>
<% } %>
<% if (error != null) { %>
    <div class="alert-bank danger"><i class="bi bi-exclamation-octagon-fill"></i> Failed to save. Please try again.</div>
<% } %>

<div class="row g-3">

    <!-- Account Info -->
    <div class="col-lg-4">
        <div class="bank-card">
            <div class="bank-card-header">
                <div class="bank-card-title"><i class="bi bi-person-fill"></i> Account Info</div>
            </div>
            <div class="bank-card-body" style="text-align:center;">
                <div style="width:64px;height:64px;border-radius:50%;background:#8B0000;display:flex;align-items:center;justify-content:center;font-size:1.6rem;font-weight:700;color:white;margin:0 auto 14px;">
                    <%= userName.substring(0,1).toUpperCase() %>
                </div>
                <div style="font-size:1rem;font-weight:700;color:#1A1A1A;margin-bottom:4px;"><%= userName %></div>
                <div style="font-size:0.8rem;color:#8A8A9A;margin-bottom:16px;"><%= userEmail %></div>
                <div style="background:#E8F5EE;border:1px solid rgba(26,127,75,0.2);border-radius:20px;padding:5px 14px;display:inline-block;">
                    <span style="font-size:0.72rem;color:#1A7F4B;font-weight:600;">&#9679; Account Active</span>
                </div>
            </div>
        </div>

        <!-- Quick stats -->
        <div class="bank-card">
            <div class="bank-card-header">
                <div class="bank-card-title"><i class="bi bi-bar-chart-fill"></i> Current Setup</div>
            </div>
            <div style="padding:16px 20px;display:flex;flex-direction:column;gap:12px;">
                <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:12px;border-bottom:1px solid #F5F5F5;">
                    <span style="font-size:0.825rem;color:#4A4A4A;">Monthly Income</span>
                    <span style="font-size:0.925rem;font-weight:700;color:<%= monthlyIncome > 0 ? "#1A7F4B" : "#8A8A9A" %>">
                        <%= monthlyIncome > 0 ? "&#8377;" + String.format("%,.0f", monthlyIncome) : "Not set" %>
                    </span>
                </div>
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <span style="font-size:0.825rem;color:#4A4A4A;">Expense Limit</span>
                    <span style="font-size:0.925rem;font-weight:700;color:<%= expenseLimit > 0 ? "#8B0000" : "#8A8A9A" %>">
                        <%= expenseLimit > 0 ? "&#8377;" + String.format("%,.0f", expenseLimit) : "Not set" %>
                    </span>
                </div>
            </div>
        </div>
    </div>

    <!-- Settings Form -->
    <div class="col-lg-8">
        <div class="bank-card">
            <div class="bank-card-header">
                <div class="bank-card-title"><i class="bi bi-sliders"></i> Financial Settings</div>
            </div>
            <div class="bank-card-body">
                <form action="SettingsServlet" method="post">

                    <!-- Income Section -->
                    <div style="background:#F0FDF4;border:1px solid rgba(26,127,75,0.15);border-radius:10px;padding:18px;margin-bottom:20px;">
                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
                            <div style="width:32px;height:32px;background:#E8F5EE;border-radius:8px;display:flex;align-items:center;justify-content:center;">
                                <i class="bi bi-arrow-down-circle-fill" style="color:#1A7F4B;"></i>
                            </div>
                            <div>
                                <div style="font-size:0.875rem;font-weight:700;color:#1A1A1A;">Monthly Income</div>
                                <div style="font-size:0.72rem;color:#8A8A9A;">Your total take-home salary per month</div>
                            </div>
                        </div>
                        <label class="form-label" for="monthlyIncome">Income Amount</label>
                        <div style="position:relative;">
                            <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-weight:700;color:#1A7F4B;font-size:1rem;">&#8377;</span>
                            <input type="number" id="monthlyIncome" name="monthlyIncome"
                                   class="form-control" step="100" min="0"
                                   placeholder="e.g. 50000"
                                   value="<%= monthlyIncome > 0 ? String.format("%.0f", monthlyIncome) : "" %>"
                                   style="padding-left:28px;border-color:rgba(26,127,75,0.2);">
                        </div>
                    </div>

                    <!-- Limit Section -->
                    <div style="background:#FFF9F9;border:1px solid rgba(139,0,0,0.12);border-radius:10px;padding:18px;margin-bottom:20px;">
                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
                            <div style="width:32px;height:32px;background:rgba(139,0,0,0.08);border-radius:8px;display:flex;align-items:center;justify-content:center;">
                                <i class="bi bi-speedometer2" style="color:#8B0000;"></i>
                            </div>
                            <div>
                                <div style="font-size:0.875rem;font-weight:700;color:#1A1A1A;">Monthly Expense Limit</div>
                                <div style="font-size:0.72rem;color:#8A8A9A;">Get alerted when you approach this limit</div>
                            </div>
                        </div>
                        <label class="form-label" for="expenseLimit">Spending Limit</label>
                        <div style="position:relative;">
                            <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-weight:700;color:#8B0000;font-size:1rem;">&#8377;</span>
                            <input type="number" id="expenseLimit" name="expenseLimit"
                                   class="form-control" step="100" min="0"
                                   placeholder="e.g. 30000"
                                   value="<%= expenseLimit > 0 ? String.format("%.0f", expenseLimit) : "" %>"
                                   style="padding-left:28px;border-color:rgba(139,0,0,0.15);">
                        </div>

                        <!-- Suggested limits -->
                        <% if (monthlyIncome > 0) { %>
                        <div style="margin-top:12px;">
                            <div style="font-size:0.7rem;color:#8A8A9A;font-weight:600;margin-bottom:6px;">Suggested limits based on your income:</div>
                            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                <span onclick="document.getElementById('expenseLimit').value='<%= Math.round(monthlyIncome * 0.50) %>'"
                                      style="cursor:pointer;background:white;border:1px solid #E2E5EA;border-radius:20px;padding:4px 10px;font-size:0.72rem;font-weight:600;color:#4A4A4A;">
                                    50% &nbsp; &#8377;<%= String.format("%,.0f", monthlyIncome * 0.50) %>
                                </span>
                                <span onclick="document.getElementById('expenseLimit').value='<%= Math.round(monthlyIncome * 0.60) %>'"
                                      style="cursor:pointer;background:white;border:1px solid #E2E5EA;border-radius:20px;padding:4px 10px;font-size:0.72rem;font-weight:600;color:#4A4A4A;">
                                    60% &nbsp; &#8377;<%= String.format("%,.0f", monthlyIncome * 0.60) %>
                                </span>
                                <span onclick="document.getElementById('expenseLimit').value='<%= Math.round(monthlyIncome * 0.70) %>'"
                                      style="cursor:pointer;background:white;border:1px solid #E2E5EA;border-radius:20px;padding:4px 10px;font-size:0.72rem;font-weight:600;color:#4A4A4A;">
                                    70% &nbsp; &#8377;<%= String.format("%,.0f", monthlyIncome * 0.70) %>
                                </span>
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <div style="display:flex;gap:10px;">
                        <button type="submit" class="btn-maroon">
                            <i class="bi bi-check-circle-fill"></i> Save Settings
                        </button>
                        <a href="DashboardServlet" class="btn-outline">
                            <i class="bi bi-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>
