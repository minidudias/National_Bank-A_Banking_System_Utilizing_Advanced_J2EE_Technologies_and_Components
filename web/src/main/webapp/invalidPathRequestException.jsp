<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isErrorPage="true" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
    <title>Your Request is Deemed to be Invalid - National Bank</title>
    <style>
        .error-container {
            height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
        }
        .error-message {
            margin: 2rem 0;
            color: #dc3545;
        }
        .redirect-message {
            color: #6c757d;
            margin-bottom: 2rem;
        }
    </style>
</head>
<body class="bg-light">
<div class="error-container">
    <img src="${pageContext.request.contextPath}/img/logo.png" alt="Logo" class="img-fluid mb-4" style="max-height: 120px;">

    <h2 class="error-message">Your Request Path is Deemed to be Invalid</h2>

    <p class="redirect-message">Redirecting...</p>

    <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.js"></script>
<script>
    setTimeout(function() {
        window.location.href = "${pageContext.request.contextPath}/index.jsp";
    }, 3000);
</script>
</body>
</html>