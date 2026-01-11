package lk.jiat.app.core.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = true)
public class InvalidAccountException extends BankingException {
    public InvalidAccountException(String message) {
        super(message);
    }
}