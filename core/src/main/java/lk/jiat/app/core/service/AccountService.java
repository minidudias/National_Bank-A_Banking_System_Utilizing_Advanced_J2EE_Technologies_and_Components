package lk.jiat.app.core.service;

import jakarta.ejb.Remote;
import lk.jiat.app.core.exception.InvalidAccountException;
import lk.jiat.app.core.model.Account;
import lk.jiat.app.core.model.ActiveStatus;

import java.util.List;

@Remote
public interface AccountService {
    Account getAccountById(Long id);
    Account getAccountByAccountNo(String accountNo);
    List<Account> getAllAccounts();
    List<Account> getAccountsByUserId(Long userId);
    void addAccount(Account account);
    void updateAccount(Account account);
    ActiveStatus toggleActiveStatus(String accountNo);
    void creditToAccount(String accountNo, double amount);
    void debitFromAccount(String accountNo, double amount);
    boolean isAccountOwnedByUser(String accountNo, Long userId) throws InvalidAccountException;
}
