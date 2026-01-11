package lk.jiat.app.ejb.bean;
import jakarta.annotation.security.RolesAllowed;
import jakarta.ejb.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import lk.jiat.app.core.annotation.Loggable;
import lk.jiat.app.core.annotation.SecureAccess;
import lk.jiat.app.core.exception.LoginFailedException;
import lk.jiat.app.core.model.*;
import lk.jiat.app.core.service.UserService;
import java.util.List;

@SecureAccess
@Stateless
@TransactionManagement(TransactionManagementType.CONTAINER)
public class UserSessionBean implements UserService {
    @PersistenceContext
    private EntityManager em;

    @RolesAllowed({"BANK_OFFICER"})
    @Loggable
    @Override
    public User getUserById(Long id) {
        return em.find(User.class, id);
    }

    @Loggable
    @Override
    public User getUserByEmail(String email) {
        try {
            return em.createNamedQuery("User.findByEmail", User.class)
                    .setParameter("email", email)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    @RolesAllowed({"HR_DEPARTMENT"})
    @Loggable
    @Override
    public List<User> getUsersByUserType(UserType userType) {
        return em.createNamedQuery("User.findByUserType", User.class)
                .setParameter("userType", userType)
                .getResultList();
    }

    @RolesAllowed({"BANK_OFFICER"})
    @Loggable
    @Override
    public List<User> getAccountHoldableUsers() {
        return em.createNamedQuery("User.findAccountHoldableUsers", User.class)
                .getResultList();
    }

    @RolesAllowed({"BANK_OFFICER","HR_DEPARTMENT"})
    @Loggable
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    @Override
    public void addUser(User user) {
        em.persist(user);
    }

    @Loggable
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    @Override
    public void updateUser(User user) {
        em.merge(user);
    }

    @Loggable
    @Override
    public boolean validate(String email, String password) {
        try {
            User user = em.createNamedQuery("User.findByEmail", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            if (user.getVerifiedStatus() != VerifiedStatus.VERIFIED) {
                throw new LoginFailedException("Your profile is not verified yet. Check your inbox for the verification email you already received.");
            }

            if (!user.getPassword().equals(password)) {
                throw new LoginFailedException("Invalid email or password");
            }

            return true;
        } catch (NoResultException e) {
            throw new LoginFailedException("No accounts are registered for this email");
        }
    }
}
