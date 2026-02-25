mvn<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.expense.model.Expense, com.expense.dao.DatabaseConnection, com.expense.dao.ExpenseDAO, java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) { response.sendRedirect("login.jsp"); return; }

    int userId = (int) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    if (userName == null) userName = "there";
    String firstName = userName.contains(" ") ? userName.split(" ")[0] : userName;

    List<Expense> expenses       = new ArrayList<>();
    double totalExpense          = 0;
    double thisMonthExpense      = 0;
    double lastMonthExpense      = 0;
    double thisYearExpense       = 0;
    double monthlyIncome         = 0;
    double expenseLimit          = 0;
    Map<String, Double> catMapMonth = new LinkedHashMap<>();
    Map<String, Double> catMapYear  = new LinkedHashMap<>();

    java.time.LocalDate today = java.time.LocalDate.now();
    int curMonth = today.getMonthValue(), curYear = today.getYear();
    int lastMonth = curMonth == 1 ? 12 : curMonth - 1;
    int lastMonthYear = curMonth == 1 ? curYear - 1 : curYear;

    try (Connection conn = DatabaseConnection.getConnection()) {
        PreparedStatement ps0 = conn.prepareStatement("SELECT monthly_income, expense_limit FROM users WHERE id=?");
        ps0.setInt(1, userId);
        ResultSet rs0 = ps0.executeQuery();
        if (rs0.next()) { monthlyIncome = rs0.getDouble("monthly_income"); expenseLimit = rs0.getDouble("expense_limit"); }

        ExpenseDAO dao = new ExpenseDAO(conn);
        expenses     = dao.getAllExpenses(userId);
        totalExpense = dao.getTotalExpenses(userId);

        for (Expense e : expenses) {
            if (e.getDate() != null) {
                java.time.LocalDate d = e.getDate().toLocalDate();
                if (d.getMonthValue() == curMonth  && d.getYear() == curYear)       { thisMonthExpense += e.getAmount(); String cat = e.getCategory() != null ? e.getCategory() : "Others"; catMapMonth.merge(cat, e.getAmount(), Double::sum); }
                if (d.getMonthValue() == lastMonth && d.getYear() == lastMonthYear) lastMonthExpense += e.getAmount();
                if (d.getYear() == curYear)                                          { thisYearExpense  += e.getAmount(); String cat = e.getCategory() != null ? e.getCategory() : "Others"; catMapYear.merge(cat, e.getAmount(), Double::sum); }
            }
        }
    } catch (Exception ex) { ex.printStackTrace(); }

    double balance      = monthlyIncome - thisMonthExpense;
    double limitUsedPct = expenseLimit > 0 ? Math.min((thisMonthExpense / expenseLimit) * 100, 100) : 0;
    double savingsRate  = monthlyIncome > 0 ? ((monthlyIncome - thisMonthExpense) / monthlyIncome) * 100 : 0;
    double monthChange  = lastMonthExpense > 0 ? ((thisMonthExpense - lastMonthExpense) / lastMonthExpense) * 100 : 0;
    List<Expense> recent = expenses.size() > 5 ? expenses.subList(0, 5) : expenses;

    Map<String, String> catIcons = new HashMap<>();
    catIcons.put("Housing","bi-house-fill"); catIcons.put("Food","bi-cup-hot-fill");
    catIcons.put("Transportation","bi-car-front-fill"); catIcons.put("Shopping","bi-bag-fill");
    catIcons.put("Entertainment","bi-film"); catIcons.put("Health","bi-heart-pulse-fill");
    catIcons.put("Investments","bi-graph-up-arrow"); catIcons.put("Education","bi-mortarboard-fill");
    catIcons.put("Family","bi-people-fill"); catIcons.put("Others","bi-grid-fill");

    Map<String, String> catClass = new HashMap<>();
    catClass.put("Housing","housing"); catClass.put("Food","food"); catClass.put("Transportation","transport");
    catClass.put("Shopping","shopping"); catClass.put("Entertainment","entertainment"); catClass.put("Health","health");
    catClass.put("Investments","investments"); catClass.put("Education","education"); catClass.put("Family","family"); catClass.put("Others","default");

    Map<String, String> catColors = new LinkedHashMap<>();
    catColors.put("Housing","#8B0000"); catColors.put("Food","#C0392B"); catColors.put("Transportation","#E74C3C");
    catColors.put("Shopping","#E67E22"); catColors.put("Entertainment","#D35400"); catColors.put("Health","#27AE60");
    catColors.put("Investments","#2980B9"); catColors.put("Education","#8E44AD"); catColors.put("Family","#F39C12"); catColors.put("Others","#95A5A6");

    String monthName = today.getMonth().getDisplayName(java.time.format.TextStyle.FULL, Locale.ENGLISH);

    // Build JS arrays for MONTH donut
    StringBuilder mLabels = new StringBuilder(), mValues = new StringBuilder(), mColors = new StringBuilder();
    boolean first = true;
    for (Map.Entry<String, Double> e : catMapMonth.entrySet()) {
        if (!first) { mLabels.append(","); mValues.append(","); mColors.append(","); }
        mLabels.append("\"").append(e.getKey()).append("\"");
        mValues.append(String.format("%.2f", e.getValue()));
        mColors.append("\"").append(catColors.getOrDefault(e.getKey(), "#95A5A6")).append("\"");
        first = false;
    }

    // Build JS arrays for YEAR donut
    StringBuilder yLabels = new StringBuilder(), yValues = new StringBuilder(), yColors = new StringBuilder();
    first = true;
    for (Map.Entry<String, Double> e : catMapYear.entrySet()) {
        if (!first) { yLabels.append(","); yValues.append(","); yColors.append(","); }
        yLabels.append("\"").append(e.getKey()).append("\"");
        yValues.append(String.format("%.2f", e.getValue()));
        yColors.append("\"").append(catColors.getOrDefault(e.getKey(), "#95A5A6")).append("\"");
        first = false;
    }
