package lk.jiat.app.core.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "scheduled_transactions")
@NamedQueries({
        @NamedQuery(name = "ScheduledTransaction.findByAccount",
                query = "SELECT st FROM ScheduledTransaction st WHERE st.sourceAccount.accountNo = :accountNo"),
        @NamedQuery(name = "ScheduledTransaction.findAllPending",
                query = "SELECT st FROM ScheduledTransaction st WHERE st.executionTime > CURRENT_TIMESTAMP"),
        @NamedQuery(
                name = "ScheduledTransaction.findOverdue",
                query = "SELECT st FROM ScheduledTransaction st WHERE st.executionTime < :cutoffTime"
        )
})
public class ScheduledTransaction implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Account sourceAccount;
    @ManyToOne
    private Account destinationAccount;
    private double amount = 0.00;
    private String reference;
    @Column(nullable = false)
    private LocalDateTime executionTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
    public LocalDateTime getExecutionTime() {
        return executionTime;
    }
    public void setExecutionTime(LocalDateTime executionTime) {
        this.executionTime = executionTime;
    }

    public Account getSourceAccount() {
        return sourceAccount;
    }

    public void setSourceAccount(Account sourceAccount) {
        this.sourceAccount = sourceAccount;
    }

    public Account getDestinationAccount() {
        return destinationAccount;
    }

    public void setDestinationAccount(Account destinationAccount) {
        this.destinationAccount = destinationAccount;
    }
}