package lk.jiat.app.ejb.bean;

import jakarta.annotation.security.RolesAllowed;
import jakarta.ejb.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.annotation.Loggable;
import lk.jiat.app.core.annotation.SecureAccess;
import lk.jiat.app.core.model.MonthlyBalanceReport;
import lk.jiat.app.core.service.ReportService;
import java.util.List;

@SecureAccess
@Stateless
@TransactionManagement(TransactionManagementType.CONTAINER)
public class ReportSessionBean implements ReportService {

    @PersistenceContext
    private EntityManager em;

    @RolesAllowed({"CUSTOMER","BANK_OFFICER"})
    @Loggable
    @TransactionAttribute(TransactionAttributeType.SUPPORTS)
    @Override
    public List<MonthlyBalanceReport> getUserMonthlyReports(Long userId) {
        return em.createNamedQuery("MonthlyBalanceReport.findByUser", MonthlyBalanceReport.class)
                .setParameter("userId", userId)
                .getResultList();
    }
}