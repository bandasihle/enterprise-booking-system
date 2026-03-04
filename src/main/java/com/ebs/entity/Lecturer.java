package com.ebs.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "lecturers")
@DiscriminatorValue("LECTURER")
public class Lecturer extends User {

    @Column(name = "staff_number", unique = true, nullable = false)
    private String staffNumber;

    @Column(name = "department")
    private String department;

    public String getStaffNumber() { return staffNumber; }
    public void setStaffNumber(String staffNumber) { this.staffNumber = staffNumber; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
}
