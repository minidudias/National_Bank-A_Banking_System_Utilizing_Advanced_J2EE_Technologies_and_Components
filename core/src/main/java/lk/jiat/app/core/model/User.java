package lk.jiat.app.core.model;
import jakarta.persistence.*;
import java.io.Serializable;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@NamedQueries({
        @NamedQuery(name = "User.findByUserType",query = "select u from User u where u.userType=:userType order by u.joinedDate desc "),
        @NamedQuery(name = "User.findByEmail",query = "select u from User u where u.email=:email"),
        @NamedQuery(name = "User.findByEmailAndPassword",query = "select u from User u where u.email=:email and u.password=:password"),
        @NamedQuery(
                name = "User.findAccountHoldableUsers",
                query = "SELECT u FROM User u WHERE u.userType IN (lk.jiat.app.core.model.UserType.CUSTOMER, lk.jiat.app.core.model.UserType.BANK_OFFICER) ORDER BY u.joinedDate DESC"
        )
})

@Cacheable(false)
public class User implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nic;
    private String name;
    private String contact;
    @Column(unique = true)
    private String email;
    private String password;
    private String verificationCode;
    @Temporal(TemporalType.DATE)
    private Date joinedDate;
    @Enumerated(EnumType.STRING)
    private UserType userType = UserType.CUSTOMER;
    @Enumerated(EnumType.STRING)
    private VerifiedStatus verifiedStatus = VerifiedStatus.UNVERIFIED;
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Account> accounts = new ArrayList<>();

    public User() {}

    public User(String name, String email, String contact, String password) {
        this.name = name;
        this.email = email;
        this.contact = contact;
        this.password = password;
    }

    public User(String name, String email, String contact, String password, String verificationCode, String nic) {
        this.name = name;
        this.email = email;
        this.contact = contact;
        this.password = password;
        this.verificationCode = verificationCode;
        this.nic = nic;
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getContact() {
        return contact;
    }
    public void setContact(String contact) {
        this.contact = contact;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public UserType getUserType() {
        return userType;
    }
    public void setUserType(UserType userType) {
        this.userType = userType;
    }
    public String getVerificationCode() {
        return verificationCode;
    }
    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }
    public VerifiedStatus getVerifiedStatus() {
        return verifiedStatus;
    }
    public void setVerifiedStatus(VerifiedStatus verifiedStatus) {
        this.verifiedStatus = verifiedStatus;
    }
    public List<Account> getAccounts() {
        return accounts;
    }
    public void setAccounts(List<Account> accounts) {
        this.accounts = accounts;
    }
    public Date getJoinedDate() {
        return joinedDate;
    }
    public void setJoinedDate(Date joinedDate) {
        this.joinedDate = joinedDate;
    }
    public String getNic() {
        return nic;
    }

    public void setNic(String nic) {
        this.nic = nic;
    }
}
