package com.ebs.auth;

import com.ebs.entity.OtpToken;
import jakarta.ejb.Stateless;
import jakarta.persistence.*;
import java.security.SecureRandom;
import java.time.LocalDateTime;

/**
 * Handles OTP generation, storage and verification for 2FA.
 * Uses SecureRandom (not Math.random) for cryptographically secure tokens.
 */
@Stateless
public class OtpService {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    private static final int OTP_EXPIRY_MINUTES = 10;

    /**
     * Generates a 6-digit OTP, stores it in DB, and returns it.
     * The EmailService will then send it to the user.
     */
    public String generateOtp(String email) {
        // Invalidate any existing OTPs for this email
        em.createQuery("UPDATE OtpToken o SET o.used = true WHERE o.email = :email AND o.used = false")
          .setParameter("email", email)
          .executeUpdate();

        String otp = String.format("%06d", new SecureRandom().nextInt(999999));

        OtpToken token = new OtpToken();
        token.setEmail(email);
        token.setToken(otp);
        token.setExpiresAt(LocalDateTime.now().plusMinutes(OTP_EXPIRY_MINUTES));
        em.persist(token);

        return otp;
    }

    /**
     * Validates OTP - checks it exists, isn't used, and hasn't expired.
     */
    public boolean verifyOtp(String email, String inputOtp) {
        try {
            OtpToken token = em.createQuery(
                "SELECT o FROM OtpToken o WHERE o.email = :email AND o.token = :otp " +
                "AND o.used = false AND o.expiresAt > :now",
                OtpToken.class)
                .setParameter("email", email)
                .setParameter("otp", inputOtp)
                .setParameter("now", LocalDateTime.now())
                .getSingleResult();

            token.setUsed(true); // One-time use
            return true;
        } catch (NoResultException e) {
            return false;
        }
    }
}
