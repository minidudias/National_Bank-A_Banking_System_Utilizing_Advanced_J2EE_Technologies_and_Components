package lk.jiat.app.ejb.bean;
import jakarta.annotation.Resource;
import jakarta.ejb.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.model.ScheduledTransaction;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Singleton
@Startup
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
public class TimerCleanupService {

    private static final Logger logger = Logger.getLogger(TimerCleanupService.class.getName());

    @PersistenceContext
    private EntityManager em;

    @Resource
    private SessionContext sessionContext;

    private TimerService getTimerService() {
        return sessionContext.getTimerService();
    }

    @Schedule(hour = "*", minute = "*/10", persistent = false)
    @Lock(LockType.WRITE)
    public void cleanupOrphanedTimers() {
        try {
            logger.info("Starting timer cleanup process...");

            cleanupOverdueTransactions();

            cleanupStaleTimers();

            logger.info("Timer cleanup process completed");

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error during timer cleanup process", e);
        }
    }

    private void cleanupOverdueTransactions() {
        try {
            LocalDateTime cutoffTime = LocalDateTime.now().minusMinutes(30);

            List<ScheduledTransaction> overdueTransactions = em
                    .createNamedQuery("ScheduledTransaction.findOverdue", ScheduledTransaction.class)
                    .setParameter("cutoffTime", cutoffTime)
                    .getResultList();

            int removedCount = 0;
            for (ScheduledTransaction st : overdueTransactions) {
                try {
                    cancelTimerByScheduledId(st.getId());
                    em.remove(st);
                    removedCount++;

                } catch (Exception e) {
                    logger.log(Level.WARNING,
                            "Failed to clean up overdue transaction " + st.getId(), e);
                }
            }

            if (removedCount > 0) {
                logger.info("Cleaned up " + removedCount + " overdue transactions");
            }

        } catch (Exception e) {
            logger.log(Level.WARNING, "Error cleaning up overdue transactions", e);
        }
    }

    private void cleanupStaleTimers() {
        try {
            List<Long> activeScheduledIds = em.createQuery(
                            "SELECT st.id FROM ScheduledTransaction st WHERE st.executionTime > :now",
                            Long.class)
                    .setParameter("now", LocalDateTime.now())
                    .getResultList();

            Set<Long> activeIdSet = activeScheduledIds.stream().collect(Collectors.toSet());

            Collection<Timer> allTimers = getTimerService().getTimers();
            int cancelledCount = 0;

            for (Timer timer : allTimers) {
                try {
                    Object timerInfo = timer.getInfo();
                    if (timerInfo instanceof Long) {
                        Long scheduledId = (Long) timerInfo;
                        if (!activeIdSet.contains(scheduledId)) {
                            timer.cancel();
                            cancelledCount++;
                            logger.info("Cancelled orphaned timer for non-existent scheduled transaction: " + scheduledId);
                        }
                    }
                } catch (Exception e) {
                    logger.log(Level.WARNING, "Error checking timer: " + e.getMessage());
                }
            }

            if (cancelledCount > 0) {
                logger.info("Cancelled " + cancelledCount + " orphaned timers");
            }

        } catch (Exception e) {
            logger.log(Level.WARNING, "Error cleaning up orphaned timers", e);
        }
    }


    private boolean cancelTimerByScheduledId(Long scheduledId) {
        try {
            Collection<Timer> timers = getTimerService().getTimers();
            for (Timer timer : timers) {
                Object info = timer.getInfo();
                if (Objects.equals(info, scheduledId)) {
                    timer.cancel();
                    return true;
                }
            }
        } catch (Exception e) {
            logger.log(Level.WARNING, "Error cancelling timer for scheduled ID " + scheduledId, e);
        }
        return false;
    }
}