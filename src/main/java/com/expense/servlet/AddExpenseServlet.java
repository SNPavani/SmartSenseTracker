package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import com.expense.dao.ExpenseDAO;
import com.expense.model.Expense;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;

@WebServlet("/AddExpenseServlet")
public class AddExpenseServlet extends HttpServlet {

    // Add this doGet method
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

        request.setAttribute("contentPage", "addExpenseContent.jsp");
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

        String title       = request.getParameter("title");
        String amountParam = request.getParameter("amount");
        String dateParam   = request.getParameter("date");
        String catParam    = request.getParameter("categoryId");

        if (title == null || title.trim().isEmpty() ||
                amountParam == null || amountParam.isEmpty() ||
                dateParam == null || dateParam.isEmpty() ||
                catParam == null || catParam.isEmpty()) {
            response.sendRedirect("AddExpenseServlet?error=missing_fields");
            return;
        }

        double amount;
        Date date;
        int categoryId;

        try {
            amount     = Double.parseDouble(amountParam);
            date       = Date.valueOf(dateParam);
            categoryId = Integer.parseInt(catParam);
        } catch (IllegalArgumentException e) {
            response.sendRedirect("AddExpenseServlet?error=invalid_input");
            return;
        }

        if (amount <= 0) {
            response.sendRedirect("AddExpenseServlet?error=invalid_amount");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        Expense expense = new Expense();
        expense.setTitle(title.trim());
        expense.setAmount(amount);
        expense.setDate(date);
        expense.setCategoryId(categoryId);

        try (Connection conn = DatabaseConnection.getConnection()) {
            ExpenseDAO dao = new ExpenseDAO(conn);

            if (dao.addExpense(expense, userId)) {
                response.sendRedirect("ViewExpensesServlet?success=added");
            } else {
                response.sendRedirect("AddExpenseServlet?error=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AddExpenseServlet?error=server_error");
        }
    }
}