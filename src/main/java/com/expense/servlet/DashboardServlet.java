package com.expense.servlet;  // Fix 1: was 'servlets' (plural), must match your folder structure

import com.expense.dao.DatabaseConnection;
import com.expense.dao.ExpenseDAO;
import com.expense.model.Expense;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;  // Fix 2: missing import

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

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

        int userId = (int) session.getAttribute("userId");

        try (Connection conn = DatabaseConnection.getConnection()) {
            ExpenseDAO dao = new ExpenseDAO(conn);
            List<Expense> expenses = dao.getAllExpenses(userId);
            double total = dao.getTotalExpenses(userId);

            request.setAttribute("expenses", expenses);  // Fix 4: data was never loaded
            request.setAttribute("totalSpent", total);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("contentPage", "dashboardContent.jsp");
        request.getRequestDispatcher("base.jsp").forward(request, response);
    }
}