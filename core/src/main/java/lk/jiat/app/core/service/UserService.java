package lk.jiat.app.core.service;

import jakarta.ejb.Remote;
import lk.jiat.app.core.model.User;
import lk.jiat.app.core.model.UserType;

import java.util.List;

@Remote
public interface UserService {
    User getUserById(Long id);
    User getUserByEmail(String email);
    List<User> getUsersByUserType(UserType userType);
    void addUser(User user);
    void updateUser(User user);
    boolean validate(String email, String password);
    List<User> getAccountHoldableUsers();
}
