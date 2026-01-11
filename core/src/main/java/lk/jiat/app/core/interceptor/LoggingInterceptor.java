package lk.jiat.app.core.interceptor;

import jakarta.annotation.Priority;
import jakarta.interceptor.AroundInvoke;
import jakarta.interceptor.Interceptor;
import jakarta.interceptor.InvocationContext;
import lk.jiat.app.core.annotation.Loggable;

import java.io.Serializable;
import java.util.logging.Logger;

@Interceptor
@Loggable
@Priority(Interceptor.Priority.APPLICATION + 199)
public class LoggingInterceptor implements Serializable {

    private static final Logger logger = Logger.getLogger(LoggingInterceptor.class.getName());

    @AroundInvoke
    public Object logMethodEntry(InvocationContext context) throws Exception {
        String className = context.getTarget().getClass().getName();
        String methodName = context.getMethod().getName();

        logger.info(() -> "Entering method: " + className + "." + methodName);

        if (context.getParameters() != null && context.getParameters().length > 0) {
            StringBuilder params = new StringBuilder("Parameters: ");
            for (Object param : context.getParameters()) {
                params.append(param).append(", ");
            }
            logger.info(params.toString());
        }

        long startTime = System.currentTimeMillis();

        try {
            Object result = context.proceed();

            long duration = System.currentTimeMillis() - startTime;
            logger.info(() -> "Exiting method: " + className + "." + methodName +
                    " | Execution time: " + duration + "ms");

            return result;
        } catch (Exception e) {
            logger.severe(() -> "Exception in method: " + className + "." + methodName +
                    " | Exception: " + e.getMessage());
            throw e;
        }
    }
}