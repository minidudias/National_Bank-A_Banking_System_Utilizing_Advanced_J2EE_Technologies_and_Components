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
import lk.jiat.app.core.exception.BankingException;
import lk.jiat.app.core.service.TransactionService;
import lk.jiat.app.core.service.UserService;
import lk.jiat.app.core.model.User;
import java.io.IOException;

@WebServlet("/cancel-scheduled")
public class CancelScheduled extends HttpServlet {

    @EJB
    private TransactionService transactionService;

    @EJB
    private UserService userService;

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
            String scheduledIdStr = request.getParameter("scheduledId");
            if (scheduledIdStr == null || scheduledIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Scheduled transaction ID is required");
            }

            Long scheduledId = Long.parseLong(scheduledIdStr);
            transactionService.cancelScheduledTransaction(scheduledId, user.getId());

            jsonResponse = Json.createObjectBuilder()
                    .add("status", "success")
                    .add("message", "Scheduled transaction cancelled successfully")
                    .build();
        } catch (BankingException | IllegalArgumentException e) {
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

    private void sendError(HttpServletResponse response, String message) throws IOException {
        JsonObject jsonResponse = Json.createObjectBuilder()
                .add("status", "error")
                .add("message", message)
                .build();
        response.getWriter().write(jsonResponse.toString());
    }
}