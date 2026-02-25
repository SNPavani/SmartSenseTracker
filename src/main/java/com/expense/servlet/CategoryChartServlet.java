package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/CategoryChartServlet")
public class CategoryChartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(401);
            return;
        }

        int userId = (int) session.getAttribute("userId");
        PrintWriter out = response.getWriter();

        // summary=all → return yearly totals for the overview chart
        String summary = request.getParameter("summary");
        if ("all".equals(summary)) {
            handleSummaryAll(userId, out);
            return;
        }

        // year-specific monthly category breakdown
        int year;
        try {
            String y = request.getParameter("year");
            year = (y != null && !y.isEmpty()) ? Integer.parseInt(y) : java.time.LocalDate.now().getYear();
        } catch (NumberFormatException e) {
            year = java.time.LocalDate.now().getYear();
        }

        handleYear(userId, year, out);
    }

    /* Returns: { years:[2023,2024,...], yearTotals:[1200,3400,...] } */
    private void handleSummaryAll(int userId, PrintWriter out) {
        try (Connection conn = DatabaseConnection.getConnection()) {

            // All years with data
            String sql = "SELECT YEAR(expense_date) as yr, SUM(amount) as total " +
                    "FROM expenses WHERE user_id = ? " +
                    "GROUP BY YEAR(expense_date) ORDER BY yr DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            StringBuilder years  = new StringBuilder();
            StringBuilder totals = new StringBuilder();
            boolean first = true;
            while (rs.next()) {
                if (!first) { years.append(","); totals.append(","); }
                years.append(rs.getInt("yr"));
                totals.append(String.format("%.2f", rs.getDouble("total")));
                first = false;
            }
            out.print("{\"years\":[" + years + "],\"yearTotals\":[" + totals + "]}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"years\":[],\"yearTotals\":[]}");
        }
    }

    /* Returns full monthly-category breakdown for one year */
    private void handleYear(int userId, int year, PrintWriter out) {
        try (Connection conn = DatabaseConnection.getConnection()) {

            // Categories that have data this year
            String catSql = "SELECT DISTINCT c.name FROM categories c " +
                    "JOIN expenses e ON e.category_id = c.id " +
                    "WHERE e.user_id = ? AND YEAR(e.expense_date) = ? ORDER BY c.name";
            PreparedStatement catPs = conn.prepareStatement(catSql);
            catPs.setInt(1, userId);
            catPs.setInt(2, year);
            ResultSet catRs = catPs.executeQuery();

            java.util.List<String> catList = new java.util.ArrayList<>();
            while (catRs.next()) catList.add(catRs.getString("name"));

            // Monthly totals per category
            String sql = "SELECT MONTH(e.expense_date) as mo, c.name as cat, SUM(e.amount) as total " +
                    "FROM expenses e JOIN categories c ON e.category_id = c.id " +
                    "WHERE e.user_id = ? AND YEAR(e.expense_date) = ? " +
                    "GROUP BY MONTH(e.expense_date), c.name ORDER BY mo, c.name";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, year);
            ResultSet rs = ps.executeQuery();

            double[][] grid = new double[13][catList.size()];
            while (rs.next()) {
                int mo     = rs.getInt("mo");
                String cat = rs.getString("cat");
                double amt = rs.getDouble("total");
                int idx    = catList.indexOf(cat);
                if (idx >= 0 && mo >= 1 && mo <= 12) grid[mo][idx] = amt;
            }

            // All years for pills
            String yearSql = "SELECT DISTINCT YEAR(expense_date) as yr FROM expenses " +
                    "WHERE user_id = ? ORDER BY yr DESC";
            PreparedStatement yearPs = conn.prepareStatement(yearSql);
            yearPs.setInt(1, userId);
            ResultSet yearRs = yearPs.executeQuery();
            StringBuilder yearsSb = new StringBuilder();
            boolean fy = true;
            while (yearRs.next()) {
                if (!fy) yearsSb.append(",");
                yearsSb.append(yearRs.getInt("yr"));
                fy = false;
            }

            // Category totals for the year (for ranking)
            String totalSql = "SELECT c.name, SUM(e.amount) as total FROM expenses e " +
                    "JOIN categories c ON e.category_id = c.id " +
                    "WHERE e.user_id = ? AND YEAR(e.expense_date) = ? " +
                    "GROUP BY c.name ORDER BY total DESC";
            PreparedStatement totalPs = conn.prepareStatement(totalSql);
            totalPs.setInt(1, userId);
            totalPs.setInt(2, year);
            ResultSet totalRs = totalPs.executeQuery();
            StringBuilder catTotals = new StringBuilder();
            boolean ft = true;
            while (totalRs.next()) {
                if (!ft) catTotals.append(",");
                catTotals.append("{\"name\":\"").append(totalRs.getString("name"))
                        .append("\",\"total\":").append(String.format("%.2f", totalRs.getDouble("total")))
                        .append("}");
                ft = false;
            }

            // Build JSON
            StringBuilder json = new StringBuilder();
            json.append("{\"year\":").append(year).append(",");
            json.append("\"years\":[").append(yearsSb).append("],");
            json.append("\"months\":[\"Jan\",\"Feb\",\"Mar\",\"Apr\",\"May\",\"Jun\",\"Jul\",\"Aug\",\"Sep\",\"Oct\",\"Nov\",\"Dec\"],");
            json.append("\"categories\":[");
            for (int i = 0; i < catList.size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(catList.get(i)).append("\"");
            }
            json.append("],");
            json.append("\"datasets\":[");
            for (int c = 0; c < catList.size(); c++) {
                if (c > 0) json.append(",");
                json.append("{\"label\":\"").append(catList.get(c)).append("\",\"data\":[");
                for (int m = 1; m <= 12; m++) {
                    if (m > 1) json.append(",");
                    json.append(String.format("%.2f", grid[m][c]));
                }
                json.append("]}");
            }
            json.append("],\"categoryTotals\":[").append(catTotals).append("]}");

            out.print(json);

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"categories\":[],\"datasets\":[],\"months\":[],\"years\":[],\"categoryTotals\":[]}");
        }
    }
}
