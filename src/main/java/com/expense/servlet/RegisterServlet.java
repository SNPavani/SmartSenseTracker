package com.expense.servlet;

import com.expense.dao.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import at.favre.lib.crypto.bcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Fix 1: Validate inputs server side
        if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.length() < 6) {

            request.setAttribute("error", "All fields are required and password must be at least 6 characters.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Fix 2: Check if email already exists
            PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM users WHERE email = ?");
            check.setString(1, email.trim());
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                request.setAttribute("error", "An account with this email already exists.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Fix 3: Hash the password before storing
            String hashedPassword = BCrypt.withDefaults().hashToString(12, password.toCharArray());

            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
            ps.setString(1, name.trim());
            ps.setString(2, email.trim());
            ps.setString(3, hashedPassword);
            ps.executeUpdate();

            // Fix 4: Signal success to login page
            response.sendRedirect("login.jsp?registered=true");

        } catch (Exception e) {
            e.printStackTrace();
            // Fix 5: Handle exception instead of silently failing
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}