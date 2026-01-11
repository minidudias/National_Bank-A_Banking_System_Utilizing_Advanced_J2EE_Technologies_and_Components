package lk.jiat.app.ejb.bean;
import jakarta.annotation.security.RolesAllowed;
import jakarta.ejb.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.annotation.Loggable;
import lk.jiat.app.core.annotation.SecureAccess;
import lk.jiat.app.core.exception.InsufficientFundsException;
import lk.jiat.app.core.exception.InvalidAccountException;
import lk.jiat.app.core.model.Account;
import lk.jiat.app.core.model.ActiveStatus;
import lk.jiat.app.core.service.AccountService;
import java.util.List;

@SecureAccess
@Stateless
@TransactionManagement(TransactionManagementType.CONTAINER)
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
public class AccountSessionBean implements AccountService{
    @PersistenceContext
    private EntityManager em;

    @Override
    public Account getAccountById(Long id) {
        try {
            return em.createNamedQuery("Account.findById", Account.class).setParameter("id", id).getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    @RolesAllowed({"CUSTOMER","BANK_OFFICER"})
    @Loggable
    @Override
    public boolean isAccountOwnedByUser(String accountNo, Long userId) throws InvalidAccountException {
        try {
            Account account = em.createNamedQuery("Account.findByAccountNo", Account.class)
                    .setParameter("accountNo", accountNo)
                    .getSingleResult();
            return account.getUser().getId().equals(userId);
        } catch (NoResultException e) {
            throw new InvalidAccountException("Account not found: " + accountNo);
        }
    }

    @Loggable
    @Override
    public Account getAccountByAccountNo(String accountNo) {
        try {
            return em.createNamedQuery("Account.findByAccountNo", Account.class)
                    .setParameter("accountNo", accountNo)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    @Loggable
    @Override
    public List<Account> getAllAccounts() {
        return em.createNamedQuery("Account.findAll", Account.class)
                .getResultList();
    }

    @RolesAllowed({"CUSTOMER","BANK_OFFICER"})
    @Loggable
    @Override
    public List<Account> getAccountsByUserId(Long userId) {
        return em.createNamedQuery("Account.findByUserId", Account.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    @RolesAllowed({"BANK_OFFICER"})
    @Loggable
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    @Override
    public void addAccount(Account account) {
        if (account.getCreatedDate() == null) {
            account.setCreatedDate(new java.sql.Date(System.currentTimeMillis()));
        }
        em.persist(account);
    }

    @Override
    public void updateAccount(Account account) {
        em.merge(account);
    }

    @RolesAllowed({"BANK_OFFICER"})
    @Loggable
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    @Override
    public ActiveStatus toggleActiveStatus(String accountNo) {
        Account account = getAccountByAccountNo(accountNo);
        if (account != null) {
            account.setActiveStatus(account.getActiveStatus() == ActiveStatus.ACTIVE
                    ? ActiveStatus.BLOCKED
                    : ActiveStatus.ACTIVE);
            em.merge(account);
            return account.getActiveStatus();
        }
        return null;
    }

    @Override
    @Lock(LockType.WRITE)
    @TransactionAttribute(TransactionAttributeType.MANDATORY)
    public void creditToAccount(String accountNo, double amount)
            throws InvalidAccountException {
        Account account = findAndLockAccount(accountNo);

        if (amount <= 0) {
            throw new IllegalArgumentException("Credit amount must be positive");
        }

        account.setBalance(account.getBalance() + amount);
        em.merge(account);
    }

    @Override
    @Lock(LockType.WRITE)
    @TransactionAttribute(TransactionAttributeType.MANDATORY)
    public void debitFromAccount(String accountNo, double amount)
            throws InvalidAccountException, InsufficientFundsException {
        Account account = findAndLockAccount(accountNo);

        if (amount <= 0) {
            throw new IllegalArgumentException("Debit amount must be positive");
        }

        if (account.getBalance() < amount) {
            throw new InsufficientFundsException("Insufficient funds");
        }

        account.setBalance(account.getBalance() - amount);
        em.merge(account);
    }

    private Account findAndLockAccount(String accountNo) throws InvalidAccountException {
        try {
            return em.createNamedQuery("Account.findByAccountNo", Account.class)
                    .setParameter("accountNo", accountNo)
                    .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                    .getSingleResult();
        } catch (NoResultException e) {
            throw new InvalidAccountException("Account not found: " + accountNo);
        }
    }
}
