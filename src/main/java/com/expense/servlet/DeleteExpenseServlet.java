package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/DeleteExpenseServlet")
public class DeleteExpenseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Fix 1: Validate id parameter before parsing
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("ViewExpensesServlet");
            return;
        }

        int expenseId;
        // Fix 2: Catch parse error separately
        try {
            expenseId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("ViewExpensesServlet");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(  // Fix 3: ps in try-with-resources
                     "DELETE FROM expenses WHERE id = ? AND user_id = ?")) {

            ps.setInt(1, expenseId);
            ps.setInt(2, userId);

            int rows = ps.executeUpdate();

            // Fix 4: Check if delete actually affected a row
            if (rows == 0) {
                response.sendRedirect("ViewExpensesServlet?error=not_found");
                return;
            }

            // Fix 5: Pass success message
            response.sendRedirect("ViewExpensesServlet?success=deleted");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ViewExpensesServlet?error=delete");
        }
    }
}