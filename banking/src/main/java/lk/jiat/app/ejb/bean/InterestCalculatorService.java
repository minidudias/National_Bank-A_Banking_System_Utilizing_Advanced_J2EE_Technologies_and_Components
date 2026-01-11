package lk.jiat.app.ejb.bean;
import jakarta.ejb.ConcurrencyManagement;
import jakarta.ejb.*;
import jakarta.ejb.ConcurrencyManagementType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.model.Account;
import lk.jiat.app.core.model.MonthlyBalanceReport;
import lk.jiat.app.core.model.Transaction;
import lk.jiat.app.core.model.TransactionType;
import lk.jiat.app.core.service.AccountService;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Logger;

@Singleton
@Startup
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
public class InterestCalculatorService {
    @PersistenceContext
    private EntityManager em;

    @EJB
    private AccountService accountService;

    private static final Logger logger = Logger.getLogger(InterestCalculatorService.class.getName());

    @Schedule(dayOfMonth = "*", hour = "23", minute = "59", persistent = true)
    @Lock(LockType.WRITE)
    @TransactionAttribute(TransactionAttributeType.REQUIRES_NEW)
    public void dailyBalanceUpdate() {
        try {
            logger.info("Starting daily balance update...");
            List<Account> accounts = accountService.getAllAccounts();

            for (Account account : accounts) {
                account.setYesterdayEndOfDayBalance(account.getBalance());

                double dailyInterest = calculateDailyInterest(account);
                account.setThisMonthInterestSoFar(account.getThisMonthInterestSoFar() + dailyInterest);

                em.merge(account);
            }
            logger.info("Daily balance update completed successfully.");
        } catch (Exception e) {
            logger.severe("Daily balance update failed: " + e.getMessage());
            throw new EJBException("Rollback due to error", e);
        }
    }

    @Schedule(dayOfMonth = "Last", hour = "23", minute = "59", second = "59", persistent = true)
    @Lock(LockType.WRITE)
    @TransactionAttribute(TransactionAttributeType.REQUIRES_NEW)
    public void monthlyInterestUpdate() {
        LocalDate reportDate = LocalDate.now();
        try {
            logger.info("Starting monthly interest update...");
            List<Account> accounts = accountService.getAllAccounts();

            for (Account account : accounts) {
                double interest = account.getThisMonthInterestSoFar();
                double balanceWithInterest = account.getBalance() + interest;
                account.setBalance(balanceWithInterest);

                Transaction interestTx = new Transaction();
                interestTx.setAmount(interest);
                interestTx.setType(TransactionType.INTEREST);
                interestTx.setTransactionDate(LocalDateTime.now());
                interestTx.setReference("Monthly Interest Credit");
                interestTx.setDestinationAccount(account);
                em.persist(interestTx);

                account.setThisMonthInterestSoFar(0.0);
                em.merge(account);

                MonthlyBalanceReport monthlyBalanceReport = new MonthlyBalanceReport();
                monthlyBalanceReport.setWhichAccount(account);
                monthlyBalanceReport.setEndOfMonthBalance(balanceWithInterest);
                monthlyBalanceReport.setInterestCredited(interest);
                monthlyBalanceReport.setRecordedDate(reportDate);
                em.persist(monthlyBalanceReport);
            }
            logger.info("Monthly interest update completed successfully.");
        } catch (Exception e) {
            logger.severe("Monthly interest update failed: " + e.getMessage());
            throw new EJBException("Rollback due to error", e);
        }
    }

    private double calculateDailyInterest(Account account) {
        double annualInterestRate = 0.10;
        return (account.getBalance() * annualInterestRate) / 365;
    }
}