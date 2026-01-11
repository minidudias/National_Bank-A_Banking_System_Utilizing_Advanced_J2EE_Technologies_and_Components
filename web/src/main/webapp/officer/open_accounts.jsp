<%@ page import="lk.jiat.app.core.model.User" %>
<%@ page import="lk.jiat.app.core.model.Account" %>
<%@ page import="lk.jiat.app.core.model.ActiveStatus" %>
<%@ page import="lk.jiat.app.core.service.UserService" %>
<%@ page import="lk.jiat.app.core.service.AccountService" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="lk.jiat.app.core.exception.UnableToRetrieveUserIdException" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (request.getUserPrincipal() == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    if (!request.isUserInRole("BANK_OFFICER")) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String customerId = request.getParameter("customerId");
    if (customerId == null || customerId.trim().isEmpty()) {
        response.sendRedirect("/index.jsp");
        return;
    }

    User customer = null;
    List<Account> accounts = null;
    String bankerEmail = request.getUserPrincipal().getName();
    String bankerName = "";

    try {
        InitialContext ctx = new InitialContext();
        UserService userService = (UserService) ctx.lookup("java:global/j2ee-national-bank-ear/auth-module/UserSessionBean!lk.jiat.app.core.service.UserService");
        AccountService accountService = (AccountService) ctx.lookup("java:global/j2ee-national-bank-ear/banking-module/AccountSessionBean!lk.jiat.app.core.service.AccountService");

        customer = userService.getUserById(Long.parseLong(customerId));
        if (customer == null) {
            response.sendRedirect("/index.jsp");
            return;
        }

        accounts = accountService.getAccountsByUserId(customer.getId());

        User officer = userService.getUserByEmail(bankerEmail);
        if (officer != null) {
            bankerName = officer.getName();
        }

    } catch (Exception e) {
        throw new UnableToRetrieveUserIdException("Failed to retrieve user ID for customer: " + customerId, e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>National Bank - Manage Accounts</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
    <style>
        .customer-info {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .account-form {
            background-color: #e9ecef;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .accounts-list {
            max-height: 500px;
            overflow-y: auto;
            border: 1px solid #dee2e6;
            border-radius: 8px;
        }
        .account-card {
            border-left: 4px solid #007bff;
            margin-bottom: 10px;
            padding: 15px;
            background-color: #ffffff;
            border-radius: 4px;
        }
        .account-card.inactive {
            border-left-color: #dc3545;
            opacity: 0.8;
        }
        .account-card:hover {
            background-color: #f8f9fa;
        }
        .status-badge {
            font-size: 0.8em;
            padding: 4px 8px;
        }
        .status-ACTIVE {
            background-color: #28a745;
            color: white;
        }
        .status-BLOCKED {
            background-color: #dc3545;
            color: white;
        }
        .form-validation-error {
            border-color: #dc3545;
            background-color: #f8d7da;
        }
        .spinner-border-sm {
            width: 1rem;
            height: 1rem;
        }
        .balance-positive {
            color: #28a745;
        }
        .balance-negative {
            color: #dc3545;
        }
    </style>
</head>
<body>
<div class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center" href="#">
            <img src="${pageContext.request.contextPath}/img/logo.png" alt="Logo" width="40" height="40" class="me-2">
            National Bank - Account Management
        </a>
        <div class="navbar-nav ms-auto">
            <div class="nav-item dropdown">
                <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                    Welcome, <%= !bankerName.isEmpty() ? bankerName : bankerEmail %>!
                </a>
                <ul class="dropdown-menu">
                    <li><span class="dropdown-item-text"><%= bankerEmail %></span></li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <a class="dropdown-item" href="${pageContext.request.contextPath}/customer">Do Transfers</a>
                    </li>
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
</div>
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
<div class="container mt-4">
    <div class="card shadow-sm">
        <div class="card-header bg-light">
            <div class="d-flex justify-content-between align-items-center">
                <h4 class="mb-0 text-primary">Account Management</h4>
                <a href="index.jsp" class="btn btn-sm btn-outline-secondary">
                    <i class="fas fa-arrow-left me-1"></i> Back to Customers
                </a>
            </div>
        </div>
        <div class="card-body">
            <div class="customer-info">
                <h5>Customer Details</h5>
                <div class="row">
                    <div class="col-md-3">
                        <p><strong>Name:</strong> <%= customer.getName() %></p>
                    </div>
                    <div class="col-md-3">
                        <p><strong>Email:</strong> <%= customer.getEmail() %></p>
                    </div>
                    <div class="col-md-3">
                        <p><strong>Contact:</strong> <%= customer.getContact() %></p>
                    </div>
                    <div class="col-md-3">
                        <p><strong>NIC:</strong> <%= customer.getNic() %></p>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-4">
                        <p><strong>Status:</strong>
                            <span class="verified-badge verified-<%= customer.getVerifiedStatus() %>">
                                <%= customer.getVerifiedStatus() %>
                            </span>
                        </p>
                    </div>
                    <div class="col-md-4">
                        <p><strong>Customer Since:</strong>
                            <%= new SimpleDateFormat("yyyy-MM-dd").format(customer.getJoinedDate()) %>
                        </p>
                    </div>
                    <div class="col-md-4">
                        <p><strong>Total Accounts:</strong> <%= accounts != null ? accounts.size() : 0 %></p>
                    </div>
                </div>
            </div>

            <div class="account-form">
                <h5 class="mb-3">Open New Account</h5>
                <form id="openAccountForm" action="${pageContext.request.contextPath}/open-account" method="post">
                    <input type="hidden" name="customerId" value="<%= customer.getId() %>">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="initialBalance" class="form-label">
                                Initial Balance (Minimum Rs. 500.00) <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text">Rs.</span>
                                <input type="number" class="form-control" id="initialBalance" name="initialBalance"
                                       min="500" step="0.01" value="500.00" required>
                            </div>
                            <div class="invalid-feedback">Minimum initial balance is Rs. 500.00</div>
                        </div>
                        <div class="col-md-6 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary" id="openAccountBtn">
                                <i class="fas fa-plus-circle me-2"></i> Create Account
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <h5 class="mt-4 mb-3">Customer Accounts</h5>
            <% if (accounts == null || accounts.isEmpty()) { %>
            <div class="alert alert-info" role="alert">
                This customer has no accounts yet.
            </div>
            <% } else { %>
            <div class="accounts-list">
                <% for (Account account : accounts) { %>
                <div class="account-card <%= account.getActiveStatus() == ActiveStatus.BLOCKED ? "inactive" : "" %>">
                    <div class="row">
                        <div class="col-md-3">
                            <h6>Account No</h6>
                            <p class="text-muted"><%= account.getAccountNo() %></p>
                        </div>
                        <div class="col-md-2">
                            <h6>Balance</h6>
                            <p class="<%= account.getBalance() >= 0 ? "balance-positive" : "balance-negative" %>">
                                Rs. <%= String.format("%,.2f", account.getBalance()) %>
                            </p>
                        </div>
                        <div class="col-md-2">
                            <h6>Created Date</h6>
                            <p class="text-muted"><%= new SimpleDateFormat("yyyy-MM-dd").format(account.getCreatedDate()) %></p>
                        </div>
                        <div class="col-md-2">
                            <h6>Yesterday EOD</h6>
                            <p class="text-muted">Rs. <%= String.format("%,.2f", account.getYesterdayEndOfDayBalance()) %></p>
                        </div>
                        <div class="col-md-2">
                            <h6>Month Interest</h6>
                            <p class="text-muted">Rs. <%= String.format("%,.2f", account.getThisMonthInterestSoFar()) %></p>
                        </div>
                        <div class="col-md-1 text-end">
                            <form action="${pageContext.request.contextPath}/toggle-account-status" method="post" class="toggle-status-form">
                                <input type="hidden" name="accountNo" value="<%= account.getAccountNo() %>">
                                <button type="submit" class="btn btn-sm <%= account.getActiveStatus() == ActiveStatus.ACTIVE ? "btn-outline-danger" : "btn-outline-success" %>">
                                    <%= account.getActiveStatus() == ActiveStatus.ACTIVE ? "Block" : "Unblock" %>
                                </button>
                            </form>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-12">
                            <span class="status-badge status-<%= account.getActiveStatus() %>">
                                <%= account.getActiveStatus() %>
                            </span>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Account Management Page Loaded');

        <c:if test="${not empty success}">
        showToast('success', '<c:out value="${success}" />');
        </c:if>

        <c:if test="${not empty error}">
        showToast('danger', '<c:out value="${error}" />');
        </c:if>

        const openAccountForm = document.getElementById('openAccountForm');
        const openAccountBtn = document.getElementById('openAccountBtn');

        openAccountForm.addEventListener('submit', function(e) {
            e.preventDefault();

            if (!validateOpenAccountForm()) {
                return;
            }

            const originalText = openAccountBtn.innerHTML;
            openAccountBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Processing...';
            openAccountBtn.disabled = true;

            const formData = new FormData(this);
            const params = new URLSearchParams();

            for (const [key, value] of formData.entries()) {
                params.append(key, value);
            }

            fetch(this.action, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params.toString()
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Response data:', data);
                    if (data.status === 'success') {
                        showToast('success', data.message);
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        showToast('danger', data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showToast('danger', 'An error occurred while processing your request');
                })
                .finally(() => {
                    openAccountBtn.innerHTML = originalText;
                    openAccountBtn.disabled = false;
                });
        });

        document.querySelectorAll('.toggle-status-form').forEach(form => {
            form.addEventListener('submit', function(e) {
                e.preventDefault();

                const button = this.querySelector('button[type="submit"]');
                const originalText = button.innerHTML;
                button.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';
                button.disabled = true;

                const formData = new FormData(this);
                const params = new URLSearchParams();

                for (const [key, value] of formData.entries()) {
                    params.append(key, value);
                }

                fetch(this.action, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: params.toString()
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log('Response data:', data);
                        if (data.status === 'success') {
                            showToast('success', data.message);
                            setTimeout(() => location.reload(), 1500);
                        } else {
                            showToast('danger', data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        showToast('danger', 'An error occurred while processing your request');
                    })
                    .finally(() => {
                        button.innerHTML = originalText;
                        button.disabled = false;
                    });
            });
        });

        document.getElementById('initialBalance').addEventListener('input', function() {
            const balance = parseFloat(this.value);
            if (isNaN(balance)) {
                this.classList.add('form-validation-error');
            } else if (balance < 500) {
                this.classList.add('form-validation-error');
            } else {
                this.classList.remove('form-validation-error');
            }
        });
    });

    function validateOpenAccountForm() {
        let isValid = true;
        const form = document.getElementById('openAccountForm');

        const balanceInput = form.querySelector('#initialBalance');
        const balance = parseFloat(balanceInput.value);
        if (isNaN(balance)) {
            balanceInput.classList.add('is-invalid');
            isValid = false;
        } else if (balance < 500) {
            balanceInput.classList.add('is-invalid');
            isValid = false;
        } else {
            balanceInput.classList.remove('is-invalid');
        }

        return isValid;
    }

    function showToast(type, message) {
        const toastId = type === 'success' ? 'dynamicSuccessToast' : 'dynamicErrorToast';
        let toastEl = document.getElementById(toastId);

        if (!toastEl) {
            toastEl = document.createElement('div');
            toastEl.id = toastId;
            toastEl.className = 'toast';
            toastEl.setAttribute('role', 'alert');
            toastEl.setAttribute('aria-live', 'assertive');
            toastEl.setAttribute('aria-atomic', 'true');

            const toastHeader = document.createElement('div');
            toastHeader.className = type === 'success' ? 'toast-header bg-success text-white' : 'toast-header bg-danger text-white';

            const strong = document.createElement('strong');
            strong.className = 'me-auto';
            strong.textContent = type === 'success' ? 'Success' : 'Error';

            const closeButton = document.createElement('button');
            closeButton.type = 'button';
            closeButton.className = 'btn-close btn-close-white';
            closeButton.setAttribute('data-bs-dismiss', 'toast');
            closeButton.setAttribute('aria-label', 'Close');

            const toastBody = document.createElement('div');
            toastBody.className = 'toast-body';

            toastHeader.appendChild(strong);
            toastHeader.appendChild(closeButton);
            toastEl.appendChild(toastHeader);
            toastEl.appendChild(toastBody);

            document.querySelector('.toast-container').appendChild(toastEl);
        }

        toastEl.querySelector('.toast-body').textContent = message;
        const toast = new bootstrap.Toast(toastEl, {
            autohide: true,
            delay: 5000
        });
        toast.show();
    }
</script>
</body>
</html>