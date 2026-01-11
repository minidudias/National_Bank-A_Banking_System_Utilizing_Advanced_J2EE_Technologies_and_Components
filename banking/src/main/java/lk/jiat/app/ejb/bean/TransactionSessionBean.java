package lk.jiat.app.ejb.bean;
import jakarta.annotation.Resource;
import jakarta.annotation.security.RolesAllowed;
import jakarta.ejb.*;
import jakarta.ejb.Timer;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.annotation.Loggable;
import lk.jiat.app.core.annotation.SecureAccess;
import lk.jiat.app.core.exception.BankingException;
import lk.jiat.app.core.exception.InsufficientFundsException;
import lk.jiat.app.core.exception.InvalidAccountException;
import lk.jiat.app.core.exception.TransactionFailedException;
import lk.jiat.app.core.model.Account;
import lk.jiat.app.core.model.ScheduledTransaction;
import lk.jiat.app.core.model.Transaction;
import lk.jiat.app.core.model.TransactionType;
import lk.jiat.app.core.service.AccountService;
import lk.jiat.app.core.service.TransactionService;
import lk.jiat.app.core.model.ActiveStatus;

import java.util.*;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.stream.Collectors;

@SecureAccess
@Stateless
@TransactionManagement(TransactionManagementType.CONTAINER)
public class TransactionSessionBean implements TransactionService {

    @PersistenceContext
    private EntityManager em;

    @Resource
    private SessionContext sessionContext;

    private TimerService getTimerService() {
        return sessionContext.getTimerService();
    }

    @EJB
    private AccountService accountService;

    @Loggable
    @Override
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public void transferAmount(String sourceAccountNo, String destinationAccountNo, double amount, String reference, TransactionType transactionType, Long userId) throws BankingException {

        validateTransfer(sourceAccountNo, destinationAccountNo, amount);
        validateAccountsForTransfer(sourceAccountNo, destinationAccountNo, userId);


        Account sourceAccount = accountService.getAccountByAccountNo(sourceAccountNo);
        Account destinationAccount = accountService.getAccountByAccountNo(destinationAccountNo);



        Transaction transaction = null;
        try {
            transaction = createTransactionRecord(sourceAccount, destinationAccount, amount, reference);

            processTransfer(sourceAccountNo, destinationAccountNo, amount);

            transaction.setType(transactionType);
            transaction.setTransactionDate(LocalDateTime.now());
            em.persist(transaction);

        } catch (Exception e) {
            if (transaction != null) {
                transaction.setType(TransactionType.FAILED);
                transaction.setTransactionDate(LocalDateTime.now());
                em.persist(transaction);
            }
            throw e;
        }
    }

    private Transaction createTransactionRecord(Account sourceAccount, Account destinationAccount,double amount, String reference) {
        Transaction transaction = new Transaction();
        transaction.setAmount(amount);
        transaction.setReference(reference);
        transaction.setType(TransactionType.IMMEDIATE);
        transaction.setTransactionDate(LocalDateTime.now());
        transaction.setSourceAccount(sourceAccount);
        transaction.setDestinationAccount(destinationAccount);
        return transaction;
    }

    private void validateTransfer(String sourceAccountNo, String destinationAccountNo, double amount) throws IllegalArgumentException {
        if (amount <= 0) {
            throw new IllegalArgumentException("Transfer amount must be positive");
        }
        if (sourceAccountNo.equals(destinationAccountNo)) {
            throw new IllegalArgumentException("Cannot transfer to the same account");
        }
    }
    private void validateAccountsForTransfer(String sourceAccountNo, String destinationAccountNo, Long userId) throws InvalidAccountException {
        Account sourceAccount = accountService.getAccountByAccountNo(sourceAccountNo);
        Account destinationAccount = accountService.getAccountByAccountNo(destinationAccountNo);
        if (sourceAccount == null) {
            throw new InvalidAccountException("Source account not found: " + sourceAccountNo);
        }
        if (!sourceAccount.getUser().getId().equals(userId)) {
            throw new SecurityException("Account not owned by user");
        }
        if (destinationAccount == null) {
            throw new InvalidAccountException("Destination account not found: " + destinationAccountNo);
        }
        if (sourceAccount.getActiveStatus() != ActiveStatus.ACTIVE) {
            throw new InvalidAccountException("Source account is not active");
        }
        if (destinationAccount.getActiveStatus() != ActiveStatus.ACTIVE) {
            throw new InvalidAccountException("Destination account is not active");
        }
    }

