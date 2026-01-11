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
import lk.jiat.app.core.exception.InvalidAccountException;
import lk.jiat.app.core.model.Account;
import lk.jiat.app.core.model.ActiveStatus;
import lk.jiat.app.core.service.AccountService;
import lk.jiat.app.core.service.UserService;

import java.io.IOException;

@WebServlet("/toggle-account-status")
public class ToggleAccountStatus extends HttpServlet {

    @EJB
    private AccountService accountService;

    @Inject
    private SecurityContext securityContext;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (securityContext.getCallerPrincipal() == null || !securityContext.isCallerInRole("BANK_OFFICER")) {
            sendError(response, "Unauthorized access");
            return;
        }

        JsonObject jsonResponse;

        try {
            String accountNo = request.getParameter("accountNo");
            String bankerEmail = securityContext.getCallerPrincipal().getName();

            if (accountNo == null || accountNo.trim().isEmpty()) {
                throw new IllegalArgumentException("Account number is required");
            }
            Account account = accountService.getAccountByAccountNo(accountNo);
            if (account == null) {
                throw new InvalidAccountException("Account not found: " + accountNo);
            }
            if (account.getUser().getEmail().equals(bankerEmail)) {
                throw new SecurityException("Bank officers cannot modify their own accounts");
            }
            ActiveStatus newStatus = accountService.toggleActiveStatus(accountNo);
            if (newStatus == null) {
                throw new InvalidAccountException("Failed to update account status");
            }

            String action = newStatus == ActiveStatus.ACTIVE ? "unblocked" : "blocked";
            jsonResponse = Json.createObjectBuilder()
                    .add("status", "success")
                    .add("message", "Account " + accountNo + " has been " + action + " successfully")
                    .build();

        } catch (IllegalArgumentException | InvalidAccountException | SecurityException e) {
            jsonResponse = Json.createObjectBuilder()
                    .add("status", "error")
                    .add("message", e.getMessage())
                    .build();
        } catch (Exception e) {
            jsonResponse = Json.createObjectBuilder()
                    .add("status", "error")
                    .add("message", "An unexpected error occurred while updating account status")
                    .build();
            e.printStackTrace();
        }

        response.getWriter().write(jsonResponse.toString());
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        JsonObject jsonResponse = Json.createObjectBuilder()
                .add("status", "error")
                .add("message", message)
                .build();
        response.getWriter().write(jsonResponse.toString());
    }
}