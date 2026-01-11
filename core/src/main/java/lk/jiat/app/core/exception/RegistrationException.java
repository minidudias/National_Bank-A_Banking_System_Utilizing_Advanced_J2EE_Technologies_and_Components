package lk.jiat.app.core.exception;
import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = true)
public class RegistrationException extends RuntimeException {
    public RegistrationException(String message) {
        super(message);
    }
}