package lk.jiat.app.core.regex;

public class Validations {
    public static boolean isEmailValid(String email) {
        return email.matches("^[a-zA-Z0-9_!#$%&’*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+$");
    }
    public static boolean isPasswordValid(String password) {
        return password.matches("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,30}$");
    }
    public static boolean isDouble(String insertedText) {
        return insertedText.matches("^\\d+(\\.\\d{2})?$");
    }
    public static boolean isValidAccountNo(String insertedText) {
        return insertedText.matches("^[1-9][0-9]{9}$");
    }
    public static boolean isMobileNumberValidSriLankan(String insertedText) {
        return insertedText.matches("^07[01245678]{1}[0-9]{7}$");
    }
    public static boolean isNationalIdentityCardValidSriLankan(String insertedText) {
        return insertedText.matches("^(([5-9][0-9][0-35-8][0-9]{6}[vVxX])|([12][09][0-9]{2}[0-35-8][0-9]{7}))$");
    }
    public static boolean isValidVerificationCode(String insertedText) {
        return insertedText.matches("^[A-Z0-9]{8}$");
    }
}
