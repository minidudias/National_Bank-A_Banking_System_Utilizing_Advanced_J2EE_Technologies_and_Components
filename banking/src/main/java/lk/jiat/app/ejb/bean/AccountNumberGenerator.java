package lk.jiat.app.ejb.bean;

import jakarta.ejb.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.model.AccountNumberSequence;
import lk.jiat.app.core.service.AccountNumberGeneratorService;

@Singleton
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
@Remote(AccountNumberGeneratorService.class)
public class AccountNumberGenerator implements AccountNumberGeneratorService {

    @PersistenceContext
    private EntityManager em;

    @Override
    @Lock(LockType.WRITE)
    public String generateAccountNumber() {
        AccountNumberSequence seq = getOrCreateSequence();
        long nextValue = seq.getNextValue();

        validateSequenceValue(nextValue);

        String accountNumber = formatAccountNumber(nextValue);
        updateSequence(seq);

        return accountNumber;
    }

    private AccountNumberSequence getOrCreateSequence() {
        AccountNumberSequence seq = em.find(AccountNumberSequence.class, "ACCOUNT_SEQ");
        if (seq == null) {
            seq = new AccountNumberSequence();
            em.persist(seq);
            em.flush();
        }
        return seq;
    }

    private void validateSequenceValue(long value) {
        if (value < 1000000001L) {
            throw new IllegalStateException("Account sequence below minimum: " + value);
        }
        if (value > 9999999999L) {
            throw new IllegalStateException("Account sequence exhausted. Maximum value (9999999999) reached.");
        }
    }

    private String formatAccountNumber(long value) {
        return String.valueOf(value);
    }

    private void updateSequence(AccountNumberSequence seq) {
        seq.setNextValue(seq.getNextValue() + 1);
        em.merge(seq);
        em.flush();
    }
}