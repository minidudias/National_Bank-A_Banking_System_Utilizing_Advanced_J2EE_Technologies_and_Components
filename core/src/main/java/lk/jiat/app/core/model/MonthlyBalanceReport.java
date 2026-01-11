package lk.jiat.app.core.model;
import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDate;

@Entity
@Cacheable(false)
@Table(name = "monthly_balance_report")
@NamedQueries({
        @NamedQuery(name = "MonthlyBalanceReport.findByUser",
                query = "SELECT r FROM MonthlyBalanceReport r WHERE r.whichAccount.user.id = :userId ORDER BY r.recordedDate DESC")
})
public class MonthlyBalanceReport implements Serializable{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne
    private Account whichAccount;
    private LocalDate recordedDate;
    private double endOfMonthBalance = 0.00;
    private double interestCredited = 0.00;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Account getWhichAccount() {
        return whichAccount;
    }

    public void setWhichAccount(Account whichAccount) {
        this.whichAccount = whichAccount;
    }

    public LocalDate getRecordedDate() {
        return recordedDate;
    }

    public void setRecordedDate(LocalDate recordedDate) {
        this.recordedDate = recordedDate;
    }

    public double getEndOfMonthBalance() {
        return endOfMonthBalance;
    }

    public void setEndOfMonthBalance(double endOfMonthBalance) {
        this.endOfMonthBalance = endOfMonthBalance;
    }

    public double getInterestCredited() {
        return interestCredited;
    }

    public void setInterestCredited(double interestCredited) {
        this.interestCredited = interestCredited;
    }

    public MonthlyBalanceReport(Account whichAccount, LocalDate recordedDate, double endOfMonthBalance, double interestCredited) {
        this.whichAccount = whichAccount;
        this.recordedDate = recordedDate;
        this.endOfMonthBalance = endOfMonthBalance;
        this.interestCredited = interestCredited;
    }

    public MonthlyBalanceReport() {}
}
