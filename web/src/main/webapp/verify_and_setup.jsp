<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);

  // Redirect if already logged in
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
  <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
  <link rel="icon" href="${pageContext.request.contextPath}/img/logo.png" />
  <title>National Bank - Verification and Setup</title>
  <style>
    .form-container {
      max-width: 500px;
      margin: 0 auto;
    }
    .invalid-feedback {
      display: none;
      color: #dc3545;
      font-size: 0.875em;
    }
    .is-invalid ~ .invalid-feedback {
      display: block;
    }
  </style>
</head>
<body class="bg-light">
<div class="container">
  <div class="row justify-content-center align-items-center min-vh-100">
    <div class="col-md-6 col-lg-5">
      <div class="card shadow-lg">
        <div class="card-body text-center">
          <img src="${pageContext.request.contextPath}/img/logo.png" alt="Logo" class="img-fluid mb-3" style="max-height: 220px;">
          <h3 class="card-title mb-4">Verification & Setup</h3>

          <form id="setupForm" method="POST" action="${pageContext.request.contextPath}/verify-setup">

            <div class="mb-3 text-start">
              <label for="email" class="form-label">Email Address <span class="text-danger">*</span></label>
              <input type="email" class="form-control" id="email" name="email" required
                     value="${param.email}">
              <div class="invalid-feedback">Please provide a valid email address.</div>
            </div>

            <div class="mb-3 text-start">
              <label for="verificationCode" class="form-label">Verification Code <span class="text-danger">*</span></label>
              <input type="text" class="form-control" id="verificationCode" name="verificationCode"
                     required pattern="^[A-Z0-9]{8}$">
              <div class="invalid-feedback">Please enter your 8 character verification code.</div>
            </div>

            <div class="mb-3 text-start">
              <label for="password" class="form-label">Password <span class="text-danger">*</span></label>
              <input type="password" class="form-control" id="password" name="password" required
                     >
              <div class="invalid-feedback">
                Password must be 6-30 characters with at least one letter and one number.
              </div>
            </div>

            <div class="mb-4 text-start">
              <label for="confirmPassword" class="form-label">Confirm Password <span class="text-danger">*</span></label>
              <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
              <div class="invalid-feedback">Passwords do not match.</div>
            </div>

            <div class="d-grid">
              <button type="submit" class="btn btn-primary" id="submitBtn">
                <span class="spinner-border spinner-border-sm d-none" id="spinner" role="status" aria-hidden="true"></span>
                Complete Setup
              </button>
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
      <strong class="me-auto">Error</strong>
      <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
    <div class="toast-body">
      <c:out value="${error}" />
    </div>
  </div>

  <div id="successToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="toast-header bg-success text-white">
      <strong class="me-auto">Success</strong>
      <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
    <div class="toast-body">
      <c:out value="${success}" />
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    <c:if test="${not empty error}">
    var errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
    errorToast.show();
    </c:if>

    <c:if test="${not empty success}">
    var successToast = new bootstrap.Toast(document.getElementById('successToast'));
    successToast.show();
    </c:if>

    // Form validation
    const form = document.getElementById('setupForm');
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');

    // Validate password match on confirm password change
    confirmPassword.addEventListener('input', function() {
      if (password.value !== confirmPassword.value) {
        confirmPassword.classList.add('is-invalid');
      } else {
        confirmPassword.classList.remove('is-invalid');
      }
    });

    form.addEventListener('submit', function(e) {
      e.preventDefault();

      // Validate passwords match
      if (password.value !== confirmPassword.value) {
        confirmPassword.classList.add('is-invalid');
        return;
      }

      // Show loading spinner
      const spinner = document.getElementById('spinner');
      const submitBtn = document.getElementById('submitBtn');
      spinner.classList.remove('d-none');
      submitBtn.disabled = true;

      fetch(form.action, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams(new FormData(form))
      })
              .then(response => response.json())
              .then(data => {
                if (data.status === 'success') {
                  window.location.href = '${pageContext.request.contextPath}/index.jsp?success=' +
                          encodeURIComponent(data.message);
                } else {
                  // Show error message in toast
                  const toastBody = document.querySelector('#errorToast .toast-body');
                  toastBody.textContent = data.message;
                  const errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
                  errorToast.show();

                  // Reset form state
                  spinner.classList.add('d-none');
                  submitBtn.disabled = false;
                }
              })
              .catch(error => {
                console.error('Error:', error);
                const toastBody = document.querySelector('#errorToast .toast-body');
                toastBody.textContent = 'An error occurred. Please try again.';
                const errorToast = new bootstrap.Toast(document.getElementById('errorToast'));
                errorToast.show();

                spinner.classList.add('d-none');
                submitBtn.disabled = false;
              });
    });
  });
</script>
</body>
</html>