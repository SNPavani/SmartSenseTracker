📊 SmartSense Tracker
Personal Finance Management System

A full-stack personal finance web application built with **Java EE (Jakarta Servlets + JSP)** and **MySQL**. Track expenses, set budgets, monitor savings goals, and visualize spending with interactive charts.

Features

Secure Authentication** — Login/Register with session management & auto-timeout
Expense Tracking** — Add, edit, delete transactions across 10 categories
Interactive Charts** — Year/month drill-down bar chart with traffic-light coloring
Category Breakdown** — NSE-style table showing amount, % spent, vs last month
Savings Goal Tracker** — Track 20% monthly savings target with progress bar
Spending Limit Alerts** — Get warned when approaching your monthly budget
Dark Mode** — Full dark mode support
Responsive Design** — Works on desktop and mobile


Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java EE — Jakarta Servlets |
| View | JSP (JavaServer Pages) |
| Database | MySQL 8.0 |
| DB Connection | JDBC (MySQL Connector/J) |
| Server | Apache Tomcat 10.1 |
| Build Tool | Apache Maven |
| CSS Framework | Bootstrap 5.3 |
| Charts | Chart.js 4.4 |
| Icons | Bootstrap Icons |

---

Project Structure

```
SmartSenseTracker/
├── src/
│   └── main/
│       ├── java/com/expense/
│       │   ├── servlet/          # All Servlet controllers
│       │   │   ├── LoginServlet.java
│       │   │   ├── DashboardServlet.java
│       │   │   ├── AddExpenseServlet.java
│       │   │   ├── ViewExpensesServlet.java
│       │   │   ├── EditExpenseServlet.java
│       │   │   ├── SettingsServlet.java
│       │   │   ├── CategoryChartServlet.java
│       │   │   └── LogoutServlet.java
│       │   ├── dao/
│       │   │   ├── DatabaseConnection.java   # JDBC connection
│       │   │   └── ExpenseDAO.java           # DB queries
│       │   └── model/
│       │       └── Expense.java              # Entity class
│       └── webapp/
│           ├── base.jsp                      # Master layout
│           ├── login.jsp
│           ├── register.jsp
│           ├── dashboardContent.jsp
│           ├── addExpenseContent.jsp
│           ├── viewExpensesContent.jsp
│           ├── editExpenseContent.jsp
│           ├── settingsContent.jsp
│           └── spendingTrendChart.jsp
├── smartsense_db.sql             # Database dump
└── pom.xml                       # Maven config
```
Setup
Prerequisites
- Java JDK 17+
- Apache Maven 3.x
- Apache Tomcat 10.1.x
- MySQL 8.x
- IntelliJ IDEA (recommended)

Security Features

- Session-based authentication on every servlet
- `Cache-Control: no-cache` headers prevent back-button access after logout
- `PreparedStatement` used for all DB queries (SQL injection prevention)
- Session auto-invalidation on logout
- 30-minute session timeout with warning modal

Author

**SN Pavani**
- Built as a personal finance tracker project
- Java EE | MySQL 