%>

<style>
.sc-toggle { background: #F5F5F5; border: 1px solid #EBEBEB; border-radius: 6px; padding: 4px 10px; font-size: 0.7rem; font-weight: 600; color: #8A8A9A; cursor: pointer; transition: all 0.18s; font-family: 'Inter', sans-serif; }
.sc-toggle:hover  { background: #FEF0F0; color: #8B0000; border-color: #FADADA; }
.sc-toggle.active { background: #8B0000; color: #fff; border-color: #8B0000; }
</style>

<!-- Page Header — Personalized Greeting -->
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div class="greeting-text">
            <span id="greetingEmoji"></span><span id="greetingText"></span>, <%= firstName %>!
        </div>
        <p style="font-size:0.78rem;color:#8A8A9A;margin:0;">
            <%= today.getDayOfMonth() %> <%= monthName %> <%= today.getYear() %>
            &nbsp;|&nbsp; Financial summary for <%= monthName %>
        </p>
    </div>
    <a href="AddExpenseServlet" class="btn-maroon">
        <i class="bi bi-plus-lg"></i> Add Transaction
    </a>
</div>

<!-- Limit Warning -->
<% if (expenseLimit > 0 && thisMonthExpense >= expenseLimit * 0.9) { %>
<div class="alert-bank warning">
    <i class="bi bi-exclamation-triangle-fill"></i>
    <div><strong>Spending Limit Alert</strong> — You have used <strong><%= String.format("%.0f", limitUsedPct) %>%</strong>
    of your &#8377;<%= String.format("%,.0f", expenseLimit) %> monthly limit.
    <% if (thisMonthExpense >= expenseLimit) { %><span style="color:#C0392B;font-weight:700;"> Limit exceeded!</span><% } %></div>
</div>
<% } %>

<!-- Stat Cards -->
<div class="row g-3 mb-3">
    <div class="col-md-3">
        <div class="stat-card green">
            <div class="stat-icon green"><i class="bi bi-arrow-down-circle-fill"></i></div>
            <div class="stat-label">Monthly Income</div>
            <div class="stat-value" data-count="<%= monthlyIncome %>">&#8377;0</div>
            <div class="stat-sub"><% if (monthlyIncome == 0) { %><a href="SettingsServlet" style="color:#8B0000;font-size:0.72rem;font-weight:600;">Set income &rarr;</a><% } else { %>Fixed monthly income<% } %></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card red">
            <div class="stat-icon red"><i class="bi bi-arrow-up-circle-fill"></i></div>
            <div class="stat-label"><%= monthName %> Expenses</div>
            <div class="stat-value" data-count="<%= thisMonthExpense %>">&#8377;0</div>
            <div class="stat-sub"><% if (lastMonthExpense > 0) { %><span style="color:<%= monthChange>0?"#C0392B":"#1A7F4B" %>;font-weight:600;"><%= monthChange>0?"&#9650;":"&#9660;" %> <%= String.format("%.1f",Math.abs(monthChange)) %>% vs last month</span><% } else { %>No previous month data<% } %></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card blue">
            <div class="stat-icon blue"><i class="bi bi-wallet2"></i></div>
            <div class="stat-label">Balance This Month</div>
            <div class="stat-value" data-count="<%= Math.abs(balance) %>" style="color:<%= balance>=0?"#1A7F4B":"#C0392B" %>">&#8377;0</div>
            <div class="stat-sub"><% if (monthlyIncome==0) { %>Set income to calculate<% } else if (balance>=0) { %><span style="color:#1A7F4B;font-weight:600;">Surplus</span> &mdash; <%= String.format("%.1f",savingsRate) %>% saved<% } else { %><span style="color:#C0392B;font-weight:600;">Deficit</span> &mdash; overspent<% } %></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card maroon">
            <div class="stat-icon maroon"><i class="bi bi-receipt"></i></div>
            <div class="stat-label">Total Transactions</div>
            <div class="stat-value" data-count="<%= expenses.size() %>" data-prefix="" data-nodecimal="true">0</div>
            <div class="stat-sub">&#8377;<%= String.format("%,.0f",totalExpense) %> all time</div>
        </div>
    </div>
</div>

<!-- Expense Limit Tracker -->
<% if (expenseLimit > 0) { %>
<div class="bank-card mb-3">
    <div class="bank-card-header">
        <div class="bank-card-title"><i class="bi bi-speedometer2"></i> Monthly Expense Limit Tracker</div>
        <a href="SettingsServlet" style="font-size:0.775rem;color:#8B0000;text-decoration:none;font-weight:600;">Edit Limit <i class="bi bi-pencil"></i></a>
    </div>
    <div class="bank-card-body">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <div><span style="font-size:0.825rem;color:#4A4A4A;font-weight:500;">Spent: </span><span style="font-size:0.925rem;font-weight:700;color:<%= limitUsedPct>=100?"#C0392B":limitUsedPct>=80?"#B7770D":"#1A7F4B" %>">&#8377;<%= String.format("%,.2f",thisMonthExpense) %></span></div>
            <div><span style="font-size:0.825rem;color:#4A4A4A;font-weight:500;">Limit: </span><span style="font-size:0.925rem;font-weight:700;color:#1A1A1A;">&#8377;<%= String.format("%,.2f",expenseLimit) %></span></div>
            <div><span style="font-size:0.825rem;color:#4A4A4A;font-weight:500;">Remaining: </span><span style="font-size:0.925rem;font-weight:700;color:<%= expenseLimit-thisMonthExpense>=0?"#1A7F4B":"#C0392B" %>">&#8377;<%= String.format("%,.2f",Math.abs(expenseLimit-thisMonthExpense)) %><%= expenseLimit-thisMonthExpense<0?" (Exceeded)":"" %></span></div>
            <div style="background:<%= limitUsedPct>=100?"#FDECEA":limitUsedPct>=80?"#FEF9EE":"#E8F5EE" %>;border-radius:20px;padding:4px 12px;font-size:0.78rem;font-weight:700;color:<%= limitUsedPct>=100?"#C0392B":limitUsedPct>=80?"#B7770D":"#1A7F4B" %>"><%= String.format("%.0f",limitUsedPct) %>% used</div>
        </div>
        <div class="progress-bar-wrap"><div class="progress-bar-fill" style="width:<%= String.format("%.1f",limitUsedPct) %>%;background:<%= limitUsedPct>=100?"#C0392B":limitUsedPct>=80?"#D97706":"#1A7F4B" %>"></div></div>
    </div>
</div>
<% } else { %>
<div class="bank-card mb-3" style="border:1px dashed #DDD;background:#FAFAFA;">
    <div class="bank-card-body" style="text-align:center;padding:18px;">
        <i class="bi bi-speedometer2" style="font-size:1.5rem;color:#CCC;margin-bottom:8px;display:block;"></i>
        <p style="font-size:0.825rem;color:#8A8A9A;margin-bottom:10px;">No expense limit set.</p>
        <a href="SettingsServlet" class="btn-maroon" style="font-size:0.825rem;padding:8px 16px;"><i class="bi bi-sliders"></i> Set Limit Now</a>
    </div>
</div>
<% } %>

<%@ include file="spendingTrendChart.jsp" %>

<div class="row g-3">
    <!-- Recent Transactions -->
    <div class="col-lg-7">
        <div class="bank-card">
            <div class="bank-card-header">
                <div class="bank-card-title"><i class="bi bi-clock-history"></i> Recent Transactions</div>
                <a href="ViewExpensesServlet" style="font-size:0.775rem;color:#8B0000;text-decoration:none;font-weight:600;">View All <i class="bi bi-arrow-right"></i></a>
            </div>
            <% if (recent.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-state-icon"><i class="bi bi-inbox"></i></div>
                <div class="empty-state-title">No Transactions Yet</div>
                <div class="empty-state-sub">Add your first expense to see it here</div>
                <a href="AddExpenseServlet" class="btn-maroon" style="font-size:0.825rem;padding:9px 18px;"><i class="bi bi-plus-lg"></i> Add Transaction</a>
            </div>
            <% } else { for (Expense e : recent) {
                String cat  = e.getCategory() != null ? e.getCategory() : "Others";
                String icon = catIcons.getOrDefault(cat, "bi-grid-fill");
                String cls  = catClass.getOrDefault(cat, "default"); %>
            <div style="display:flex;align-items:center;gap:14px;padding:13px 20px;border-bottom:1px solid #F5F5F5;">
                <div class="txn-icon cat-badge <%= cls %>" style="width:36px;height:36px;border-radius:10px;padding:0;justify-content:center;"><i class="bi <%= icon %>"></i></div>
                <div style="flex:1;"><div class="txn-title"><%= e.getTitle() %></div><div class="txn-id"><%= e.getDate() %> &nbsp;&#183;&nbsp; <%= cat %></div></div>
                <div class="amount-debit">- &#8377;<%= String.format("%,.2f",e.getAmount()) %></div>
            </div>
            <% } } %>
        </div>
    </div>

    <!-- Right column -->
    <div class="col-lg-5 d-flex flex-column gap-3">

        <!-- NSE-style Category Breakdown Table -->
        <div class="bank-card">
            <div class="bank-card-header">
                <div class="bank-card-title"><i class="bi bi-table"></i> Category Breakdown</div>
                <div style="display:flex;gap:4px;">
                    <button class="sc-toggle active" id="nseMonthBtn" onclick="switchNse('month')">This Month</button>
                    <button class="sc-toggle"        id="nseYearBtn"  onclick="switchNse('year')">This Year</button>
                </div>
            </div>
            <% if (catMapMonth.isEmpty() && catMapYear.isEmpty()) { %>
            <div class="empty-state" style="padding:24px;"><div class="empty-state-sub">No transactions yet</div></div>
            <% } else { %>
            <!-- Table header -->
            <div style="display:grid;grid-template-columns:1fr 80px 60px 72px;gap:0;padding:7px 16px;background:#F8F9FA;border-bottom:2px solid #8B0000;">
                <div style="font-size:0.62rem;font-weight:700;letter-spacing:0.8px;text-transform:uppercase;color:#8B0000;">CATEGORY</div>
                <div style="font-size:0.62rem;font-weight:700;letter-spacing:0.8px;text-transform:uppercase;color:#8B0000;text-align:right;">AMOUNT</div>
                <div style="font-size:0.62rem;font-weight:700;letter-spacing:0.8px;text-transform:uppercase;color:#8B0000;text-align:right;">% SPENT</div>
                <div style="font-size:0.62rem;font-weight:700;letter-spacing:0.8px;text-transform:uppercase;color:#8B0000;text-align:right;">VS LAST</div>
            </div>
            <!-- Month rows -->
            <div id="nseMonthRows">
            <%
                double mTotal = catMapMonth.values().stream().mapToDouble(Double::doubleValue).sum();
                for (Map.Entry<String,Double> e : catMapMonth.entrySet()) {
                    double pct     = mTotal > 0 ? (e.getValue() / mTotal * 100) : 0;
                    String catName = e.getKey();
                    String iconCls = catIcons.getOrDefault(catName, "bi-grid-fill");
                    String badgeCls= catClass.getOrDefault(catName, "default");
                    // vs last month for same category
                    double lastVal = 0;
                    for (Expense ex : expenses) {
                        if (ex.getDate() != null && ex.getCategory() != null &&
                            ex.getCategory().equals(catName)) {
                            java.time.LocalDate d = ex.getDate().toLocalDate();
                            if (d.getMonthValue() == lastMonth && d.getYear() == lastMonthYear)
                                lastVal += ex.getAmount();
                        }
                    }
                    double chg = lastVal > 0 ? ((e.getValue() - lastVal) / lastVal * 100) : 0;
                    boolean hasLast = lastVal > 0;
            %>
            <div style="display:grid;grid-template-columns:1fr 80px 60px 72px;gap:0;padding:10px 16px;border-bottom:1px solid #F5F5F5;transition:background 0.12s;" onmouseover="this.style.background='#FAFAFA'" onmouseout="this.style.background=''">
                <div style="display:flex;align-items:center;gap:8px;">
                    <div class="cat-badge <%= badgeCls %>" style="width:26px;height:26px;border-radius:7px;padding:0;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                        <i class="bi <%= iconCls %>" style="font-size:0.72rem;"></i>
                    </div>
                    <span style="font-size:0.825rem;font-weight:600;color:#1A1A1A;"><%= catName %></span>
                </div>
                <div style="text-align:right;font-size:0.825rem;font-weight:700;color:#1A1A1A;">&#8377;<%= String.format("%,.0f", e.getValue()) %></div>
                <div style="text-align:right;font-size:0.78rem;font-weight:600;color:#8A8A9A;"><%= String.format("%.1f", pct) %>%</div>
                <div style="text-align:right;font-size:0.775rem;font-weight:700;color:<%= !hasLast ? "#AAAAAA" : chg > 0 ? "#C0392B" : "#1A7F4B" %>;">
                    <% if (!hasLast) { %><span style="color:#CCC;">—</span>
                    <% } else { %>
                        <%= chg > 0 ? "&#9650;" : "&#9660;" %> <%= String.format("%.1f", Math.abs(chg)) %>%
                    <% } %>
                </div>
            </div>
            <% } %>
            </div>
            <!-- Year rows (hidden by default) -->
            <div id="nseYearRows" style="display:none;">
            <%
                double yTotal = catMapYear.values().stream().mapToDouble(Double::doubleValue).sum();
                for (Map.Entry<String,Double> e : catMapYear.entrySet()) {
                    double pct     = yTotal > 0 ? (e.getValue() / yTotal * 100) : 0;
                    String catName = e.getKey();
                    String iconCls = catIcons.getOrDefault(catName, "bi-grid-fill");
                    String badgeCls= catClass.getOrDefault(catName, "default");
            %>
            <div style="display:grid;grid-template-columns:1fr 80px 60px 72px;gap:0;padding:10px 16px;border-bottom:1px solid #F5F5F5;transition:background 0.12s;" onmouseover="this.style.background='#FAFAFA'" onmouseout="this.style.background=''">
                <div style="display:flex;align-items:center;gap:8px;">
                    <div class="cat-badge <%= badgeCls %>" style="width:26px;height:26px;border-radius:7px;padding:0;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                        <i class="bi <%= iconCls %>" style="font-size:0.72rem;"></i>
                    </div>
                    <span style="font-size:0.825rem;font-weight:600;color:#1A1A1A;"><%= catName %></span>
                </div>
                <div style="text-align:right;font-size:0.825rem;font-weight:700;color:#1A1A1A;">&#8377;<%= String.format("%,.0f", e.getValue()) %></div>
                <div style="text-align:right;font-size:0.78rem;font-weight:600;color:#8A8A9A;"><%= String.format("%.1f", pct) %>%</div>
                <div style="text-align:right;font-size:0.775rem;color:#AAAAAA;">—</div>
            </div>
            <% } %>
            </div>
            <!-- Total row -->
            <div id="nseTotalMonth" style="display:grid;grid-template-columns:1fr 80px 60px 72px;padding:10px 16px;background:#FFF9F9;border-top:2px solid #E2E5EA;">
                <div style="font-size:0.825rem;font-weight:700;color:#8B0000;">TOTAL</div>
                <div style="text-align:right;font-size:0.825rem;font-weight:800;color:#8B0000;">&#8377;<%= String.format("%,.0f", mTotal) %></div>
                <div style="text-align:right;font-size:0.78rem;font-weight:600;color:#8A8A9A;">100%</div>
                <div></div>
            </div>
            <div id="nseTotalYear" style="display:none;grid-template-columns:1fr 80px 60px 72px;padding:10px 16px;background:#FFF9F9;border-top:2px solid #E2E5EA;">
                <div style="font-size:0.825rem;font-weight:700;color:#8B0000;">TOTAL</div>
                <div style="text-align:right;font-size:0.825rem;font-weight:800;color:#8B0000;">&#8377;<%= String.format("%,.0f", yTotal) %></div>
                <div style="text-align:right;font-size:0.78rem;font-weight:600;color:#8A8A9A;">100%</div>
                <div></div>
            </div>
            <% } %>
        </div>

        <!-- Savings Goal Tracker -->
        <div class="bank-card">
            <div class="bank-card-header">
                <div class="bank-card-title"><i class="bi bi-piggy-bank-fill"></i> Savings Goal</div>
                <span id="savingsStatusBadge" style="font-size:0.7rem;border-radius:20px;padding:3px 9px;font-weight:600;border:1px solid;"></span>
            </div>
            <div style="padding:16px 18px;">
                <% if (monthlyIncome <= 0) { %>
                <div style="text-align:center;padding:16px 0;">
                    <i class="bi bi-piggy-bank" style="font-size:1.8rem;color:#CCC;display:block;margin-bottom:8px;"></i>
                    <p style="font-size:0.8rem;color:#8A8A9A;margin-bottom:10px;">Set your monthly income to track savings.</p>
                    <a href="SettingsServlet" class="btn-maroon" style="font-size:0.8rem;padding:7px 14px;"><i class="bi bi-sliders"></i> Set Income</a>
                </div>
                <% } else {
                    double goalAmt    = monthlyIncome * 0.20; // 20% savings goal
                    double savedAmt   = Math.max(0, monthlyIncome - thisMonthExpense);
                    double goalPct    = Math.min((savedAmt / goalAmt) * 100, 100);
                    String goalColor  = goalPct >= 100 ? "#1A7F4B" : goalPct >= 50 ? "#F39C12" : "#C0392B";
                    String goalBg     = goalPct >= 100 ? "#E8F5EE" : goalPct >= 50 ? "#FEF9EE" : "#FDECEA";
                    String goalBorder = goalPct >= 100 ? "rgba(26,127,75,0.2)" : goalPct >= 50 ? "rgba(183,119,13,0.2)" : "rgba(192,57,43,0.2)";
                    String goalLabel  = goalPct >= 100 ? "🎯 Goal Reached!" : goalPct >= 50 ? "On Track" : "Needs Attention";
                %>
                <!-- Goal progress -->
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
                    <div>
                        <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;color:#8A8A9A;margin-bottom:3px;">Saved This Month</div>
                        <div style="font-family:'DM Sans',sans-serif;font-size:1.4rem;font-weight:800;color:<%= goalColor %>;">&#8377;<%= String.format("%,.0f", savedAmt) %></div>
                    </div>
                    <div style="text-align:right;">
                        <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;color:#8A8A9A;margin-bottom:3px;">Goal (20%)</div>
                        <div style="font-family:'DM Sans',sans-serif;font-size:1rem;font-weight:700;color:#1A1A1A;">&#8377;<%= String.format("%,.0f", goalAmt) %></div>
                    </div>
                </div>
                <!-- Progress bar -->
                <div style="margin-bottom:10px;">
                    <div style="display:flex;justify-content:space-between;margin-bottom:5px;">
                        <span style="font-size:0.7rem;color:#8A8A9A;">Progress</span>
                        <span style="font-size:0.7rem;font-weight:700;color:<%= goalColor %>;"><%= String.format("%.0f", goalPct) %>%</span>
                    </div>
                    <div style="background:#F0F2F5;border-radius:6px;height:10px;overflow:hidden;">
                        <div style="width:<%= String.format("%.1f", goalPct) %>%;height:100%;background:<%= goalColor %>;border-radius:6px;transition:width 0.6s ease;"></div>
                    </div>
                </div>
                <!-- Stats row -->
                <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;margin-top:12px;">
                    <div style="background:#F8F9FA;border-radius:8px;padding:10px;text-align:center;">
                        <div style="font-size:0.62rem;color:#8A8A9A;font-weight:600;text-transform:uppercase;margin-bottom:3px;">Income</div>
                        <div style="font-size:0.82rem;font-weight:700;color:#1A1A1A;">&#8377;<%= String.format("%,.0f", monthlyIncome) %></div>
                    </div>
                    <div style="background:#F8F9FA;border-radius:8px;padding:10px;text-align:center;">
                        <div style="font-size:0.62rem;color:#8A8A9A;font-weight:600;text-transform:uppercase;margin-bottom:3px;">Spent</div>
                        <div style="font-size:0.82rem;font-weight:700;color:#C0392B;">&#8377;<%= String.format("%,.0f", thisMonthExpense) %></div>
                    </div>
                    <div style="background:#F8F9FA;border-radius:8px;padding:10px;text-align:center;">
                        <div style="font-size:0.62rem;color:#8A8A9A;font-weight:600;text-transform:uppercase;margin-bottom:3px;">Saved</div>
                        <div style="font-size:0.82rem;font-weight:700;color:<%= goalColor %>;">&#8377;<%= String.format("%,.0f", savedAmt) %></div>
                    </div>
                </div>
                <% if (savedAmt < goalAmt) { %>
                <div style="margin-top:12px;background:<%= goalBg %>;border:1px solid <%= goalBorder %>;border-radius:8px;padding:9px 12px;font-size:0.775rem;color:<%= goalColor %>;font-weight:500;">
                    <i class="bi bi-info-circle-fill"></i>
                    Save &#8377;<%= String.format("%,.0f", goalAmt - savedAmt) %> more to hit your 20% goal this month.
                </div>
                <% } else { %>
                <div style="margin-top:12px;background:#E8F5EE;border:1px solid rgba(26,127,75,0.2);border-radius:8px;padding:9px 12px;font-size:0.775rem;color:#1A7F4B;font-weight:500;">
                    <i class="bi bi-trophy-fill"></i> You've hit your 20% savings goal this month! Great job.
                </div>
                <% } %>
                <script>
                (function(){
                    const badge = document.getElementById('savingsStatusBadge');
                    badge.textContent  = '<%= goalLabel %>';
                    badge.style.background = '<%= goalBg %>';
                    badge.style.color      = '<%= goalColor %>';
                    badge.style.borderColor= '<%= goalBorder %>';
                })();
                </script>
                <% } %>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
// 1. GREETING
(function() {
    const h = new Date().getHours();
    let emoji, text;
    if      (h >= 5  && h < 12) { emoji = '\u2600\uFE0F '; text = 'Good Morning'; }
    else if (h >= 12 && h < 17) { emoji = '\uD83D\uDC4B '; text = 'Good Afternoon'; }
    else if (h >= 17 && h < 21) { emoji = '\uD83C\uDF06 '; text = 'Good Evening'; }
    else                         { emoji = '\uD83C\uDF19 '; text = 'Good Night'; }
    document.getElementById('greetingEmoji').textContent = emoji;
    document.getElementById('greetingText').textContent  = text;
})();

// 2. ANIMATED COUNTING
function animateCount(el, target, duration) {
    const prefix    = el.dataset.prefix !== undefined ? el.dataset.prefix : '\u20B9';
    const noDecimal = el.dataset.nodecimal === 'true';
    const startTime = performance.now();
    (function update(now) {
        const ease    = 1 - Math.pow(1 - Math.min((now - startTime) / duration, 1), 3);
        const current = target * ease;
        el.textContent = noDecimal
            ? prefix + Math.round(current).toLocaleString('en-IN')
            : prefix + current.toLocaleString('en-IN', { maximumFractionDigits: 0 });
        if (ease < 1) requestAnimationFrame(update);
    })(performance.now());
}
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.stat-value[data-count]').forEach(el => {
        animateCount(el, parseFloat(el.dataset.count) || 0, 1200);
    });
});

// 3. NSE TABLE TOGGLE
function switchNse(view) {
    document.getElementById('nseMonthBtn').classList.toggle('active', view === 'month');
    document.getElementById('nseYearBtn').classList.toggle('active',  view === 'year');
    document.getElementById('nseMonthRows').style.display  = view === 'month' ? 'block' : 'none';
    document.getElementById('nseYearRows').style.display   = view === 'year'  ? 'block' : 'none';
    document.getElementById('nseTotalMonth').style.display = view === 'month' ? 'grid'  : 'none';
    document.getElementById('nseTotalYear').style.display  = view === 'year'  ? 'grid'  : 'none';
}
</script>
