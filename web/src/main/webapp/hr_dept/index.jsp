<%@ page import="lk.jiat.app.core.model.User" %>
<%@ page import="lk.jiat.app.core.model.UserType" %>
<%@ page import="lk.jiat.app.core.model.VerifiedStatus" %>
<%@ page import="lk.jiat.app.core.service.UserService" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (request.getUserPrincipal() == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    if (!request.isUserInRole("HR_DEPARTMENT")) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    List<User> bankOfficers;

    try {
        InitialContext ctx = new InitialContext();
        UserService userService = (UserService) ctx.lookup("java:global/j2ee-national-bank-ear/auth-module/UserSessionBean!lk.jiat.app.core.service.UserService");
        bankOfficers = userService.getUsersByUserType(UserType.BANK_OFFICER);
    } catch (Exception e) {
        throw new RuntimeException("Error loading bank officers: " + e.getMessage(), e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>National Bank - HR Department Dashboard</title>
    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
    <style>
        .register-form {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .officers-list {
            max-height: 500px;
            overflow-y: auto;
            border: 1px solid #dee2e6;
            border-radius: 8px;
        }
        .officer-card {
            border-left: 4px solid #007bff;
            margin-bottom: 10px;
            padding: 15px;
            background-color: #ffffff;
            border-radius: 4px;
        }
        .officer-card:hover {
            background-color: #f8f9fa;
        }
        .verified-badge {
            font-size: 0.8em;
            padding: 4px 8px;
        }
        .verified-VERIFIED {
            background-color: #28a745;
            color: white;
        }
        .verified-UNVERIFIED {
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
    </style>
</head>
<body>
<div class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center" href="#">
            <img src="${pageContext.request.contextPath}/img/logo.png" alt="Logo" width="40" height="40" class="me-2">
            National Bank - HR Dashboard
        </a>
        <div class="navbar-nav ms-auto">
            <div class="nav-item dropdown">
                <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                    Welcome, HR Department!
                </a>
                <ul class="dropdown-menu">
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
            <h4 class="mb-0 text-primary">Bank Officer Management</h4>
        </div>
        <div class="card-body">
            <div class="register-form">
                <h5 class="mb-3">Register New Bank Officer</h5>
                <form id="registerOfficerForm" action="${pageContext.request.contextPath}/register-officer" method="post">
                    <div class="row g-3">
                        <div class="col-md-3">
                            <label for="name" class="form-label">Full Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" required>
                            <div class="invalid-feedback">Please enter a valid name</div>
                        </div>
                        <div class="col-md-3">
                            <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" required>
                            <div class="invalid-feedback">Please enter a valid email</div>
                        </div>
                        <div class="col-md-3">
                            <label for="contact" class="form-label">Contact Number <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" id="contact" name="contact" required>
                            <div class="invalid-feedback">Please enter a valid contact number</div>
                        </div>
                        <div class="col-md-3">
                            <label for="nic" class="form-label">NIC Number <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="nic" name="nic" required>
                            <div class="invalid-feedback">Please enter a valid NIC number</div>
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary" id="registerOfficerBtn">
                                <i class="fas fa-user-plus me-2"></i> Register Officer
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <h5 class="mt-4 mb-3">Registered Bank Officers</h5>
            <% if (bankOfficers.isEmpty()) { %>
            <div class="alert alert-info" role="alert">
                No bank officers registered yet.
            </div>
            <% } else { %>
            <div class="officers-list">
                <% for (User officer : bankOfficers) { %>
                <div class="officer-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="mb-1"><%= officer.getName() %></h6>
                            <div class="text-muted small"><%= officer.getEmail() %></div>
                            <div class="text-muted small"><%= officer.getContact() %></div>
                            <div class="text-muted small">NIC: <%= officer.getNic() %></div>
                        </div>
                        <div>
                                    <span class="verified-badge verified-<%= officer.getVerifiedStatus() %>">
                                        <%= officer.getVerifiedStatus() %>
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
        console.log('HR Department Dashboard Loaded');

        <c:if test="${not empty success}">
        showToast('success', '<c:out value="${success}" />');
        </c:if>

        <c:if test="${not empty error}">
        showToast('danger', '<c:out value="${error}" />');
        </c:if>

        const registerForm = document.getElementById('registerOfficerForm');
        const registerBtn = document.getElementById('registerOfficerBtn');

        registerForm.addEventListener('submit', function(e) {
            e.preventDefault();

            if (!validateOfficerForm()) {
                return;
            }

            const originalText = registerBtn.innerHTML;
            registerBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Processing...';
            registerBtn.disabled = true;

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
                        this.reset();
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
                    registerBtn.innerHTML = originalText;
                    registerBtn.disabled = false;
                });
        });

        document.getElementById('contact').addEventListener('input', function() {
            const contact = this.value.trim();
            if (!isValidSriLankanMobile(contact)) {
                this.classList.add('form-validation-error');
            } else {
                this.classList.remove('form-validation-error');
            }
        });

        document.getElementById('nic').addEventListener('input', function() {
            const nic = this.value.trim();
            if (!isValidSriLankanNIC(nic)) {
                this.classList.add('form-validation-error');
            } else {
                this.classList.remove('form-validation-error');
            }
        });
    });

    function validateOfficerForm() {
        let isValid = true;
        const form = document.getElementById('registerOfficerForm');

        const nameInput = form.querySelector('#name');
        if (nameInput.value.trim() === '') {
            nameInput.classList.add('is-invalid');
            isValid = false;
        } else {
            nameInput.classList.remove('is-invalid');
        }

        const emailInput = form.querySelector('#email');
        if (!isValidEmail(emailInput.value.trim())) {
            emailInput.classList.add('is-invalid');
            isValid = false;
        } else {
            emailInput.classList.remove('is-invalid');
        }

        const contactInput = form.querySelector('#contact');
        if (!isValidSriLankanMobile(contactInput.value.trim())) {
            contactInput.classList.add('is-invalid');
            isValid = false;
        } else {
            contactInput.classList.remove('is-invalid');
        }

        const nicInput = form.querySelector('#nic');
        if (!isValidSriLankanNIC(nicInput.value.trim())) {
            nicInput.classList.add('is-invalid');
            isValid = false;
        } else {
            nicInput.classList.remove('is-invalid');
        }

        return isValid;
    }

    function isValidEmail(email) {
        const re = /^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+$/;
        return re.test(email);
    }

    function isValidSriLankanMobile(contact) {
        const re = /^07[01245678]{1}[0-9]{7}$/;
        return re.test(contact);
    }

    function isValidSriLankanNIC(nic) {
        const re = /^(([5-9][0-9][0-35-8][0-9]{6}[vVxX])|([12][09][0-9]{2}[0-35-8][0-9]{7}))$/;
        return re.test(nic);
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