<%@ page session="true" %>
<%
    if (session.getAttribute("userId") != null) {
        response.sendRedirect("DashboardServlet");
    } else {
        response.sendRedirect("login.jsp");
    }
%>