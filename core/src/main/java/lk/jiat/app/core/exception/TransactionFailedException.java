package lk.jiat.app.core.exception;

import jakarta.ejb.ApplicationException;

@ApplicationException(rollback = true)
public class TransactionFailedException extends BankingException {
    public TransactionFailedException(String message) {
        super(message);
    }
    public TransactionFailedException(String message, Throwable cause) {
        super(message, cause);
    }
}