package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import com.expense.dao.ExpenseDAO;
import com.expense.model.Expense;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/ViewExpensesServlet")
public class ViewExpensesServlet extends HttpServlet {

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

            request.setAttribute("expenses", expenses);
            request.setAttribute("contentPage", "viewExpensesContent.jsp");  // Fix 1
            request.getRequestDispatcher("base.jsp").forward(request, response);  // Fix 2

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to fetch expenses.");
            request.setAttribute("contentPage", "viewExpensesContent.jsp");  // Fix 3
            request.getRequestDispatcher("base.jsp").forward(request, response);
        }
    }
}