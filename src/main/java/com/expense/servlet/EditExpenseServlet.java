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

@WebServlet("/EditExpenseServlet")
public class EditExpenseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("ViewExpensesServlet");
            return;
        }

        try {
            Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("ViewExpensesServlet");
            return;
        }

        request.setAttribute("contentPage", "editExpenseContent.jsp");
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

        String expenseIdParam  = request.getParameter("expenseId");
        String amountParam     = request.getParameter("amount");
        String categoryIdParam = request.getParameter("categoryId");
        String title           = request.getParameter("title");
        String date            = request.getParameter("date");

        if (expenseIdParam == null || amountParam == null || categoryIdParam == null
                || title == null || title.trim().isEmpty()
                || date == null || date.isEmpty()) {
            response.sendRedirect("ViewExpensesServlet");
            return;
        }

        int expenseId, categoryId;
        double amount;

        try {
            expenseId  = Integer.parseInt(expenseIdParam);
            amount     = Double.parseDouble(amountParam);
            categoryId = Integer.parseInt(categoryIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("ViewExpensesServlet");
            return;
        }

        if (amount <= 0) {
            response.sendRedirect("EditExpenseServlet?id=" + expenseIdParam + "&error=invalid_amount");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        Expense expense = new Expense();
        expense.setId(expenseId);
        expense.setTitle(title.trim());
        expense.setAmount(amount);
        expense.setDate(Date.valueOf(date));
        expense.setCategoryId(categoryId);

        try (Connection conn = DatabaseConnection.getConnection()) {
            ExpenseDAO dao = new ExpenseDAO(conn);

            if (dao.updateExpense(expense, userId)) {
                response.sendRedirect("ViewExpensesServlet?success=updated");
            } else {
                response.sendRedirect("EditExpenseServlet?id=" + expenseId + "&error=not_found");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("EditExpenseServlet?id=" + expenseId + "&error=server_error");
        }
    }
}