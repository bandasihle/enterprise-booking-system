/**
 *
 * @author Muzi
 */
package com.ebs.util;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

@ApplicationScoped
public class EmailService {

    // TODO: Put your actual Gmail address and the 16-character App Password here
    private static final String SMTP_USER = "muziturner@gmail.com"; 
    private static final String SMTP_PASSWORD = "dpofacbwiqimmjzg";

    public void sendOtpEmail(String toEmail, String otpCode) throws Exception {
        // 1. Set up the Gmail SMTP server settings
        Properties props = new Properties();
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587"); // TLS Port
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true"); // Required by Gmail

        // 2. Authenticate with Google
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASSWORD);
            }
        });

        // 3. Draft the email
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SMTP_USER, "Enterprise Booking System"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Your EBS Registration Code");
        
        // 4. Create professional HTML content
        String htmlContent = "<div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>"
                + "<h2 style='color: #2563EB;'>Enterprise Booking System</h2>"
                + "<p>Welcome! Use the following 6-digit code to verify your student email address.</p>"
                + "<div style='font-size: 24px; font-weight: bold; background: #f3f4f6; padding: 15px; width: 120px; text-align: center; border-radius: 8px; letter-spacing: 2px;'>" 
                + otpCode 
                + "</div>"
                + "<p style='color: #666; font-size: 12px; margin-top: 20px;'>This code will expire in 10 minutes. If you did not request this, please ignore this email.</p>"
                + "</div>";
        
        message.setContent(htmlContent, "text/html; charset=utf-8");

        // 5. Send it!
        Transport.send(message);
    }
}