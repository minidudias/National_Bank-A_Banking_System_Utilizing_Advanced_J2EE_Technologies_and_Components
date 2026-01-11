package lk.jiat.app.core.model;
import jakarta.persistence.*;

@Entity
@Cacheable(false)
@Table(name = "account_number_sequence")
public class AccountNumberSequence {

    @Id
    private String name = "ACCOUNT_SEQ";
    @Version
    private Long version;
    private Long nextValue = 1000000001L;

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public Long getVersion() {
        return version;
    }
    public void setVersion(Long version) {
        this.version = version;
    }
    public Long getNextValue() {
        return nextValue;
    }
    public void setNextValue(Long nextValue) {
        this.nextValue = nextValue;
    }
}