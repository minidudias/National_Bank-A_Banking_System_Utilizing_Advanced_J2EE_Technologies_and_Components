<%@ page import="lk.jiat.app.core.model.Account" %>
<%@ page import="java.util.List" %>
<%@ page import="lk.jiat.app.core.service.AccountService" %>
<%@ page import="lk.jiat.app.core.service.UserService" %>
<%@ page import="lk.jiat.app.core.model.User" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="lk.jiat.app.core.service.ReportService" %>
<%@ page import="lk.jiat.app.core.model.MonthlyBalanceReport" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (request.getUserPrincipal() == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    if (request.isUserInRole("HR_DEPARTMENT")) {
        response.sendRedirect(request.getContextPath() + "/hr_dept/index.jsp");
        return;
    }
    if (!request.isUserInRole("CUSTOMER") && !request.isUserInRole("BANK_OFFICER")) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String name = request.getUserPrincipal().getName();
    List<Account> accounts;
    String userName;
    List<MonthlyBalanceReport> reports;
    List<YearMonth> availableMonths;

    try {
        InitialContext ctx = new InitialContext();
        AccountService accountService = (AccountService) ctx.lookup("java:global/j2ee-national-bank-ear/banking-module/AccountSessionBean!lk.jiat.app.core.service.AccountService");
        UserService userService = (UserService) ctx.lookup("java:global/j2ee-national-bank-ear/auth-module/UserSessionBean!lk.jiat.app.core.service.UserService");
        ReportService reportService = (ReportService) ctx.lookup("java:global/j2ee-national-bank-ear/banking-module/ReportSessionBean!lk.jiat.app.core.service.ReportService");

        User user = userService.getUserByEmail(name);
        accounts = accountService.getAccountsByUserId(user.getId());
        userName = user.getName();

        reports = reportService.getUserMonthlyReports(user.getId());

        availableMonths = reports.stream()
                .map(report -> YearMonth.from(report.getRecordedDate()))
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    } catch (Exception e) {
        throw new RuntimeException("Error loading user data: " + e.getMessage(), e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>National Bank - Monthly Reports</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
    <style>
        .report-card {
            border-left: 4px solid #6f42c1;
            border-radius: 8px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }
        .report-card:hover {
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        .report-header {
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
            padding: 10px 15px;
            background-color: #e9ecef;
        }
        .report-body {
            padding: 15px;
        }
        .report-amount {
            font-size: 1.2em;
            font-weight: bold;
        }
        .report-date {
            color: #6c757d;
            font-size: 0.9em;
        }
        .account-badge {
            font-size: 0.85em;
            padding: 4px 7px;
            margin-right: 5px;
        }
        .filter-container {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
        }
        .no-reports {
            text-align: center;
            padding: 40px;
            color: #6c757d;
        }
        .balance-value {
            font-weight: bold;
        }
        .interest-value {
            color: #28a745;
            font-weight: bold;
        }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center" href="#">
            <img src="${pageContext.request.contextPath}/img/logo.png" alt="Logo" width="40" height="40" class="me-2">
            National Bank
        </a>
        <div class="navbar-nav ms-auto">
            <div class="nav-item dropdown">
                <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                    Welcome, <%= userName %>!
                </a>
                <ul class="dropdown-menu">
                    <li><span class="dropdown-item-text"><%= name %></span></li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                            <button type="submit" class="dropdown-item" style="border:none; background:none; padding-left: 20px;">
                                <i class="fas fa-sign-out-alt me-1"></i> Logout
                            </button>
                        </form>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</nav>
<div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1080;">
    <div id="successToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header bg-success text-white">
            <strong class="me-auto">Success</strong>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body">
            <c:out value="${success}" />
        </div>
    </div>

    <div id="errorToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header bg-danger text-white">
            <strong class="me-auto">Error</strong>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body">
            <c:out value="${error}" />
        </div>
    </div>
</div>

<div class="container-fluid mt-4">
    <div class="row">
        <div class="col-md-3">
            <div class="card shadow-sm mb-4">
                <div class="card-body p-0">
                    <ul class="nav nav-pills flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="index.jsp">Do Transfers and Summary</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="history.jsp">Finished Transactions</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="scheduled.jsp">Scheduled Transactions</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="reports.jsp">Monthly Reports</a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-md-9">
            <div class="card shadow-sm">
                <div class="card-header bg-light">
                    <div class="d-flex justify-content-between align-items-center">
                        <h4 class="mb-0 text-primary">Monthly Reports</h4>
                        <span class="badge bg-secondary"><%= reports != null ? reports.size() : 0 %> Reports</span>
                    </div>
                </div>
                <div class="card-body">
                    <div class="filter-container">
                        <form id="filterForm" class="row g-3">
                            <div class="col-md-4">
                                <label for="accountFilter" class="form-label">Account</label>
                                <select class="form-select" id="accountFilter">
                                    <option value="all">All Accounts</option>
                                    <% for (Account account : accounts) { %>
                                    <option value="<%= account.getAccountNo() %>"><%= account.getAccountNo() %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label for="monthFilter" class="form-label">Month</label>
                                <select class="form-select" id="monthFilter">
                                    <option value="all">All Months</option>
                                    <% for (YearMonth month : availableMonths) { %>
                                    <option value="<%= month.toString() %>">
                                        <%= month.format(DateTimeFormatter.ofPattern("MMMM yyyy")) %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label for="yearFilter" class="form-label">Year</label>
                                <select class="form-select" id="yearFilter">
                                    <option value="all">All Years</option>
                                    <%
                                        List<Integer> years = availableMonths.stream()
                                                .map(ym -> ym.getYear())
                                                .distinct()
                                                .sorted()
                                                .collect(Collectors.toList());
                                        for (Integer year : years) { %>
                                    <option value="<%= year %>"><%= year %></option>
                                    <% } %>
                                </select>
                            </div>
                        </form>
                    </div>
                    <div id="reportsList">
                        <% if (reports == null || reports.isEmpty()) { %>
                        <div class="no-reports">
                            <i class="fas fa-file-alt fa-3x mb-3"></i>
                            <h5>No Monthly Reports</h5>
                            <p>You don't have any monthly reports yet.</p>
                        </div>
                        <% } else { %>
                        <% for (MonthlyBalanceReport report : reports) { %>
                        <div class="report-card">
                            <div class="report-header">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                            <span class="badge bg-primary">
                                                MONTHLY REPORT
                                            </span>
                                        <span class="report-date">
                                                <%= report.getRecordedDate().format(DateTimeFormatter.ofPattern("MMMM yyyy")) %>
                                            </span>
                                    </div>
                                    <span class="badge bg-secondary">
                                            <%= report.getWhichAccount().getAccountNo() %>
                                        </span>
                                </div>
                            </div>
                            <div class="report-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <span class="text-muted">End of Month Balance:</span>
                                            <span class="balance-value">
                                                    Rs. <%= String.format("%,.2f", report.getEndOfMonthBalance()) %>
                                                </span>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <span class="text-muted">Interest Credited:</span>
                                            <span class="interest-value">
                                                    + Rs. <%= String.format("%,.2f", report.getInterestCredited()) %>
                                                </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Monthly Reports Page Loaded');
        <c:if test="${not empty success}">
        var successToast = new bootstrap.Toast(document.getElementById('successToast'));
        successToast.show();
        </c:if>

        <c:if test="${not empty error}">
        var errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
        errorToast.show();
        </c:if>

        document.getElementById('accountFilter').addEventListener('change', applyFilters);
        document.getElementById('monthFilter').addEventListener('change', applyFilters);
        document.getElementById('yearFilter').addEventListener('change', applyFilters);
    });

    function applyFilters() {
        const accountFilter = document.getElementById('accountFilter').value;
        const monthFilter = document.getElementById('monthFilter').value;
        const yearFilter = document.getElementById('yearFilter').value;

        console.log('Applying filters:', { accountFilter, monthFilter, yearFilter });

        const reports = document.querySelectorAll('.report-card');
        reports.forEach(report => {
            const accountNo = report.querySelector('.badge.bg-secondary').textContent.trim();
            const dateText = report.querySelector('.report-date').textContent.trim();

            const [monthName, year] = dateText.split(' ');
            const reportYear = parseInt(year);

            const monthNames = ["January", "February", "March", "April", "May", "June",
                "July", "August", "September", "October", "November", "December"];
            const reportMonth = monthNames.indexOf(monthName) + 1; // 1-12

            let show = true;

            if (accountFilter !== 'all' && accountNo !== accountFilter) {
                show = false;
            }

            if (monthFilter !== 'all') {
                const [filterYear, filterMonth] = monthFilter.split('-');
                if (reportYear !== parseInt(filterYear) || reportMonth !== parseInt(filterMonth)) {
                    show = false;
                }
            }

            if (yearFilter !== 'all' && reportYear !== parseInt(yearFilter)) {
                show = false;
            }

            report.style.display = show ? 'block' : 'none';
        });

        const visibleReports = document.querySelectorAll('.report-card[style="display: block;"]');
        const noReportsMessage = document.querySelector('.no-reports');

        if (visibleReports.length === 0) {
            if (!noReportsMessage) {
                const reportsList = document.getElementById('reportsList');
                const messageDiv = document.createElement('div');
                messageDiv.className = 'no-reports';
                messageDiv.innerHTML = `
                <i class="fas fa-file-alt fa-3x mb-3"></i>
                <h5>No Matching Reports</h5>
                <p>No reports match your current filters.</p>
            `;
                reportsList.prepend(messageDiv);
            }
        } else if (noReportsMessage) {
            noReportsMessage.remove();
        }
    }
</script>
</body>
</html>