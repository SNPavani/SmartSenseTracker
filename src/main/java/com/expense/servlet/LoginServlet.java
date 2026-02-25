package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import at.favre.lib.crypto.bcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String identifier = request.getParameter("identifier");  // email
        String password = request.getParameter("password");

        // referencing undefined "email" variable
        if (identifier == null || identifier.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=true");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     //  supports both email AND username login
                     "SELECT id, name, password FROM users WHERE email = ? OR username = ?")) {

            ps.setString(1, identifier.trim());
            ps.setString(2, identifier.trim());  // second parameter for username
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");

                BCrypt.Result result = BCrypt.verifyer().verify(password.toCharArray(), hashedPassword);
                if (result.verified) {
                    HttpSession session = request.getSession();
                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("userName", rs.getString("name"));
                    response.sendRedirect("DashboardServlet");
                } else {
                    response.sendRedirect("login.jsp?error=true");
                }
            } else {
                response.sendRedirect("login.jsp?error=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=true");
        }
    }
}