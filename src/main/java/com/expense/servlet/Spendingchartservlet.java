package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;

@WebServlet("/SpendingChartServlet")
public class Spendingchartservlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            response.setStatus(401);
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        int userId = (int) session.getAttribute("userId");
        String view = request.getParameter("view"); // day, week, month, year
        if (view == null) view = "month";

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection conn = DatabaseConnection.getConnection()) {
            StringBuilder labels = new StringBuilder();
            StringBuilder values = new StringBuilder();
            String sql;
            LocalDate now = LocalDate.now();

            switch (view) {

                // Last 30 days — one point per day
                case "day":
                    sql = "SELECT DATE(expense_date) as d, SUM(amount) as total " +
                            "FROM expenses WHERE user_id = ? " +
                            "AND expense_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
                            "GROUP BY DATE(expense_date) ORDER BY d";
                    break;

                // Last 12 weeks — one point per week
                case "week":
                    sql = "SELECT YEARWEEK(expense_date, 1) as wk, SUM(amount) as total " +
                            "FROM expenses WHERE user_id = ? " +
                            "AND expense_date >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK) " +
                            "GROUP BY YEARWEEK(expense_date, 1) ORDER BY wk";
                    break;

                // Last 3 years — one point per year
                case "year":
                    sql = "SELECT YEAR(expense_date) as yr, SUM(amount) as total " +
                            "FROM expenses WHERE user_id = ? " +
                            "AND expense_date >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR) " +
                            "GROUP BY YEAR(expense_date) ORDER BY yr";
                    break;

                // Default: Last 12 months — one point per month
                default:
                    sql = "SELECT DATE_FORMAT(expense_date,'%Y-%m') as mo, SUM(amount) as total " +
                            "FROM expenses WHERE user_id = ? " +
                            "AND expense_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) " +
                            "GROUP BY DATE_FORMAT(expense_date,'%Y-%m') ORDER BY mo";
                    break;
            }

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            boolean first = true;
            double runningTotal = 0;

            while (rs.next()) {
                if (!first) { labels.append(","); values.append(","); }

                String label;
                switch (view) {
                    case "day":
                        // Format: "15 Jan"
                        java.sql.Date d = rs.getDate("d");
                        LocalDate ld = d.toLocalDate();
                        label = "\"" + ld.getDayOfMonth() + " " +
                                ld.getMonth().getDisplayName(java.time.format.TextStyle.SHORT,
                                        java.util.Locale.ENGLISH) + "\"";
                        break;
                    case "week":
                        label = "\"W" + rs.getString("wk").substring(4) + " " +
                                rs.getString("wk").substring(0, 4) + "\"";
                        break;
                    case "year":
                        label = "\"" + rs.getString("yr") + "\"";
                        break;
                    default:
                        // Format: "Jan 2025"
                        String mo = rs.getString("mo"); // "2025-01"
                        String[] parts = mo.split("-");
                        LocalDate ld2 = LocalDate.of(Integer.parseInt(parts[0]),
                                Integer.parseInt(parts[1]), 1);
                        label = "\"" + ld2.getMonth().getDisplayName(java.time.format.TextStyle.SHORT,
                                java.util.Locale.ENGLISH) + " " + parts[0] + "\"";
                        break;
                }

                double amount = rs.getDouble("total");
                runningTotal += amount;

                labels.append(label);
                values.append(String.format("%.2f", amount));
                first = false;
            }

            // Also return total for display
            out.print("{\"labels\":[" + labels + "],\"values\":[" + values + "]," +
                    "\"total\":" + String.format("%.2f", runningTotal) + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"labels\":[],\"values\":[],\"total\":0}");
        }
    }
}