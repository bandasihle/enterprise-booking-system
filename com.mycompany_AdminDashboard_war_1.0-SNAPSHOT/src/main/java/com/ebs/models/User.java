package com.ebs.models;

/*
 * Represents the users table in ebs_db
 * Columns: id, full_name, email, password, role, is_banned, ban_expiry, cancellation_count
 */
public class User {

    private int id;
    private String fullName;
    private String email;
    private String password;
    private String role;
    private boolean isBanned;
    private String banExpiry;
    private int cancellationCount;

    public User() {}

    // Constructor for adding a new user
    public User(String fullName, String email, String password, String role) {
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.role = role;
        this.isBanned = false;
        this.cancellationCount = 0;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isBanned() { return isBanned; }
    public void setBanned(boolean banned) { isBanned = banned; }

    public String getBanExpiry() { return banExpiry; }
    public void setBanExpiry(String banExpiry) { this.banExpiry = banExpiry; }

    public int getCancellationCount() { return cancellationCount; }
    public void setCancellationCount(int cancellationCount) { this.cancellationCount = cancellationCount; }
}