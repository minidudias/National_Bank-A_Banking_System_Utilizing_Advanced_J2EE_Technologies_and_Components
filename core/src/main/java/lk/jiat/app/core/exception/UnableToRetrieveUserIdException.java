package lk.jiat.app.core.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = true)
public class UnableToRetrieveUserIdException extends RuntimeException{
    public UnableToRetrieveUserIdException(String message) {
        super(message);
    }
    public UnableToRetrieveUserIdException(String message, Throwable cause) {
        super(message, cause);
    }
}