package lk.jiat.app.core.model;

import jakarta.persistence.*;

import java.io.Serializable;
import java.sql.Date;

@Entity
@Cacheable(false)
@Table(name = "account")
@NamedQueries({
        @NamedQuery(name = "Account.findById",
                query = "SELECT a FROM Account a WHERE a.id = :id"),
        @NamedQuery(name = "Account.findByAccountNo",
                query = "SELECT a FROM Account a WHERE a.accountNo = :accountNo"),
        @NamedQuery(name = "Account.findByUserId",
                query = "SELECT a FROM Account a WHERE a.user.id = :userId ORDER BY a.id DESC"),
        @NamedQuery(name = "Account.findAll",
                query = "SELECT a FROM Account a")
})

public class Account implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(unique = true, nullable = false)
    private String accountNo;
    private double balance = 0.00;
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @Enumerated(EnumType.STRING)
    private ActiveStatus activeStatus = ActiveStatus.ACTIVE;
    @Temporal(TemporalType.DATE)
    private Date createdDate;
    private double yesterdayEndOfDayBalance = 0.00;
    private double thisMonthInterestSoFar = 0.00;

    public Account() {}

    public Account(String accountNo, ActiveStatus activeStatus, User user, double balance) {
        this.accountNo = accountNo;
        this.activeStatus = activeStatus;
        this.user = user;
        this.balance = balance;
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getAccountNo() {
        return accountNo;
    }
    public void setAccountNo(String accountNo) {
        this.accountNo = accountNo;
    }
    public double getBalance() {
        return balance;
    }
    public void setBalance(double balance) {
        this.balance = balance;
    }
    public User getUser() {
        return user;
    }
    public void setUser(User user) {
        this.user = user;
    }
    public ActiveStatus getActiveStatus() {
        return activeStatus;
    }
    public void setActiveStatus(ActiveStatus activeStatus) {
        this.activeStatus = activeStatus;
    }
    public Date getCreatedDate() {
        return createdDate;
    }
    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public double getYesterdayEndOfDayBalance() {
        return yesterdayEndOfDayBalance;
    }

    public void setYesterdayEndOfDayBalance(double yesterdayEndOfDayBalance) {
        this.yesterdayEndOfDayBalance = yesterdayEndOfDayBalance;
    }

    public double getThisMonthInterestSoFar() {
        return thisMonthInterestSoFar;
    }

    public void setThisMonthInterestSoFar(double thisMonthInterestSoFar) {
        this.thisMonthInterestSoFar = thisMonthInterestSoFar;
    }
}
