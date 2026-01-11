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
import lk.jiat.app.core.exception.RegistrationException;
import lk.jiat.app.core.model.User;
import lk.jiat.app.core.model.UserType;
import lk.jiat.app.core.model.VerifiedStatus;
import lk.jiat.app.core.provider.Mail;
import lk.jiat.app.core.service.UserService;
import lk.jiat.app.core.regex.Validations;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Date;

@WebServlet("/register-officer")
public class RegisterOfficer extends HttpServlet {

    @EJB
    private UserService userService;

    @Inject
    private SecurityContext securityContext;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (securityContext.getCallerPrincipal() == null || !securityContext.isCallerInRole("HR_DEPARTMENT")) {
            sendError(response, "Unauthorized access");
            return;
        }

        JsonObject jsonResponse;

        try {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String contact = request.getParameter("contact");
            String nic = request.getParameter("nic");

            validateInputs(name, email, contact, nic);

            if (userService.getUserByEmail(email) != null) {
                throw new RegistrationException("Email already registered");
            }

            String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            SecureRandom random = new SecureRandom();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 8; i++) {
                sb.append(chars.charAt(random.nextInt(chars.length())));
            }
            String verificationCode = sb.toString();
            User officer = new User();
            officer.setName(name);
            officer.setEmail(email);
            officer.setContact(contact);
            officer.setNic(nic);
            officer.setJoinedDate(new Date(System.currentTimeMillis()));
            officer.setUserType(UserType.BANK_OFFICER);
            officer.setVerifiedStatus(VerifiedStatus.UNVERIFIED);
            officer.setVerificationCode(verificationCode);

            Thread emailSenderThread = new Thread(){
                @Override
                public void run(){
                    Mail.sendMail(email, "National Bank Officer Verification",
                            "<h1 style=\"color:#007bff;\">Your National Bank profile verification code is: " + verificationCode + "</h1>"
                    );
                }
            };
            emailSenderThread.start();

            userService.addUser(officer);

            jsonResponse = Json.createObjectBuilder()
                    .add("status", "success")
                    .add("message", "Bank officer registered successfully. Temporary code was sent to their email. : " + email)
                    .build();

        } catch (RegistrationException | IllegalArgumentException e) {
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

    private void validateInputs(String name, String email, String contact, String nic) throws IllegalArgumentException {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name is required");
        }
        if (email == null || email.trim().isEmpty() || !Validations.isEmailValid(email)) {
            throw new IllegalArgumentException("Valid email is required");
        }
        if (contact == null || contact.trim().isEmpty() || !Validations.isMobileNumberValidSriLankan(contact)) {
            throw new IllegalArgumentException("Valid Sri Lankan mobile number is required (format: 07XXXXXXXX)");
        }
        if (nic == null || nic.trim().isEmpty() || !Validations.isNationalIdentityCardValidSriLankan(nic)) {
            throw new IllegalArgumentException("Valid Sri Lankan National Identity Card Number is Required");
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