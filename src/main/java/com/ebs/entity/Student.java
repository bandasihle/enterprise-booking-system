

package com.ebs.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "students")
@DiscriminatorValue("STUDENT")
public class Student extends User {

    @Column(name = "student_number", unique = true, nullable = false)
    private String studentNumber;

    @Column(name = "course")
    private String course;

    public String getStudentNumber() { return studentNumber; }
    public void setStudentNumber(String studentNumber) { this.studentNumber = studentNumber; }

    public String getCourse() { return course; }
    public void setCourse(String course) { this.course = course; }

}
