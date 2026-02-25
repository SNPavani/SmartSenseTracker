package com.expense.servlet;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Applies no-cache headers to every protected page.
 * This prevents the browser back button from showing cached pages after logout.
 * Also validates session on every request — if session is gone, redirects to login.
 */
@WebFilter(urlPatterns = {
        "/DashboardServlet",
        "/AddExpenseServlet",
        "/ViewExpensesServlet",
        "/EditExpenseServlet",
        "/DeleteExpenseServlet",
        "/SettingsServlet",
        "/base.jsp",
        "/dashboardContent.jsp",
        "/viewExpensesContent.jsp",
        "/addExpenseContent.jsp",
        "/editExpenseContent.jsp",
        "/settingsContent.jsp"
})
public class NoCacheFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        // ── 1. Set no-cache headers on EVERY response ──
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // ── 2. Validate session — if no valid session, kick to login ──
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // ── 3. Valid session — continue normally ──
        chain.doFilter(req, res);
    }

    @Override public void init(FilterConfig config) {}
    @Override public void destroy() {}
}