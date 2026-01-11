package lk.jiat.app.core.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = true)
public class BankingException extends RuntimeException{
    public BankingException(String message) {
        super(message);
    }
    public BankingException(String message, Throwable cause) {
        super(message, cause);
    }
}