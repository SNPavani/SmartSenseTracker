package com.expense.dao;

import com.expense.model.Expense;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExpenseDAO {
    private Connection conn;

    public ExpenseDAO(Connection conn) {
        this.conn = conn;
    }

    // Add expense
    public boolean addExpense(Expense expense, int userId) {
        String sql = "INSERT INTO expenses (user_id, title, amount, expense_date, category_id) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setInt(1, userId);
            pst.setString(2, expense.getTitle());
            pst.setDouble(3, expense.getAmount());
            pst.setDate(4, expense.getDate());
            pst.setInt(5, expense.getCategoryId());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all expenses for a user
    public List<Expense> getAllExpenses(int userId) {
        List<Expense> list = new ArrayList<>();

        // Fix 1: SELECT specific columns instead of e.*
        String sql = "SELECT e.id, e.title, e.amount, e.expense_date, e.category_id, c.name AS category_name " +
                "FROM expenses e LEFT JOIN categories c ON e.category_id = c.id " +
                "WHERE e.user_id = ? ORDER BY e.expense_date DESC";

        try (PreparedStatement pst = conn.prepareStatement(sql);) {
            pst.setInt(1, userId);

            // Fix 2: ResultSet in try-with-resources
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    list.add(new Expense(
                            rs.getInt("id"),
                            rs.getString("title"),
                            rs.getDouble("amount"),
                            rs.getDate("expense_date"),
                            rs.getInt("category_id"),
                            rs.getString("category_name")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Delete expense
    public boolean deleteExpense(int id, int userId) {
        String sql = "DELETE FROM expenses WHERE id = ? AND user_id = ?";
        try (PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setInt(1, id);
            pst.setInt(2, userId);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Fix 3: Add missing updateExpense method
    public boolean updateExpense(Expense expense, int userId) {
        String sql = "UPDATE expenses SET title=?, amount=?, expense_date=?, category_id=? " +
                "WHERE id=? AND user_id=?";
        try (PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setString(1, expense.getTitle());
            pst.setDouble(2, expense.getAmount());
            pst.setDate(3, expense.getDate());
            pst.setInt(4, expense.getCategoryId());
            pst.setInt(5, expense.getId());
            pst.setInt(6, userId);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Total expenses
    public double getTotalExpenses(int userId) {
        String sql = "SELECT SUM(amount) AS total FROM expenses WHERE user_id = ?";
        try (PreparedStatement pst = conn.prepareStatement(sql);) {

            pst.setInt(1, userId);

            // Fix 4: ResultSet in try-with-resources
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}