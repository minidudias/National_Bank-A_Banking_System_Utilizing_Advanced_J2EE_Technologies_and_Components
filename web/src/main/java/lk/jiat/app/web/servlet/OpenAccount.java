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
import lk.jiat.app.core.model.User;
import lk.jiat.app.core.service.AccountNumberGeneratorService;
import lk.jiat.app.core.service.AccountService;
import lk.jiat.app.core.service.UserService;
import java.io.IOException;

@WebServlet("/open-account")
public class OpenAccount extends HttpServlet {

    @EJB
    private AccountService accountService;

    @EJB
    private UserService userService;

    @Inject
    private SecurityContext securityContext;

    @EJB
    private AccountNumberGeneratorService accountNumberGeneratorService;

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
            String customerId = request.getParameter("customerId");
            String initialBalanceStr = request.getParameter("initialBalance");
            String bankerEmail = securityContext.getCallerPrincipal().getName();

            if (customerId == null || customerId.trim().isEmpty()) {
                throw new IllegalArgumentException("Customer ID is required");
            }
            if (initialBalanceStr == null || initialBalanceStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Initial balance is required");
            }

            double initialBalance = Double.parseDouble(initialBalanceStr);
            if (initialBalance < 500) {
                throw new IllegalArgumentException("Minimum initial balance is Rs. 500.00");
            }

            User customer = userService.getUserById(Long.parseLong(customerId));
            if (customer == null) {
                throw new IllegalArgumentException("Customer not found");
            }

            if (customer.getEmail().equals(bankerEmail)) {
                throw new SecurityException("Bank officers cannot create accounts for themselves");
            }

            String accountNo = accountNumberGeneratorService.generateAccountNumber();

            Account account = new Account();
            account.setAccountNo(accountNo);
            account.setBalance(initialBalance);
            account.setUser(customer);
            account.setActiveStatus(ActiveStatus.ACTIVE);
            account.setYesterdayEndOfDayBalance(0.00);
            account.setThisMonthInterestSoFar(0.00);

            accountService.addAccount(account);

            jsonResponse = Json.createObjectBuilder()
                    .add("status", "success")
                    .add("message", "Account " + accountNo + " created successfully with initial balance Rs. " +
                            String.format("%,.2f", initialBalance))
                    .build();

        } catch (IllegalArgumentException | InvalidAccountException | SecurityException e) {
            jsonResponse = Json.createObjectBuilder()
                    .add("status", "error")
                    .add("message", e.getMessage())
                    .build();
        } catch (Exception e) {
            jsonResponse = Json.createObjectBuilder()
                    .add("status", "error")
                    .add("message", "An unexpected error occurred while creating account")
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