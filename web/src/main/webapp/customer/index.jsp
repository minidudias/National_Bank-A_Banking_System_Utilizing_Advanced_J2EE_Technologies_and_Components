<%@ page import="lk.jiat.app.core.model.Account" %>
<%@ page import="java.util.List" %>
<%@ page import="lk.jiat.app.core.service.AccountService" %>
<%@ page import="lk.jiat.app.core.service.UserService" %>
<%@ page import="lk.jiat.app.core.model.User" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
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
    String minDateTime = LocalDateTime.now().plusMinutes(5).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);

    try {
        InitialContext ctx = new InitialContext();
        AccountService accountService = (AccountService) ctx.lookup("java:global/j2ee-national-bank-ear/banking-module/AccountSessionBean!lk.jiat.app.core.service.AccountService");
        UserService userService = (UserService) ctx.lookup("java:global/j2ee-national-bank-ear/auth-module/UserSessionBean!lk.jiat.app.core.service.UserService");
        User user = userService.getUserByEmail(name);
        accounts = accountService.getAccountsByUserId(user.getId());
        userName = user.getName();
    } catch (Exception e) {
        throw new RuntimeException("Error loading user data: " + e.getMessage(), e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>National Bank - Customer Dashboard</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
    <style>
        .transfer-type-container {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }
        .schedule-date-container {
            background-color: #e3f2fd;
            border: 1px solid #1976d2;
            border-radius: 8px;
            padding: 15px;
            margin-top: 10px;
        }
        .account-card {
            border-left: 4px solid #007bff;
        }
        .account-card.inactive {
            border-left-color: #dc3545;
            opacity: 0.7;
        }
        .balance-display {
            font-size: 1.2em;
            font-weight: bold;
        }
        .transfer-form {
            background-color: #ffffff;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            margin-top: 15px;
        }
        .form-validation-error {
            border-color: #dc3545;
            background-color: #f8d7da;
        }
        .spinner-border-sm {
            width: 1rem;
            height: 1rem;
        }
        .reference-counter {
            font-size: 0.875em;
        }
        .transfer-type-info {
            font-size: 0.875em;
            color: #6c757d;
            margin-top: 5px;
        }
        .datetime-help {
            font-size: 0.8em;
            color: #6c757d;
        }
        .min-datetime {
            font-size: 0.75em;
            color: #28a745;
        }
        .yesterday-balance {
            font-size: 0.95em;
            color: #6c757d;
        }
        .monthly-interest {
            font-size: 0.95em;
            font-weight: 500;
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
                            <a class="nav-link active" href="index.jsp">Do Transfers and Summary</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="history.jsp">Finished Transactions</a>
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
                        <h4 class="mb-0 text-primary">Do Transfers and Summary</h4>
                        <span class="badge bg-secondary"><%= accounts.size() %> Accounts</span>
                    </div>
                </div>
                <div class="card-body" style="max-height: calc(100vh - 200px); overflow-y: auto;">
                    <% if (accounts.isEmpty()) { %>
                    <div class="alert alert-info" role="alert">
                        <h5>No Accounts Found</h5>
                        <p>You don't have any accounts available for transfers. Please contact your bank officer to set up accounts.</p>
                    </div>
                    <% } else { %>
                    <div class="row g-4">
                        <% for (Account account : accounts) { %>
                        <div class="col-lg-6">
                            <div class="card h-100 shadow-sm border-0 account-card <%= !account.getActiveStatus().toString().equals("ACTIVE") ? "inactive" : "" %>">
                                <div class="card-header bg-light border-0">
                                    <h5 class="card-title text-primary mb-0">
                                        Account: <span class="account-number"><%= account.getAccountNo() %></span>
                                        <span class="badge bg-<%= account.getActiveStatus().toString().equals("ACTIVE") ? "success" : "danger" %> float-end">
                                                    <%= account.getActiveStatus().toString() %>
                                                </span>
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <span class="text-muted">Available Balance:</span>
                                        <span class="balance-display text-<%= account.getBalance() >= 0 ? "success" : "danger" %>">
                                                    Rs. <%= String.format("%,.2f", account.getBalance()) %>
                                                </span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <span class="text-muted">Yesterday's EOD Balance:</span>
                                        <span class="text-muted">
                Rs. <%= String.format("%,.2f", account.getYesterdayEndOfDayBalance()) %>
            </span>
                                    </div>

                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <span class="text-muted">This Month's Interest:</span>
                                        <span class="text-success">
                Rs. <%= String.format("%,.2f", account.getThisMonthInterestSoFar()) %>
            </span>
                                    </div>

                                    <% if (account.getActiveStatus().toString().equals("ACTIVE")) { %>

                                    <div class="transfer-form">
                                        <form class="transfer-form-element"
                                              data-account-id="<%= account.getId() %>"
                                              data-account-number="<%= account.getAccountNo() %>"
                                              data-max-balance="<%= account.getBalance() %>">

                                            <input type="hidden" name="sourceAccountNo" value="<%= account.getAccountNo() %>">

                                            <div class="mb-3">
                                                <label for="destination<%= account.getId() %>" class="form-label">
                                                    Destination Account <span class="text-danger">*</span>
                                                </label>
                                                <input type="text"
                                                       class="form-control destination-input"
                                                       id="destination<%= account.getId() %>"
                                                       name="destinationAccountNo"
                                                       placeholder="Enter destination account number"
                                                       required
                                                       maxlength="10">
                                                <div class="invalid-feedback">
                                                    Please enter a valid destination account number
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <label for="amount<%= account.getId() %>" class="form-label">
                                                    Amount (Rs.) <span class="text-danger">*</span>
                                                </label>
                                                <input type="number"
                                                       class="form-control amount-input"
                                                       id="amount<%= account.getId() %>"
                                                       name="amount"
                                                       min="0.01"
                                                       max="<%= account.getBalance() %>"
                                                       step="0.01"
                                                       placeholder="Max: Rs. <%= String.format("%,.2f", account.getBalance()) %>"
                                                       required>
                                                <div class="invalid-feedback">
                                                    Please enter a valid amount (0.01 to <%= String.format("%,.2f", account.getBalance()) %>)
                                                </div>
                                            </div>

                                            <div class="transfer-type-container">
                                                <div class="mb-3">
                                                    <label class="form-label">Transfer Type <span class="text-danger">*</span></label>
                                                    <div class="form-check">
                                                        <input class="form-check-input transfer-type-radio"
                                                               type="radio"
                                                               name="transferType"
                                                               id="immediate<%= account.getId() %>"
                                                               value="immediate"
                                                               checked>
                                                        <label class="form-check-label" for="immediate<%= account.getId() %>">
                                                            <strong>Immediate Transfer</strong>
                                                            <div class="transfer-type-info">
                                                                Process the transfer immediately
                                                            </div>
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input transfer-type-radio"
                                                               type="radio"
                                                               name="transferType"
                                                               id="scheduled<%= account.getId() %>"
                                                               value="scheduled">
                                                        <label class="form-check-label" for="scheduled<%= account.getId() %>">
                                                            <strong>Scheduled Transfer</strong>
                                                            <div class="transfer-type-info">
                                                                Schedule the transfer for a future date and time
                                                            </div>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <label for="reference<%= account.getId() %>" class="form-label">
                                                    Reference <span class="text-muted">(Optional)</span>
                                                </label>
                                                <input type="text"
                                                       class="form-control reference-input"
                                                       id="reference<%= account.getId() %>"
                                                       name="reference"
                                                       maxlength="30"
                                                       placeholder="Enter reference for this transfer">
                                                <div class="reference-counter">
                                                    <span id="referenceCount<%= account.getId() %>">0</span>/30 characters
                                                </div>
                                            </div>
                                            <div class="schedule-date-container"
                                                 id="scheduleDateContainer<%= account.getId() %>"
                                                 style="display: none;">
                                                <label for="scheduleDate<%= account.getId() %>" class="form-label">
                                                    Schedule Date & Time <span class="text-danger">*</span>
                                                </label>
                                                <input type="datetime-local"
                                                       class="form-control schedule-date-input"
                                                       id="scheduleDate<%= account.getId() %>"
                                                       name="scheduleDate"
                                                       min="<%= minDateTime %>">
                                                <div class="datetime-help">
                                                    <div class="min-datetime">
                                                        Must be at least 5 minutes ahead of current time.
                                                    </div>
                                                    <small class="text-muted">
                                                        The transfer will be executed at exactly this date and time.
                                                    </small>
                                                </div>
                                                <div class="invalid-feedback">
                                                    Please select a valid future date and time (at least 5 minutes from now)
                                                </div>
                                            </div>
                                            <div class="d-grid gap-2 mt-4">
                                                <button type="submit" class="btn btn-primary btn-lg transfer-btn">
                                                    <i class="fas fa-paper-plane me-2"></i>
                                                    Transfer Now
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                    <% } else { %>

                                    <div class="alert alert-warning" role="alert">
                                        <h6>Account Inactive</h6>
                                        <p class="mb-0">This account is currently inactive and cannot be used for transfers. Please contact your bank officer.</p>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Customer Transfer Page Loaded');

        <c:if test="${not empty success}">
        var successToast = new bootstrap.Toast(document.getElementById('successToast'));
        successToast.show();
        </c:if>

        <c:if test="${not empty error}">
        var errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
        errorToast.show();
        </c:if>

        initializeTransferForms();
    });

    function initializeTransferForms() {
        document.querySelectorAll('.transfer-type-radio').forEach(radio => {
            radio.addEventListener('change', handleTransferTypeChange);
        });


        document.querySelectorAll('.reference-input').forEach(input => {
            input.addEventListener('input', handleReferenceInput);
        });

        document.querySelectorAll('.transfer-form-element').forEach(form => {
            form.addEventListener('submit', handleTransferSubmit);
        });

        setupRealTimeValidation();
    }

    function handleTransferTypeChange(event) {
        const radio = event.target;
        const accountId = extractAccountId(radio.id);
        const container = document.getElementById('scheduleDateContainer' + accountId);
        const scheduleDateInput = document.getElementById('scheduleDate' + accountId);
        const button = radio.closest('.transfer-form-element').querySelector('.transfer-btn');

        console.log('Transfer type changed:', radio.value, 'for account:', accountId);

        if (radio.value === 'scheduled' && radio.checked) {
            container.style.display = 'block';
            button.innerHTML = '<i class="fas fa-clock me-2"></i>Schedule Transfer';
            scheduleDateInput.required = true;

            const now = new Date();
            now.setMinutes(now.getMinutes() + 5);
            scheduleDateInput.min = now.toISOString().slice(0, 16);

        } else if (radio.value === 'immediate' && radio.checked) {
            container.style.display = 'none';
            button.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Transfer Now';
            scheduleDateInput.value = '';
            scheduleDateInput.required = false;

            scheduleDateInput.classList.remove('is-invalid');
        }
    }

    function handleReferenceInput(event) {
        const input = event.target;
        const accountId = extractAccountId(input.id);
        const counter = document.getElementById('referenceCount' + accountId);
        const currentLength = input.value.length;
        const maxLength = parseInt(input.getAttribute('maxlength'));

        counter.textContent = currentLength;

        if (currentLength > maxLength * 0.9) {
            counter.style.color = '#fd7e14';
        } else if (currentLength > maxLength * 0.7) {
            counter.style.color = '#1eac60';
        } else {
            counter.style.color = '#6c757d';
        }
    }

    function handleTransferSubmit(event) {
        event.preventDefault();

        const form = event.target;
        const button = form.querySelector('.transfer-btn');
        const originalButtonContent = button.innerHTML;

        console.log('Transfer form submitted');

        if (!validateTransferForm(form)) {
            console.log('Form validation failed');
            return;
        }

        button.disabled = true;
        button.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Processing...';

        const formData = new FormData(form);
        const params = new URLSearchParams();

        for (const [key, value] of formData.entries()) {
            params.append(key, value);
        }

        console.log('Sending transfer request:', params.toString());

        fetch('${pageContext.request.contextPath}/transfer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: params.toString()
        })
            .then(response => {
                console.log('Transfer response status:', response.status);
                return response.json();
            })
            .then(data => {
                console.log('Transfer response data:', data);

                if (data.status === 'success') {
                    showToast('success', data.message);
                    form.reset();
                    resetFormState(form);
                    setTimeout(() => {
                        window.location.reload();
                    }, 2000);
                } else {
                    showToast('danger', data.message || 'Transfer failed');
                }
            })
            .catch(error => {
                console.error('Transfer error:', error);
                showToast('danger', 'Network error occurred. Please try again.');
            })
            .finally(() => {
                button.disabled = false;
                button.innerHTML = originalButtonContent;
            });
    }

    function validateTransferForm(form) {
        let isValid = true;
        const accountNumber = form.dataset.accountNumber;
        const maxBalance = parseFloat(form.dataset.maxBalance);

        form.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });

        const destinationInput = form.querySelector('.destination-input');
        const destinationValue = destinationInput.value.trim();

        if (!destinationValue) {
            destinationInput.classList.add('is-invalid');
            isValid = false;
        } else if (destinationValue === accountNumber) {
            destinationInput.classList.add('is-invalid');
            showToast('danger', 'Cannot transfer to the same account');
            isValid = false;
        }

        const amountInput = form.querySelector('.amount-input');
        const amountValue = parseFloat(amountInput.value);

        if (!amountValue || amountValue <= 0) {
            amountInput.classList.add('is-invalid');
            isValid = false;
        } else if (amountValue > maxBalance) {
            amountInput.classList.add('is-invalid');
            showToast('danger', 'Amount exceeds available balance');
            isValid = false;
        }

        const scheduledRadio = form.querySelector('input[name="transferType"][value="scheduled"]');
        if (scheduledRadio && scheduledRadio.checked) {
            const scheduleDateInput = form.querySelector('.schedule-date-input');
            const scheduleDateValue = scheduleDateInput.value;

            if (!scheduleDateValue) {
                scheduleDateInput.classList.add('is-invalid');
                isValid = false;
            } else {
                const scheduleDate = new Date(scheduleDateValue);
                const minDate = new Date();
                minDate.setMinutes(minDate.getMinutes() + 5);

                if (scheduleDate <= minDate) {
                    scheduleDateInput.classList.add('is-invalid');
                    showToast('danger', 'Schedule date must be at least 5 minutes in the future');
                    isValid = false;
                }
            }
        }

        return isValid;
    }

    function setupRealTimeValidation() {
        document.querySelectorAll('.amount-input').forEach(input => {
            input.addEventListener('input', function() {
                const value = parseFloat(this.value);
                const max = parseFloat(this.max);

                if (value > max) {
                    this.classList.add('form-validation-error');
                } else {
                    this.classList.remove('form-validation-error');
                }
            });
        });

        document.querySelectorAll('.destination-input').forEach(input => {
            input.addEventListener('input', function() {
                const form = this.closest('.transfer-form-element');
                const accountNumber = form.dataset.accountNumber;

                if (this.value.trim() === accountNumber) {
                    this.classList.add('form-validation-error');
                } else {
                    this.classList.remove('form-validation-error');
                }
            });
        });
    }

    function resetFormState(form) {
        const immediateRadio = form.querySelector('input[name="transferType"][value="immediate"]');
        if (immediateRadio) {
            immediateRadio.checked = true;
            immediateRadio.dispatchEvent(new Event('change'));
        }

        const referenceInputs = form.querySelectorAll('.reference-input');
        referenceInputs.forEach(input => {
            const accountId = extractAccountId(input.id);
            const counter = document.getElementById('referenceCount' + accountId);
            if (counter) {
                counter.textContent = '0';
                counter.style.color = '#6c757d';
            }
        });

        form.querySelectorAll('.is-invalid, .form-validation-error').forEach(el => {
            el.classList.remove('is-invalid', 'form-validation-error');
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

    function extractAccountId(elementId) {
        return elementId.replace(/^[a-zA-Z]+/, '');
    }
</script>
</body>
</html>