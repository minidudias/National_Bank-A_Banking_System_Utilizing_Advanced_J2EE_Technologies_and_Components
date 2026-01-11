package lk.jiat.app.web.servlet;

import jakarta.ejb.EJB;
import jakarta.inject.Inject;
import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.security.enterprise.SecurityContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.jiat.app.core.exception.*;
import lk.jiat.app.core.model.TransactionType;
import lk.jiat.app.core.model.User;
import lk.jiat.app.core.service.AccountService;
import lk.jiat.app.core.service.TransactionService;
import lk.jiat.app.core.service.UserService;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import lk.jiat.app.core.regex.Validations;

@WebServlet("/transfer")
public class Transfer extends HttpServlet {

    @EJB
    private TransactionService transactionService;

    @EJB
    private UserService userService;

    @EJB
    private AccountService accountService;

    @Inject
    private SecurityContext securityContext;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (securityContext.getCallerPrincipal() == null) {
            sendError(response, "Authentication required");
            return;
        }

        String email = securityContext.getCallerPrincipal().getName();
        User user = userService.getUserByEmail(email);
        if (user == null) {
            sendError(response, "User not found");
            return;
        }

        JsonObject jsonResponse;

        try {
            String sourceAccountNo = request.getParameter("sourceAccountNo");
            String destinationAccountNo = request.getParameter("destinationAccountNo");
            String amountStr = request.getParameter("amount");
            String reference = request.getParameter("reference");
            String transferType = request.getParameter("transferType");
            String scheduleDateStr = request.getParameter("scheduleDate");

           validateCommonParameters(sourceAccountNo, destinationAccountNo, amountStr);

            if (!Validations.isValidAccountNo(destinationAccountNo.trim())) {
                throw new IllegalArgumentException("Destination account number must be 10 digits starting with 1-9");
            }
            if (!Validations.isDouble(amountStr.trim())) {
                throw new IllegalArgumentException("Amount must be a valid number with up to 2 decimal places");
            }
            if (!accountService.isAccountOwnedByUser(sourceAccountNo, user.getId())) {
                throw new SecurityException("Source account does not belong to the authenticated user");
            }

            double amount = Double.parseDouble(amountStr.trim());

            if ("scheduled".equals(transferType)) {
                if (scheduleDateStr == null || scheduleDateStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("Schedule date is required for scheduled transfers");
                }

                LocalDateTime scheduleDate = parseScheduleDate(scheduleDateStr);
                transactionService.scheduleTransfer(
                        sourceAccountNo, destinationAccountNo, amount, reference, scheduleDate, user.getId());

                jsonResponse = Json.createObjectBuilder()
                        .add("status", "success")
                        .add("message", "Transfer scheduled successfully!")
                        .build();
            } else {
                transactionService.transferAmount(
                        sourceAccountNo, destinationAccountNo, amount, reference, TransactionType.IMMEDIATE, user.getId());

                jsonResponse = Json.createObjectBuilder()
                        .add("status", "success")
                        .add("message", "Transfer completed successfully!")
                        .build();
            }
        } catch (InvalidAccountException | InsufficientFundsException |
                 TransactionFailedException | IllegalArgumentException |
                 SecurityException e) {
            jsonResponse = Json.createObjectBuilder()
                    .add("status", "error")
                    .add("message", e.getMessage())
                    .build();
        } catch (Exception e) {
            jsonResponse = Json.createObjectBuilder()
                    .add("status", "error")
                    .add("message", "An unexpected error occurred")
                    .build();
            e.printStackTrace();
        }

        response.getWriter().write(jsonResponse.toString());
    }

    private void validateCommonParameters(String source, String dest, String amount)
            throws IllegalArgumentException {
        if (source == null || source.trim().isEmpty()) {
            throw new IllegalArgumentException("Source account number is required");
        }
        if (dest == null || dest.trim().isEmpty()) {
            throw new IllegalArgumentException("Destination account number is required");
        }
        if (amount == null || amount.trim().isEmpty()) {
            throw new IllegalArgumentException("Amount is required");
        }
        try {
            if (Double.parseDouble(amount) <= 0) {
                throw new IllegalArgumentException("Amount must be positive");
            }
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid amount format");
        }
    }

    private LocalDateTime parseScheduleDate(String dateStr) throws IllegalArgumentException {
        try {
            LocalDateTime scheduleDate = LocalDateTime.parse(dateStr);
            if (scheduleDate.isBefore(LocalDateTime.now().plusMinutes(5))) {
                throw new IllegalArgumentException("Schedule date must be at least 5 minutes in the future");
            }
            return scheduleDate;
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid schedule date format. Use YYYY-MM-DDTHH:MM");
        }
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        JsonObject jsonResponse = Json.createObjectBuilder()
                .add("status", "error")
                .add("message", message)
                .build();
        response.getWriter().write(jsonResponse.toString());
    }
}