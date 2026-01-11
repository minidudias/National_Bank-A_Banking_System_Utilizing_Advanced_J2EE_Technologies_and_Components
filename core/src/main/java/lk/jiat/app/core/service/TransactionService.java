package lk.jiat.app.core.service;

import jakarta.ejb.Remote;
import lk.jiat.app.core.model.ScheduledTransaction;
import lk.jiat.app.core.model.Transaction;
import lk.jiat.app.core.model.TransactionType;

import java.time.LocalDateTime;
import java.util.List;

@Remote
public interface TransactionService {
    List<Transaction> getUserTransactions(Long userId);
    List<ScheduledTransaction> getUserScheduledTransactions(Long userId);
    void transferAmount(String sourceAccountNo, String destinationAccountNo, double amount, String reference, TransactionType transactionType, Long userId);
    void scheduleTransfer(String sourceAccountNo, String destinationAccountNo, double amount, String reference, LocalDateTime scheduleDate, Long userId);
    void cancelScheduledTransaction(Long scheduledId, Long userId);
    void recreateTimerForScheduledTransaction(ScheduledTransaction scheduledTransaction);
}
