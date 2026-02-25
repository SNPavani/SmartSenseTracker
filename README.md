# 📊 SmartSense Tracker
### Personal Finance Management System

![Java](https://img.shields.io/badge/Java-17-orange?style=flat-square&logo=java)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=flat-square&logo=mysql)
![Tomcat](https://img.shields.io/badge/Tomcat-10.1-yellow?style=flat-square)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple?style=flat-square&logo=bootstrap)
![Maven](https://img.shields.io/badge/Maven-3.x-red?style=flat-square&logo=apachemaven)

A full-stack personal finance web application built with **Java EE (Jakarta Servlets + JSP)** and **MySQL**. Track expenses, set budgets, monitor savings goals, and visualize spending with interactive charts.

---

## ✨ Features

- 🔐 **Secure Authentication** — Login/Register with session management & auto-timeout
- 💸 **Expense Tracking** — Add, edit, delete transactions across 10 categories
- 📊 **Interactive Charts** — Year/month drill-down bar chart with traffic-light coloring
- 📋 **Category Breakdown** — NSE-style table showing amount, % spent, vs last month
- 🎯 **Savings Goal Tracker** — Track 20% monthly savings target with progress bar
- ⚡ **Spending Limit Alerts** — Get warned when approaching your monthly budget
- 🌙 **Dark Mode** — Full dark mode support
- 📱 **Responsive Design** — Works on desktop and mobile

---

## 🛠️ Tech Stack

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

## 📁 Project Structure

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

---

## 🗄️ Database Schema

**3 Tables:** `users`, `categories`, `expenses`

```sql
-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    monthly_income DECIMAL(12,2) DEFAULT 0,
    expense_limit DECIMAL(12,2) DEFAULT 0
);

-- Categories table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Expenses table
CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    expense_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Java JDK 17+
- Apache Maven 3.x
- Apache Tomcat 10.1.x
- MySQL 8.x
- IntelliJ IDEA (recommended)

### Step 1 — Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/SmartSenseTracker.git
cd SmartSenseTracker
```

### Step 2 — Database Setup
```bash
# Login to MySQL
mysql -u root -p

# Create database
CREATE DATABASE SmartSenseTracker;
EXIT;

# Import the dump
mysql -u root -p SmartSenseTracker < smartsense_db.sql
```

### Step 3 — Configure Database Connection
Open `src/main/java/com/expense/dao/DatabaseConnection.java` and update:
```java
private static final String URL      = "jdbc:mysql://localhost:3306/SmartSenseTracker";
private static final String USER     = "root";
private static final String PASSWORD = "your_mysql_password";
```

### Step 4 — Build & Run
```bash
mvn clean package
```
Then in IntelliJ:
1. Go to **Run → Edit Configurations**
2. Add **Apache Tomcat 10** server
3. Deploy `SmartSenseTracker:war exploded`
4. Click **Run**
5. Open → [http://localhost:8080/SmartSenseTracker](http://localhost:8080/SmartSenseTracker)

---

## 🔒 Security Features

- Session-based authentication on every servlet
- `Cache-Control: no-cache` headers prevent back-button access after logout
- `PreparedStatement` used for all DB queries (SQL injection prevention)
- Session auto-invalidation on logout
- 30-minute session timeout with warning modal

---

## 📸 Screenshots

> Add screenshots of your dashboard here after deployment

---

## 👨‍💻 Author

**Deepak JN**
- Built as a personal finance tracker project
- Java EE | MySQL | Bootstrap 5

---

## 📄 License

This project is for educational and personal use.
