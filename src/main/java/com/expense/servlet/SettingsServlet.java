package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/SettingsServlet")
public class SettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.setAttribute("contentPage", "settingsContent.jsp");
        request.getRequestDispatcher("base.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        String incomeParam = request.getParameter("monthlyIncome");
        String limitParam  = request.getParameter("expenseLimit");

        double monthlyIncome = 0, expenseLimit = 0;

        try {
            if (incomeParam != null && !incomeParam.isEmpty())
                monthlyIncome = Double.parseDouble(incomeParam);
            if (limitParam != null && !limitParam.isEmpty())
                expenseLimit = Double.parseDouble(limitParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("SettingsServlet?error=invalid");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE users SET monthly_income=?, expense_limit=? WHERE id=?")) {
            ps.setDouble(1, monthlyIncome);
            ps.setDouble(2, expenseLimit);
            ps.setInt(3, userId);
            ps.executeUpdate();
            response.sendRedirect("SettingsServlet?success=saved");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SettingsServlet?error=failed");
        }
    }
}
