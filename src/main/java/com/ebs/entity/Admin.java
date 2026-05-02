/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
/**
 *
 * @author Muzi
 */
package com.ebs.entity;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import java.time.LocalDateTime;

@Entity
@DiscriminatorValue("ADMIN") // Tells JPA this is the Admin version of a User
public class Admin extends User {

    // Extra security tracking specifically for admins
    @Column(name = "clearance_level")
    private String clearanceLevel = "SYSTEM_ADMIN";

    @Column(name = "last_audit_date")
    private LocalDateTime lastAuditDate;

    public Admin() {
        // Default constructor required by JPA
    }

    // Getters and Setters
    public String getClearanceLevel() {
        return clearanceLevel;
    }

    public void setClearanceLevel(String clearanceLevel) {
        this.clearanceLevel = clearanceLevel;
    }

    public LocalDateTime getLastAuditDate() {
        return lastAuditDate;
    }

    public void setLastAuditDate(LocalDateTime lastAuditDate) {
        this.lastAuditDate = lastAuditDate;
    }
}