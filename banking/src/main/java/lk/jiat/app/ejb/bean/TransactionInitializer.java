package lk.jiat.app.ejb.bean;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.model.ScheduledTransaction;
import lk.jiat.app.core.service.TransactionService;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Logger;

@Startup
@Singleton
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
public class TransactionInitializer {
    private static final Logger logger = Logger.getLogger(TransactionInitializer.class.getName());

    @PersistenceContext
    private EntityManager em;

    @EJB
    private TransactionService transactionService;

    @PostConstruct
    @Lock(LockType.WRITE)
    public void init() {
        System.out.println("Running TransactionInitializer");
        logger.info("Initializing pending scheduled transactions...");

        List<ScheduledTransaction> pendingTransactions = em.createNamedQuery(
                        "ScheduledTransaction.findAllPending", ScheduledTransaction.class)
                .getResultList();

        int createdCount = 0;
        int failedCount = 0;

        for (ScheduledTransaction st : pendingTransactions) {
            try {
                if (st.getExecutionTime().isAfter(LocalDateTime.now())) {

                    recreateTimerForTransaction(st);
                    createdCount++;
                    logger.info("Recreated timer for transaction ID: " + st.getId());
                } else {
                    logger.warning("Removing overdue transaction ID: " + st.getId());
                    em.remove(st);
                }
            } catch (Exception e) {
                failedCount++;
                logger.severe("Failed to initialize transaction " + st.getId() + ": " + e.getMessage());
            }
        }

        logger.info("Scheduled transactions initialization completed. " +
                "Created: " + createdCount + ", Failed: " + failedCount +
                " out of " + pendingTransactions.size() + " transactions.");
    }


    private void recreateTimerForTransaction(ScheduledTransaction st) {
        try {
            transactionService.recreateTimerForScheduledTransaction(st);
        } catch (Exception e) {
            logger.severe("Failed to recreate timer for transaction " + st.getId() + ": " + e.getMessage());
            throw e;
        }
    }
}