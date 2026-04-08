package com.ebs.dto;

public class StudentProfileDTO {

    private static final int BAN_THRESHOLD = 3;

    private Long    id;
    private String  fullName;
    private String  email;
    private String  studentNumber;
    private String  course;
    private boolean banned;
    private int     cancellationCount;

    public StudentProfileDTO(Long id, String fullName, String email,
                              String studentNumber, String course,
                              boolean banned, int cancellationCount) {
        this.id                = id;
        this.fullName          = fullName;
        this.email             = email;
        this.studentNumber     = studentNumber;
        this.course            = course;
        this.banned            = banned;
        this.cancellationCount = cancellationCount;
    }

    public Long    getId()                { return id; }
    public String  getFullName()          { return fullName; }
    public String  getEmail()             { return email; }
    public String  getStudentNumber()     { return studentNumber; }
    public String  getCourse()            { return course; }
    public boolean isBanned()             { return banned; }
    public int     getCancellationCount() { return cancellationCount; }

    /** True when student is one cancellation away from a ban — used by dashboard.jsp */
    public boolean isAtRiskOfBan() {
        return !banned && cancellationCount >= BAN_THRESHOLD - 1;
    }
}
