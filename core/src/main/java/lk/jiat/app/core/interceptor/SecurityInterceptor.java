package lk.jiat.app.core.interceptor;

import jakarta.annotation.Priority;
import jakarta.annotation.security.RolesAllowed;
import jakarta.ejb.EJBAccessException;
import jakarta.inject.Inject;
import jakarta.interceptor.AroundInvoke;
import jakarta.interceptor.Interceptor;
import jakarta.interceptor.InvocationContext;
import jakarta.security.enterprise.SecurityContext;
import lk.jiat.app.core.annotation.SecureAccess;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.logging.Logger;

@Interceptor
@SecureAccess
@Priority(Interceptor.Priority.APPLICATION + 200)
public class SecurityInterceptor {

    @Inject
    private SecurityContext securityContext;

    private static final Logger logger = Logger.getLogger(SecurityInterceptor.class.getName());

    @AroundInvoke
    public Object checkSecurity(InvocationContext context) throws Exception {
        Method method = context.getMethod();
        String target = context.getTarget().getClass().getSimpleName();

        if (method.isAnnotationPresent(RolesAllowed.class)) {
            RolesAllowed rolesAllowed = method.getAnnotation(RolesAllowed.class);
            String caller = securityContext.getCallerPrincipal() != null ?
                    securityContext.getCallerPrincipal().getName() : "anonymous";

            if (Arrays.stream(rolesAllowed.value())
                    .noneMatch(securityContext::isCallerInRole)) {

                logger.warning(String.format(
                        "SECURITY DENIED: %s tried accessing %s.%s (Required: %s)",
                        caller, target, method.getName(),
                        String.join(", ", rolesAllowed.value())
                ));

                throw new EJBAccessException(
                        String.format("Access denied to %s.%s. Required roles: %s",
                                target, method.getName(), String.join(", ", rolesAllowed.value()))
                );
            }

            logger.info(String.format(
                    "SECURITY GRANTED: %s accessed %s.%s",
                    caller, target, method.getName()
            ));
        }
        return context.proceed();
    }
}