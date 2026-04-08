/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
/**
 *
 * @author Muzi
 */
package com.ebs.service;

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

    /**
     * REGISTRATION STEP 1: Check if user exists, then generate OTP.
     */
    @Transactional
    public void initRegistration(String email, String studentNo) throws Exception {
        long emailCount = em.createQuery("SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                .setParameter("email", email).getSingleResult();
        if (emailCount > 0) throw new Exception("Email already registered.");

        long studentCount = em.createQuery("SELECT COUNT(s) FROM Student s WHERE s.studentNumber = :studentNo", Long.class)
                .setParameter("studentNo", studentNo).getSingleResult();
        if (studentCount > 0) throw new Exception("Student number already registered.");

        generateAndSendOtp(email);
    }

    /**
     * REGISTRATION STEP 2: Verify OTP and save the student to the database.
     */
    @Transactional
    public void verifyOtpAndRegister(RegisterRequest request) throws Exception {
        try {
            // 1. Verify the OTP
            OtpToken otpToken = em.createQuery(
                "SELECT o FROM OtpToken o WHERE o.email = :email AND o.token = :token AND o.used = false AND o.expiresAt > :now", OtpToken.class)
                .setParameter("email", request.email())
                .setParameter("token", request.otpCode())
                .setParameter("now", LocalDateTime.now())
                .getSingleResult();

            // 2. Mark OTP as used
            otpToken.setUsed(true);
            em.merge(otpToken);

            // 3. Save the new Student
            Student newStudent = new Student();
            newStudent.setFullName(request.fullName()); 
            newStudent.setEmail(request.email());
            newStudent.setPassword(request.password()); // TODO: Hash this later
            newStudent.setStudentNumber(request.studentNo()); 
            
            em.persist(newStudent);

        } catch (NoResultException e) {
            throw new Exception("Invalid or expired OTP.");
        }
    }

    /**
     * LOGIN: Verify credentials and return JWT immediately.
     */
    public String login(String email, String password) throws Exception {
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email).getSingleResult();

            if (user.isBanned()) throw new Exception("User is banned.");
            
            // TODO: Use PasswordUtil here later
            if (!user.getPassword().equals(password)) throw new Exception("Invalid password.");

            return "mock-jwt-token-" + System.currentTimeMillis();

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
        
        // --- THE REAL EMAIL DISPATCH ---
        System.out.println("Attempting to send real email to: " + email);
        emailService.sendOtpEmail(email, otpCode);
        System.out.println("Email sent successfully!");
    }
}