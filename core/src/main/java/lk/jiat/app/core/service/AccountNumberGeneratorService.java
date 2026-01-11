package lk.jiat.app.core.service;

import jakarta.ejb.Remote;

@Remote
public interface AccountNumberGeneratorService {
    String generateAccountNumber();
}
