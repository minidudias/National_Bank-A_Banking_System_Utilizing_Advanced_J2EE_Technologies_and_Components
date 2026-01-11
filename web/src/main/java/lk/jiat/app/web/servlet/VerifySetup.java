package lk.jiat.app.web.servlet;

import jakarta.ejb.EJB;
import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.jiat.app.core.exception.RegistrationException;
import lk.jiat.app.core.model.User;
import lk.jiat.app.core.model.VerifiedStatus;
import lk.jiat.app.core.regex.Validations;
import lk.jiat.app.core.service.UserService;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/verify-setup")
public class VerifySetup extends HttpServlet {

    @EJB
    private UserService userService;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String verificationCode = request.getParameter("verificationCode");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        try (PrintWriter out = response.getWriter()) {
            JsonObject jsonResponse;

            try {
                if (email == null || email.trim().isEmpty() || !Validations.isEmailValid(email)) {
                    throw new RegistrationException("Please provide a valid email address");
                }

                if (verificationCode == null || verificationCode.trim().isEmpty()) {
                    throw new RegistrationException("Verification code is required");
                }

                if (password == null || password.trim().isEmpty()) {
                    throw new RegistrationException("Password is required");
                }

                if (!password.equals(confirmPassword)) {
                    throw new RegistrationException("Passwords do not match");
                }

                User user = userService.getUserByEmail(email);
                if (user == null) {
                    throw new RegistrationException("No account found with this email address");
                }

                if (user.getVerifiedStatus() == VerifiedStatus.VERIFIED) {
                    throw new RegistrationException("This account is already verified. Please login.");
                }

                if (!Validations.isValidVerificationCode(verificationCode)) {
                    throw new RegistrationException("This is not a valid verification code");
                }

                if (!verificationCode.equals(user.getVerificationCode())) {
                    throw new RegistrationException("Invalid verification code");
                }

                if (!Validations.isPasswordValid(password)) {
                    throw new RegistrationException("Password must be 6-30 characters with at least one letter and one number");
                }

                user.setPassword(password);
                user.setVerifiedStatus(VerifiedStatus.VERIFIED);
                userService.updateUser(user);

                jsonResponse = Json.createObjectBuilder()
                        .add("status", "success")
                        .add("message", "Account setup completed successfully. You can now login.")
                        .build();

            } catch (RegistrationException e) {
                jsonResponse = Json.createObjectBuilder()
                        .add("status", "error")
                        .add("message", e.getMessage())
                        .build();
            } catch (Exception e) {
                jsonResponse = Json.createObjectBuilder()
                        .add("status", "error")
                        .add("message", "An unexpected error occurred. Please try again.")
                        .build();
                e.printStackTrace();
            }

            out.print(jsonResponse.toString());
            out.flush();
        }
    }
}