    private void processTransfer(String sourceAccountNo, String destinationAccountNo, double amount) throws BankingException {
        try {
            accountService.debitFromAccount(sourceAccountNo, amount);

            accountService.creditToAccount(destinationAccountNo, amount);

        } catch (InsufficientFundsException | InvalidAccountException e) {
            throw e;
        } catch (Exception e) {
            throw new TransactionFailedException("Transfer processing failed", e);
        }
    }

    @RolesAllowed({"CUSTOMER","BANK_OFFICER"})
    @Loggable
    @Override
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public void scheduleTransfer(String sourceAccountNo, String destinationAccountNo, double amount, String reference, LocalDateTime scheduleDate, Long userId) throws BankingException {

        validateAccountsForTransfer(sourceAccountNo, destinationAccountNo, userId);

        validateTransfer(sourceAccountNo, destinationAccountNo, amount);
        Account sourceAccount = accountService.getAccountByAccountNo(sourceAccountNo);
        Account destinationAccount = accountService.getAccountByAccountNo(destinationAccountNo);

        ScheduledTransaction st = new ScheduledTransaction();
        st.setSourceAccount(sourceAccount);
        st.setDestinationAccount(destinationAccount);
        st.setAmount(amount);
        st.setReference(reference);
        st.setExecutionTime(scheduleDate);
        em.persist(st);

        TimerConfig config = new TimerConfig();
        config.setInfo(st.getId());
        config.setPersistent(true);

        Date timerDate = Date.from(scheduleDate.atZone(ZoneId.systemDefault()).toInstant());

        try {
            getTimerService().createSingleActionTimer(timerDate, config);
        } catch (Exception e) {
            em.remove(st);
            throw new TransactionFailedException("Failed to schedule transfer", e);
        }
    }

    @Timeout
    @TransactionAttribute(TransactionAttributeType.REQUIRES_NEW)
    public void executeScheduledTransfer(Timer timer) {
        Long scheduledId = (Long) timer.getInfo();
        ScheduledTransaction st = em.find(ScheduledTransaction.class, scheduledId);

        if (st == null) return;

        try {
            transferAmount(st.getSourceAccount().getAccountNo(), st.getDestinationAccount().getAccountNo(), st.getAmount(), st.getReference(),TransactionType.SCHEDULED,st.getDestinationAccount().getUser().getId());

            em.remove(st);

        } catch (Exception e) {
            recordFailedTransaction(st, "Failed during execution: " + e.getMessage());
            em.remove(st);
        }
    }

    private void recordFailedTransaction(ScheduledTransaction st, String failureReason) {
        Transaction tx = new Transaction();
        tx.setSourceAccount(st.getSourceAccount());
        tx.setDestinationAccount(st.getDestinationAccount());
        tx.setAmount(st.getAmount());
        tx.setReference(st.getReference() + " [" + failureReason + "]");
        tx.setType(TransactionType.FAILED);
        tx.setTransactionDate(LocalDateTime.now());
        em.persist(tx);
    }

    @RolesAllowed({"CUSTOMER","BANK_OFFICER"})
    @Loggable
    @Override
    public List<ScheduledTransaction> getUserScheduledTransactions(Long userId) {
        List<Account> userAccounts = accountService.getAccountsByUserId(userId);

        List<ScheduledTransaction> results = new ArrayList<>();
        for (Account account : userAccounts) {
            results.addAll(
                    em.createNamedQuery("ScheduledTransaction.findByAccount", ScheduledTransaction.class)
                            .setParameter("accountNo", account.getAccountNo())
                            .getResultList()
            );
        }
        return results;
    }

