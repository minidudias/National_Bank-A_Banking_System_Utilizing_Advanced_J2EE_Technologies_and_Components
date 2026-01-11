<%@ page import="lk.jiat.app.core.model.Account" %>
<%@ page import="java.util.List" %>
<%@ page import="lk.jiat.app.core.service.AccountService" %>
<%@ page import="lk.jiat.app.core.service.UserService" %>
<%@ page import="lk.jiat.app.core.model.User" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="lk.jiat.app.core.service.TransactionService" %>
<%@ page import="lk.jiat.app.core.model.ScheduledTransaction" %>
<%@ page import="lk.jiat.app.core.model.ActiveStatus" %>
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
  String userName;
  List<ScheduledTransaction> scheduledTransactions;

  try {
    InitialContext ctx = new InitialContext();
    UserService userService = (UserService) ctx.lookup("java:global/j2ee-national-bank-ear/auth-module/UserSessionBean!lk.jiat.app.core.service.UserService");
    TransactionService transactionService = (TransactionService) ctx.lookup("java:global/j2ee-national-bank-ear/banking-module/TransactionSessionBean!lk.jiat.app.core.service.TransactionService");

    User user = userService.getUserByEmail(name);
    userName = user.getName();

    scheduledTransactions = transactionService.getUserScheduledTransactions(user.getId())
            .stream()
            .filter(st -> st.getSourceAccount().getActiveStatus() == ActiveStatus.ACTIVE)
            .collect(java.util.stream.Collectors.toList());
  } catch (Exception e) {
    throw new RuntimeException("Error loading user data: " + e.getMessage(), e);
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>National Bank - Scheduled Transactions</title>
  <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
  <style>
    .scheduled-card {
      border-left: 4px solid #17a2b8;
      border-radius: 8px;
      margin-bottom: 15px;
      transition: all 0.3s ease;
    }
    .scheduled-card:hover {
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    }
    .scheduled-header {
      border-top-left-radius: 8px;
      border-top-right-radius: 8px;
      padding: 10px 15px;
      background-color: #d1ecf1;
    }
    .scheduled-body {
      padding: 15px;
    }
    .scheduled-amount {
      font-size: 1.2em;
      font-weight: bold;
    }
    .scheduled-date {
      color: #6c757d;
      font-size: 0.9em;
    }
    .scheduled-reference {
      font-style: italic;
      margin-top: 5px;
    }
    .account-badge {
      font-size: 0.85em;
      padding: 4px 7px;
      margin-right: 5px;
    }
    .no-transactions {
      text-align: center;
      padding: 40px;
      color: #6c757d;
    }
    .cancel-btn {
      margin-top: 10px;
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
              <a class="nav-link active" href="scheduled.jsp">Scheduled Transactions</a>
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
            <h4 class="mb-0 text-primary">Scheduled Transactions</h4>
            <span class="badge bg-secondary"><%= scheduledTransactions != null ? scheduledTransactions.size() : 0 %> Scheduled</span>
          </div>
        </div>
        <div class="card-body">
          <div id="scheduledList">
            <% if (scheduledTransactions == null || scheduledTransactions.isEmpty()) { %>
            <div class="no-transactions">
              <i class="fas fa-clock fa-3x mb-3"></i>
              <h5>No Scheduled Transactions</h5>
              <p>You don't have any scheduled transactions.</p>
            </div>
            <% } else { %>
            <% for (ScheduledTransaction transaction : scheduledTransactions) { %>
            <div class="scheduled-card">
              <div class="scheduled-header">
                <div class="d-flex justify-content-between align-items-center">
                  <div>
                                            <span class="badge bg-info">
                                                SCHEDULED
                                            </span>
                    <span class="scheduled-date">
                                                Scheduled for: <%= transaction.getExecutionTime().format(DateTimeFormatter.ofPattern("MMM dd, yyyy hh:mm a")) %>
                                            </span>
                  </div>
                  <span class="scheduled-amount text-danger">
                                            Rs. <%= String.format("%,.2f", transaction.getAmount()) %>
                                        </span>
                </div>
              </div>
              <div class="scheduled-body">
                <div class="d-flex flex-wrap mb-2">
                                        <span class="badge account-badge bg-primary">
                                            <i class="fas fa-arrow-up me-1"></i> From: <%= transaction.getSourceAccount().getAccountNo() %>
                                        </span>
                  <span class="badge account-badge bg-success">
                                            <i class="fas fa-arrow-down me-1"></i> To: <%= transaction.getDestinationAccount().getAccountNo() %>
                                        </span>
                </div>
                <% if (transaction.getReference() != null && !transaction.getReference().isEmpty()) { %>
                <div class="scheduled-reference">
                  <strong>Reference:</strong> <%= transaction.getReference() %>
                </div>
                <% } %>
                <div class="d-grid gap-2">
                  <button class="btn btn-danger cancel-btn"
                          data-transaction-id="<%= transaction.getId() %>">
                    <i class="fas fa-times-circle me-2"></i>
                    Cancel Scheduled Transfer
                  </button>
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
    console.log('Scheduled Transactions Page Loaded');
    <c:if test="${not empty success}">
    var successToast = new bootstrap.Toast(document.getElementById('successToast'));
    successToast.show();
    </c:if>

    <c:if test="${not empty error}">
    var errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
    errorToast.show();
    </c:if>


    document.querySelectorAll('.cancel-btn').forEach(button => {
      button.addEventListener('click', handleCancelScheduled);
    });
  });

  function handleCancelScheduled(event) {
    const button = event.target.closest('.cancel-btn');
    const transactionId = button.getAttribute('data-transaction-id');
    const originalButtonContent = button.innerHTML;

    button.disabled = true;
    button.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Cancelling...';

    fetch('${pageContext.request.contextPath}/cancel-scheduled', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'scheduledId=' + encodeURIComponent(transactionId)
    })
            .then(response => {
              console.log('Cancel response status:', response.status);
              return response.json();
            })
            .then(data => {
              console.log('Cancel response data:', data);

              if (data.status === 'success') {
                showToast('success', data.message);
                setTimeout(() => {
                  window.location.reload();
                }, 1500);
              } else {
                showToast('danger', data.message || 'Cancellation failed');
                button.disabled = false;
                button.innerHTML = originalButtonContent;
              }
            })
            .catch(error => {
              console.error('Cancel error:', error);
              showToast('danger', 'Network error occurred. Please try again.');
              button.disabled = false;
              button.innerHTML = originalButtonContent;
            });
  }

  function showToast(type, message) {
    const toastContainer = document.querySelector('.toast-container');
    if (!toastContainer) {
      console.error('Toast container not found in DOM');
      return;
    }

    console.log('Showing toast:', { type, message });

    if (!message || typeof message !== 'string' || message.trim() === '') {
      message = 'Something happened, but no message was provided.';
    }

    const toast = document.createElement('div');
    toast.className = 'toast show';
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');

    const toastHeader = document.createElement('div');
    toastHeader.className = 'toast-header';

    const bgClass = type === 'success' ? 'bg-success' : 'bg-danger';
    const textClass = 'text-white';
    const title = type === 'success' ? 'Success' : 'Error';

    const strong = document.createElement('strong');
    strong.className = `me-auto ${textClass}`;
    strong.textContent = title;

    const closeButton = document.createElement('button');
    closeButton.type = 'button';
    closeButton.className = 'btn-close btn-close-white';
    closeButton.setAttribute('data-bs-dismiss', 'toast');
    closeButton.setAttribute('aria-label', 'Close');

    toastHeader.appendChild(strong);
    toastHeader.appendChild(closeButton);

    const toastBody = document.createElement('div');
    toastBody.className = 'toast-body';
    toastBody.textContent = message;

    toast.appendChild(toastHeader);
    toast.appendChild(toastBody);

    toastHeader.classList.add(bgClass, textClass);
    toastContainer.appendChild(toast);
    const bsToast = new bootstrap.Toast(toast, {
      autohide: true,
      delay: 5000
    });

    bsToast.show();

    toast.addEventListener('hidden.bs.toast', function() {
      toast.remove();
    });
  }
</script>
</body>
</html>