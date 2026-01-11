package lk.jiat.app.core.service;
import jakarta.ejb.Remote;
import lk.jiat.app.core.model.MonthlyBalanceReport;
import java.util.List;

@Remote
public interface ReportService {
    List<MonthlyBalanceReport> getUserMonthlyReports(Long userId);
}