    @RolesAllowed({"CUSTOMER","BANK_OFFICER"})
    @Loggable
    @Override
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public void cancelScheduledTransaction(Long scheduledId, Long userId)
            throws BankingException {

        if (scheduledId == null) {
            throw new IllegalArgumentException("Scheduled transaction ID cannot be null");
        }
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        ScheduledTransaction st = em.find(ScheduledTransaction.class, scheduledId);
        if (st == null) {
            throw new TransactionFailedException("Scheduled transaction not found");
        }

        if (st.getSourceAccount().getActiveStatus() != ActiveStatus.ACTIVE) {
            throw new InvalidAccountException("Source account is not active");
        }
        if (!st.getSourceAccount().getUser().getId().equals(userId)) {
            throw new SecurityException("Account not owned by user");
        }

        String timerCancellationError = null;

        try {
            Timer targetTimer = findTimerByScheduledId(scheduledId);
            if (targetTimer != null) {
                targetTimer.cancel();
            } else {
                timerCancellationError = "Timer not found for scheduled transaction ID: " + scheduledId;
            }
        } catch (Exception e) {
            timerCancellationError = "Timer cancellation failed: " + e.getMessage();
            System.err.println("Warning: " + timerCancellationError);
        }

        try {
            em.remove(st);
            em.flush();
        } catch (Exception e) {
            throw new TransactionFailedException("Failed to remove scheduled transaction", e);
        }

        try {
            Account sourceAccount = st.getSourceAccount();
            Account destinationAccount = st.getDestinationAccount();

            if (sourceAccount == null) {
                throw new InvalidAccountException("Source account not found");
            }
            if (destinationAccount == null) {
                throw new InvalidAccountException("Destination account not found");
            }

            Transaction tx = new Transaction();
            tx.setSourceAccount(sourceAccount);
            tx.setDestinationAccount(destinationAccount);
            tx.setAmount(st.getAmount());

            String reference = "CANCELLED: " + st.getReference();
            if (timerCancellationError != null) {
                reference += " (Timer warning: " + timerCancellationError + ")";
            }
            tx.setReference(reference);

            tx.setType(TransactionType.CANCELLED);
            tx.setTransactionDate(LocalDateTime.now());

            em.persist(tx);
            em.flush();

        } catch (InvalidAccountException e) {
            throw e;
        } catch (Exception e) {
            throw new TransactionFailedException("Failed to record cancellation", e);
        }
    }
    private Timer findTimerByScheduledId(Long scheduledId) {
        try {
            Collection<Timer> timers = getTimerService().getTimers();
            for (Timer timer : timers) {
                Object info = timer.getInfo();
                if (info instanceof Long && scheduledId.equals(info)) {
                    return timer;
                }
            }
        } catch (Exception e) {
            System.err.println("Error searching for timer: " + e.getMessage());
        }
        return null;
    }

    @Override
    public void recreateTimerForScheduledTransaction(ScheduledTransaction st) {
        try {
            cancelExistingTimer(st.getId());

            TimerConfig config = new TimerConfig();
            config.setInfo(st.getId());
            config.setPersistent(true);

            Date timerDate = Date.from(st.getExecutionTime().atZone(ZoneId.systemDefault()).toInstant());
            getTimerService().createSingleActionTimer(timerDate, config);

            System.out.println("Successfully created timer for scheduled transaction " + st.getId() +
                    " to execute at " + st.getExecutionTime());

        } catch (Exception e) {
            System.err.println("Failed to recreate timer for scheduled transaction " + st.getId() + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to recreate timer for scheduled transaction " + st.getId(), e);
        }
    }

    private void cancelExistingTimer(Long scheduledId) {
        try {
            Collection<Timer> timers = getTimerService().getTimers();
            for (Timer timer : timers) {
                Object info = timer.getInfo();
                if (info instanceof Long && scheduledId.equals(info)) {
                    timer.cancel();
                    System.out.println("Cancelled existing timer for scheduled transaction " + scheduledId);
                    break;
                }
            }
        } catch (Exception e) {
            System.err.println("Warning: Could not cancel existing timer for scheduled ID " + scheduledId + ": " + e.getMessage());
        }
    }

    @RolesAllowed({"CUSTOMER","BANK_OFFICER"})
    @Loggable
    @Override
    public List<Transaction> getUserTransactions(Long userId) {
        List<Account> userAccounts = accountService.getAccountsByUserId(userId);
        Set<Transaction> uniqueTransactions = new HashSet<>();

        for (Account account : userAccounts) {
            uniqueTransactions.addAll(
                    em.createNamedQuery("Transaction.findBySourceAccount", Transaction.class)
                            .setParameter("accountNo", account.getAccountNo())
                            .getResultList()
            );
            uniqueTransactions.addAll(
                    em.createNamedQuery("Transaction.findByDestinationAccount", Transaction.class)
                            .setParameter("accountNo", account.getAccountNo())
                            .getResultList()
            );
        }

        return uniqueTransactions.stream()
                .sorted((t1, t2) -> t2.getTransactionDate().compareTo(t1.getTransactionDate()))
                .collect(Collectors.toList());
    }
}
