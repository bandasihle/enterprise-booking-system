

package com.ebs.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

/**
 * Base User entity - inherited by Student, Lecturer, Admin
 * Uses JPA JOINED inheritance strategy for clean table separation.
 */
@Entity
@Table(name = "users")
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "role", discriminatorType = DiscriminatorType.STRING)


public abstract class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(name = "full_name", nullable = false)
    private String fullName;

    @NotBlank
    @Email
    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank
    @Column(nullable = false)
    private String password; // Store BCrypt hash - never plain text

    @Column(name = "is_banned", nullable = false)
    private boolean banned = false;

    @Column(name = "cancellation_count", nullable = false)
    private int cancellationCount = 0;

    @Column(name = "ban_expiry")
    private java.time.LocalDateTime banExpiry;
    
    @Column(name = "role", insertable = false, updatable = false)
    private String role;
    

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public boolean isBanned() { return banned; }
    public void setBanned(boolean banned) { this.banned = banned; }

    public int getCancellationCount() { return cancellationCount; }
    public void setCancellationCount(int cancellationCount) { this.cancellationCount = cancellationCount; }

    public java.time.LocalDateTime getBanExpiry() { return banExpiry; }
    public void setBanExpiry(java.time.LocalDateTime banExpiry) { this.banExpiry = banExpiry; }
    
    public String getRole() { 
        return role; 
    }
}
