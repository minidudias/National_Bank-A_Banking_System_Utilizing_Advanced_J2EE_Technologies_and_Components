<%@ page import="lk.jiat.app.core.model.Account" %>
<%@ page import="java.util.List" %>
<%@ page import="lk.jiat.app.core.service.AccountService" %>
<%@ page import="lk.jiat.app.core.service.UserService" %>
<%@ page import="lk.jiat.app.core.model.User" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="lk.jiat.app.core.service.TransactionService" %>
<%@ page import="lk.jiat.app.core.model.Transaction" %>
<%@ page import="lk.jiat.app.core.model.TransactionType" %>
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
  List<Transaction> transactions;

  try {
    InitialContext ctx = new InitialContext();
    AccountService accountService = (AccountService) ctx.lookup("java:global/j2ee-national-bank-ear/banking-module/AccountSessionBean!lk.jiat.app.core.service.AccountService");
    UserService userService = (UserService) ctx.lookup("java:global/j2ee-national-bank-ear/auth-module/UserSessionBean!lk.jiat.app.core.service.UserService");
    TransactionService transactionService = (TransactionService) ctx.lookup("java:global/j2ee-national-bank-ear/banking-module/TransactionSessionBean!lk.jiat.app.core.service.TransactionService");

    User user = userService.getUserByEmail(name);
    accounts = accountService.getAccountsByUserId(user.getId());
    userName = user.getName();

    transactions = transactionService.getUserTransactions(user.getId());
  } catch (Exception e) {
    throw new RuntimeException("Error loading user data: " + e.getMessage(), e);
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>National Bank - Transaction History</title>
  <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
  <style>
    .transaction-card {
      border-radius: 8px;
      margin-bottom: 15px;
      transition: all 0.3s ease;
    }
    .transaction-card:hover {
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    }
    .transaction-header {
      border-top-left-radius: 8px;
      border-top-right-radius: 8px;
      padding: 10px 15px;
    }
    .transaction-body {
      padding: 15px;
    }
    .transaction-amount {
      font-size: 1.2em;
      font-weight: bold;
    }
    .transaction-date {
      color: #6c757d;
      font-size: 0.9em;
    }
    .transaction-reference {
      font-style: italic;
      margin-top: 5px;
    }
    .transaction-type-badge {
      font-size: 0.8em;
      padding: 5px 8px;
      text-transform: uppercase;
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
    .immediate-type {
      background-color: #d4edda;
      border-left: 4px solid #28a745;
    }
    .scheduled-type {
      background-color: #d1ecf1;
      border-left: 4px solid #17a2b8;
    }
    .interest-type {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
    }
    .failed-type {
      background-color: #f8d7da;
      border-left: 4px solid #dc3545;
    }
    .cancelled-type {
      background-color: #e2e3e5;
      border-left: 4px solid #6c757d;
    }
    .no-transactions {
      text-align: center;
      padding: 40px;
      color: #6c757d;
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
              <a class="nav-link active" href="history.jsp">Finished Transactions</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="scheduled.jsp">Scheduled Transactions</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="reports.jsp">Monthly Reports</a>
            </li>
          </ul>
        </div>
      </div>
    </div>

    <div class="col-md-9">
      <div class="card shadow-sm">
        <div class="card-header bg-light">
          <div class="d-flex justify-content-between align-items-center">
            <h4 class="mb-0 text-primary">Transaction History</h4>
            <span class="badge bg-secondary"><%= transactions != null ? transactions.size() : 0 %> Transactions</span>
          </div>
        </div>
        <div class="card-body">
          <div class="filter-container">
            <form id="filterForm" class="row g-3">
              <div class="col-md-4">
                <label for="accountFilter" class="form-label">Debited From</label>
                <select class="form-select" id="accountFilter">
                  <option value="all">All Accounts</option>
                  <% for (Account account : accounts) { %>
                  <option value="<%= account.getAccountNo() %>"><%= account.getAccountNo() %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-4">
                <label for="typeFilter" class="form-label">Transaction Type</label>
                <select class="form-select" id="typeFilter">
                  <option value="all">All Types</option>
                  <option value="IMMEDIATE">Immediate</option>
                  <option value="SCHEDULED">Was Scheduled</option>
                  <option value="INTEREST">Interest</option>
                  <option value="FAILED">Failed</option>
                  <option value="CANCELLED">Cancelled</option>
                </select>
              </div>
              <div class="col-md-4">
                <label for="dateFilter" class="form-label">Date Range</label>
                <select class="form-select" id="dateFilter">
                  <option value="all">All Time</option>
                  <option value="today">Today</option>
                  <option value="week">This Week</option>
                  <option value="month">This Month</option>
                  <option value="year">This Year</option>
                </select>
              </div>
            </form>
          </div>

          <div id="transactionsList">
            <% if (transactions == null || transactions.isEmpty()) { %>
            <div class="no-transactions">
              <i class="fas fa-exchange-alt fa-3x mb-3"></i>
              <h5>No Transactions Found</h5>
              <p>You don't have any transaction history yet.</p>
            </div>
            <% } else { %>
            <% for (Transaction transaction : transactions) { %>
            <div class="transaction-card
                                <% switch(transaction.getType()) {
                                    case IMMEDIATE: %>immediate-type<% break;
                                    case SCHEDULED: %>scheduled-type<% break;
                                    case INTEREST: %>interest-type<% break;
                                    case FAILED: %>failed-type<% break;
                                    case CANCELLED: %>cancelled-type<% break;
                                } %>">
              <div class="transaction-header">
                <div class="d-flex justify-content-between align-items-center">
                  <div>
                                            <span class="badge transaction-type-badge bg-<%= getBadgeColor(transaction.getType()) %>">
                                                <%= transaction.getType().toString() %>
                                            </span>
                    <span class="transaction-date">
                                                <%= transaction.getTransactionDate().format(DateTimeFormatter.ofPattern("MMM dd, yyyy hh:mm a")) %>
                                            </span>
                  </div>
                  <span class="transaction-amount text-<%= transaction.getAmount() >= 0 ? "success" : "danger" %>">
                                            Rs. <%= String.format("%,.2f", transaction.getAmount()) %>
                                        </span>
                </div>
              </div>
              <div class="transaction-body">
                <div class="d-flex flex-wrap mb-2">
                  <% if (transaction.getSourceAccount() != null) { %>
                  <span class="badge account-badge bg-primary">
                <i class="fas fa-arrow-up me-1"></i> From: <%= transaction.getSourceAccount().getAccountNo() %>
            </span>
                  <% } else { %>
                  <span class="badge account-badge bg-primary">
                <i class="fas fa-bank me-1"></i> From: Monthly Interest
            </span>
                  <% } %>
                  <span class="badge account-badge bg-success">
            <i class="fas fa-arrow-down me-1"></i> To: <%= transaction.getDestinationAccount().getAccountNo() %>
        </span>
                </div>
                <% if (transaction.getReference() != null && !transaction.getReference().isEmpty()) { %>
                <div class="transaction-reference">
                  <strong>Reference:</strong> <%= transaction.getReference() %>
                </div>
                <% } %>
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
    console.log('Transaction History Page Loaded');

    <c:if test="${not empty success}">
    var successToast = new bootstrap.Toast(document.getElementById('successToast'));
    successToast.show();
    </c:if>

    <c:if test="${not empty error}">
    var errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
    errorToast.show();
    </c:if>

    document.getElementById('accountFilter').addEventListener('change', applyFilters);
    document.getElementById('typeFilter').addEventListener('change', applyFilters);
    document.getElementById('dateFilter').addEventListener('change', applyFilters);
  });

  function applyFilters() {
    const accountFilter = document.getElementById('accountFilter').value;
    const typeFilter = document.getElementById('typeFilter').value;
    const dateFilter = document.getElementById('dateFilter').value;

    console.log('Applying filters:', { accountFilter, typeFilter, dateFilter });

    const transactions = document.querySelectorAll('.transaction-card');
    transactions.forEach(transaction => {
      const accountNo = transaction.querySelector('.account-badge').textContent.split(': ')[1];
      const type = transaction.querySelector('.transaction-type-badge').textContent.trim();
      const dateText = transaction.querySelector('.transaction-date').textContent.trim();
      const transactionDate = new Date(dateText);

      let show = true;
      if (accountFilter !== 'all' &&
              !accountNo.includes(accountFilter)) {
        show = false;
      }

      if (typeFilter !== 'all' &&
              type !== typeFilter) {
        show = false;
      }

      if (dateFilter !== 'all') {
        const now = new Date();
        let startDate;

        switch(dateFilter) {
          case 'today':
            startDate = new Date(now.setHours(0, 0, 0, 0));
            break;
          case 'week':
            startDate = new Date(now.setDate(now.getDate() - now.getDay()));
            break;
          case 'month':
            startDate = new Date(now.getFullYear(), now.getMonth(), 1);
            break;
          case 'year':
            startDate = new Date(now.getFullYear(), 0, 1);
            break;
        }

        if (transactionDate < startDate) {
          show = false;
        }
      }

      if (show) {
        transaction.style.display = 'block';
      } else {
        transaction.style.display = 'none';
      }
    });

    const visibleTransactions = document.querySelectorAll('.transaction-card[style="display: block;"]');
    const noTransactionsMessage = document.querySelector('.no-transactions');

    if (visibleTransactions.length === 0) {
      if (!noTransactionsMessage) {
        const transactionsList = document.getElementById('transactionsList');
        const messageDiv = document.createElement('div');
        messageDiv.className = 'no-transactions';
        messageDiv.innerHTML = `
                    <i class="fas fa-exchange-alt fa-3x mb-3"></i>
                    <h5>No Matching Transactions</h5>
                    <p>No transactions match your current filters.</p>
                `;
        transactionsList.prepend(messageDiv);
      }
    } else if (noTransactionsMessage) {
      noTransactionsMessage.remove();
    }
  }
</script>
</body>
</html>

<%!
  private String getBadgeColor(TransactionType type) {
    switch(type) {
      case IMMEDIATE: return "success";
      case SCHEDULED: return "info";
      case INTEREST: return "warning";
      case FAILED: return "danger";
      case CANCELLED: return "secondary";
      default: return "primary";
    }
  }
%>