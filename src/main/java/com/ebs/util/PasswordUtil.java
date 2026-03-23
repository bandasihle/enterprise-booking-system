package com.ebs.util;


import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Password hashing utility.
 * NOTE: In production, use a proper BCrypt library.
 * This is a SHA-256 + salt implementation for the project scope.
 */
public class PasswordUtil {

    public static String hashPassword(String password) {
        try {
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);

            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes());

            return Base64.getEncoder().encodeToString(salt) + ":" +
                   Base64.getEncoder().encodeToString(hashedPassword);
        } catch (Exception e) {
            throw new RuntimeException("Password hashing failed", e);
        }
    }

    public static boolean verifyPassword(String inputPassword, String storedHash) {
        try {
            String[] parts = storedHash.split(":");
            byte[] salt = Base64.getDecoder().decode(parts[0]);

            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] hashedInput = md.digest(inputPassword.getBytes());

            return parts[1].equals(Base64.getEncoder().encodeToString(hashedInput));
        } catch (Exception e) {
            return false;
        }
    }
}
