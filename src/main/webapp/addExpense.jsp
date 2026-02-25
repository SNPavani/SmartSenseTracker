<%
    request.setAttribute("contentPage", "addExpenseContent.jsp");
    request.getRequestDispatcher("base.jsp").forward(request, response);
%>