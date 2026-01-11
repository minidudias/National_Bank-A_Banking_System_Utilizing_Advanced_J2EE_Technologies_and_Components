<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    // Check if user is already logged in - adjust session attribute name as needed
    if (request.getUserPrincipal() != null) {
        if (request.isUserInRole("BANK_OFFICER")) {
            response.sendRedirect(request.getContextPath() + "/officer/index.jsp");
            return;
        } else if (request.isUserInRole("HR_DEPARTMENT")) {
            response.sendRedirect(request.getContextPath() + "/hr_dept/index.jsp");
            return;
        } else if (request.isUserInRole("CUSTOMER")) {
            response.sendRedirect(request.getContextPath() + "/customer/index.jsp");
            return;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="css/bootstrap.css" rel="stylesheet">
    <link rel="icon" href="img/logo.png" />
    <title>National Bank - All User Login</title>
    <style>
        .verify-account-btn {
            width: 100%;
        }
    </style>
</head>
<body class="bg-light">
<div class="container">
    <div class="row justify-content-center align-items-center min-vh-100">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-lg">
                <div class="card-body text-center">
                    <img src="img/logo.png" alt="Logo" class="img-fluid mb-3" style="max-height: 220px;">
                    <h3 class="card-title mb-4">National Bank Login</h3>
                    <form method="POST" action="${pageContext.request.contextPath}/login">
                        <div class="mb-3 text-start">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" id="email" autocomplete="off" required
                                   value="${param.email}">
                        </div>
                        <div class="mb-3 text-start">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" name="password" class="form-control" id="password" autocomplete="off" required>
                        </div>
                        <div class="d-grid gap-3">
                            <button type="submit" class="btn btn-primary">Login</button>
                            <a href="${pageContext.request.contextPath}/verify_and_setup.jsp" class="btn btn-success verify-account-btn">
                                Verify Account
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="errorToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header bg-danger text-white">
            <svg class="bd-placeholder-img rounded me-2" width="20" height="20" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" preserveAspectRatio="xMidYMid slice" focusable="false">
                <rect width="100%" height="100%" fill="#dc3545"></rect>
            </svg>
            <strong class="me-auto">Login Error</strong>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body">
            <c:out value="${error}" />
        </div>
    </div>
</div>

<script src="js/bootstrap.bundle.js"></script>
<script>
    // Show toast if there's an error message
    <c:if test="${not empty error}">
    document.addEventListener('DOMContentLoaded', function() {
        var errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
        errorToast.show();
    });
    </c:if>
</script>
</body>
</html>