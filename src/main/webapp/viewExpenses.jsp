You need to replace the entire content of viewExpenses.jsp with this — it fetches the expenses before forwarding:
jsp<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="com.expense.model.Expense" %>
<%@ page import="com.expense.dao.DatabaseConnection" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Expense> expenses = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT e.id, e.title, e.amount, e.date, c.name AS category " +
             "FROM expenses e JOIN categories c ON e.category_id = c.id " +
             "WHERE e.user_id = ?")) {

        ps.setInt(1, (int) session.getAttribute("userId"));
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            expenses.add(new Expense(
                rs.getInt("id"),
                rs.getString("title"),
                rs.getDouble("amount"),
                rs.getString("date"),        // comes as String from query alias
                rs.getString("category")     // aliased column from JOIN
            ));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    request.setAttribute("expenses", expenses);
    request.setAttribute("contentPage", "viewExpensesContent.jsp");
    request.getRequestDispatcher("base.jsp").forward(request, response);
%>