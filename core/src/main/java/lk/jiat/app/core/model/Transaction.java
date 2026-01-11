package lk.jiat.app.core.model;

import jakarta.persistence.*;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Cacheable(false)
@Table(name = "transaction")
@NamedQueries({
        @NamedQuery(name = "Transaction.findById",
                query = "SELECT t FROM Transaction t WHERE t.id = :id"),
        @NamedQuery(name = "Transaction.findBySourceAccount",
                query = "SELECT t FROM Transaction t WHERE t.sourceAccount.accountNo = :accountNo"),
        @NamedQuery(name = "Transaction.findByDestinationAccount",
                query = "SELECT t FROM Transaction t WHERE t.destinationAccount.accountNo = :accountNo"),
        @NamedQuery(name = "Transaction.findByType",
                query = "SELECT t FROM Transaction t WHERE t.type = :type"),
        @NamedQuery(name = "Transaction.findByDateRange",
                query = "SELECT t FROM Transaction t WHERE t.transactionDate BETWEEN :start AND :end")
})

public class Transaction implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne
    private Account sourceAccount;
    @ManyToOne
    private Account destinationAccount;
    private double amount = 0.00;
    @Enumerated(EnumType.STRING)
    private TransactionType type = TransactionType.IMMEDIATE;
    private LocalDateTime transactionDate;
    private String reference;

    public Transaction() {}

    public Transaction(Account sourceAccount, Account destinationAccount, double amount, TransactionType type, LocalDateTime transactionDate, String reference) {
        this.sourceAccount = sourceAccount;
        this.destinationAccount = destinationAccount;
        this.amount = amount;
        this.type = type;
        this.transactionDate = transactionDate;
        this.reference = reference;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public TransactionType getType() {
        return type;
    }

    public void setType(TransactionType type) {
        this.type = type;
    }

    public LocalDateTime getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDateTime transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getReference() {
        return reference;
    }

    public void setReference(String reference) {
        this.reference = reference;
    }
}
