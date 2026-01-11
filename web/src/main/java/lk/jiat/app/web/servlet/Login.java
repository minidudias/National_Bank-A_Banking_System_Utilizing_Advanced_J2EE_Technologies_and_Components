package lk.jiat.app.web.servlet;

import jakarta.ejb.EJB;
import jakarta.inject.Inject;
import jakarta.security.enterprise.AuthenticationStatus;
import jakarta.security.enterprise.SecurityContext;
import jakarta.security.enterprise.authentication.mechanism.http.AuthenticationParameters;
import jakarta.security.enterprise.credential.UsernamePasswordCredential;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.jiat.app.core.exception.LoginFailedException;
import lk.jiat.app.core.model.User;
import lk.jiat.app.core.service.UserService;

import java.io.IOException;

@WebServlet("/login")
public class Login extends HttpServlet {

    @Inject
    private SecurityContext securityContext;

    @EJB
    private UserService userService;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            userService.validate(email, password);

            AuthenticationParameters parameters = AuthenticationParameters.withParams()
                    .credential(new UsernamePasswordCredential(email, password));

            AuthenticationStatus status = securityContext.authenticate(
                    request, response, parameters);

            if (status == AuthenticationStatus.SUCCESS) {
                User user = userService.getUserByEmail(email);

                switch(user.getUserType()) {
                    case BANK_OFFICER:
                        response.sendRedirect(request.getContextPath() + "/officer/index.jsp");
                        break;
                    case HR_DEPARTMENT:
                        response.sendRedirect(request.getContextPath() + "/hr_dept/index.jsp");
                        break;
                    case CUSTOMER:
                        response.sendRedirect(request.getContextPath() + "/customer/index.jsp");
                        break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                }
            } else {
                request.setAttribute("error", "Authentication failed");
                request.getRequestDispatcher("/index.jsp").forward(request, response);
            }
        } catch (LoginFailedException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        } catch (Exception e) {
            Throwable cause = e.getCause();
            if (cause instanceof LoginFailedException) {
                request.setAttribute("error", cause.getMessage());
            } else {
                request.setAttribute("error", "An error occurred during login");
            }
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }
}