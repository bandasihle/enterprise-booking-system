package com.ebs.service;

import com.ebs.entity.Lecturer;
import com.ebs.entity.OtpToken;
import com.ebs.entity.Student;
import com.ebs.entity.User;
import com.ebs.rest.AuthResource.RegisterRequest;
import com.ebs.util.EmailService;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

import java.time.LocalDateTime;
import java.util.Random;

@RequestScoped
public class AuthService {

    @Inject
    private EmailService emailService;

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Transactional
    public void initRegistration(String email, String studentNo) throws Exception {
        long emailCount = em.createQuery(
                "SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                .setParameter("email", email)
                .getSingleResult();

        if (emailCount > 0) {
            throw new Exception("Email already registered.");
        }

        long studentCount = em.createQuery(
                "SELECT COUNT(s) FROM Student s WHERE s.studentNumber = :studentNo", Long.class)
                .setParameter("studentNo", studentNo)
                .getSingleResult();

        if (studentCount > 0) {
            throw new Exception("Student number already registered.");
        }

        generateAndSendOtp(email);
    }

    @Transactional
    public void verifyOtpAndRegister(RegisterRequest request) throws Exception {
        try {
            OtpToken otpToken = em.createQuery(
                    "SELECT o FROM OtpToken o WHERE o.email = :email AND o.token = :token AND o.used = false AND o.expiresAt > :now",
                    OtpToken.class)
                    .setParameter("email", request.email())
                    .setParameter("token", request.otpCode())
                    .setParameter("now", LocalDateTime.now())
                    .getSingleResult();

            otpToken.setUsed(true);
            em.merge(otpToken);

            if ("lecturer".equalsIgnoreCase(request.role())) {
                Lecturer newLecturer = new Lecturer();
                newLecturer.setFullName(request.fullName());
                newLecturer.setEmail(request.email());
                newLecturer.setPassword(request.password());
                newLecturer.setStaffNumber(request.studentNo());
                em.persist(newLecturer);
            } else {
                Student newStudent = new Student();
                newStudent.setFullName(request.fullName());
                newStudent.setEmail(request.email());
                newStudent.setPassword(request.password());
                newStudent.setStudentNumber(request.studentNo());
                em.persist(newStudent);
            }

        } catch (NoResultException e) {
            throw new Exception("Invalid or expired OTP.");
        }
    }

    /**
     * Authenticates a user and returns a JWT token.
     *
     * FIX: Added suspension check. The original code only checked isBanned(),
     *      allowing suspended users to log in freely. We also auto-lift
     *      suspensions whose expiry timestamp has already passed.
     */
    @Transactional
    public String login(String email, String password) throws Exception {
        try {
            User user = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            // ── Check ban ──────────────────────────────────────────────────────
            if (user.isBanned()) {
                throw new Exception("Your account has been banned. Please contact administration.");
            }

            // ── Check suspension (auto-lift if the period has expired) ─────────
            if (user.isSuspended()) {
                LocalDateTime suspendedUntil = user.getSuspendedUntil();
                if (suspendedUntil != null && LocalDateTime.now().isAfter(suspendedUntil)) {
                    // Suspension has expired — lift it automatically
                    user.setSuspended(false);
                    user.setSuspendedUntil(null);
                    em.merge(user);
                } else {
                    // Still within the suspension window — block login
                    String until = (suspendedUntil != null)
                            ? suspendedUntil.toString().replace("T", " ")
                            : "further notice";
                    throw new Exception(
                            "Your account is suspended until " + until +
                            ". Please contact administration if you believe this is an error.");
                }
            }
            // ─────────────────────────────────────────────────────────────────

            if (!user.getPassword().equals(password)) {
                throw new Exception("Invalid email or password.");
            }

            return "mock-jwt-token-" + System.currentTimeMillis();

        } catch (NoResultException e) {
            throw new Exception("Invalid email or password.");
        }
    }

    /**
     * FIX: Same suspension check applied here so the session-based
     *      flow is also protected.
     */
    @Transactional
    public Long loginAndReturnUserId(String email, String password) throws Exception {
        try {
            User user = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            if (user.isBanned()) {
                throw new Exception("Your account has been banned.");
            }

            // ── Suspension check ───────────────────────────────────────────────
            if (user.isSuspended()) {
                LocalDateTime suspendedUntil = user.getSuspendedUntil();
                if (suspendedUntil != null && LocalDateTime.now().isAfter(suspendedUntil)) {
                    user.setSuspended(false);
                    user.setSuspendedUntil(null);
                    em.merge(user);
                } else {
                    String until = (suspendedUntil != null)
                            ? suspendedUntil.toString().replace("T", " ")
                            : "further notice";
                    throw new Exception("Your account is suspended until " + until + ".");
                }
            }
            // ─────────────────────────────────────────────────────────────────

            if (!user.getPassword().equals(password)) {
                throw new Exception("Invalid password.");
            }

            return user.getId();

        } catch (NoResultException e) {
            throw new Exception("Invalid email or password.");
        }
    }

    @Transactional
    public void generateAndSendOtp(String email) throws Exception {
        String otpCode = String.format("%06d", new Random().nextInt(999999));

        OtpToken otpToken = new OtpToken();
        otpToken.setEmail(email);
        otpToken.setToken(otpCode);
        otpToken.setExpiresAt(LocalDateTime.now().plusMinutes(10));
        em.persist(otpToken);

        System.out.println("Attempting to send real email to: " + email);
        emailService.sendOtpEmail(email, otpCode);
        System.out.println("Email sent successfully!");
    }

    public User getUserByEmail(String email) {
        try {
            return em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                     .setParameter("email", email)
                     .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }
}
