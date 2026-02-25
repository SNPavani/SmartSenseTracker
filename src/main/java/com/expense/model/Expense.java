package com.expense.model;

import java.sql.Date;

public class Expense {
    private int id;
    private String title;
    private double amount;
    private Date date;
    private int categoryId;
    private String categoryName;

    // Full constructor
    public Expense(int id, String title, double amount, Date date, int categoryId, String categoryName) {
        this.id = id;
        this.title = title;
        this.amount = amount;
        this.date = date;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
    }

    // Fix 1: Add constructor that matches ViewExpensesServlet usage
    public Expense(int id, String title, double amount, String date, String categoryName) {
        this.id = id;
        this.title = title;
        this.amount = amount;
        this.date = Date.valueOf(date);
        this.categoryId = 0;
        this.categoryName = categoryName;
    }

    // Empty constructor
    public Expense() {}

    // Getters
    public int getId() { return id; }
    public String getTitle() { return title; }
    public double getAmount() { return amount; }
    public Date getDate() { return date; }
    public int getCategoryId() { return categoryId; }
    public String getCategoryName() { return categoryName; }

    // Fix 2: Add getCategory() alias so viewExpensesContent.jsp works
    public String getCategory() { return categoryName; }

    // Setters
    public void setId(int id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    public void setAmount(double amount) { this.amount = amount; }
    public void setDate(Date date) { this.date = date; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
}