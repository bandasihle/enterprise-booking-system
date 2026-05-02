package com.ebs.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "complaints")
public class Complaint {

    public enum Status   { PENDING, IN_REVIEW, RESOLVED, DISMISSED }
    public enum Category { HARDWARE, SOFTWARE, NETWORK, CLEANLINESS, NOISE, OTHER }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false)
    private Category category;

    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private Status status = Status.PENDING;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId()                    { return id; }
    public Booking getBooking()            { return booking; }
    public void setBooking(Booking b)      { this.booking = b; }
    public Category getCategory()          { return category; }
    public void setCategory(Category c)    { this.category = c; }
    public String getDescription()         { return description; }
    public void setDescription(String d)   { this.description = d; }
    public Status getStatus()              { return status; }
    public void setStatus(Status s)        { this.status = s; }
    public LocalDateTime getCreatedAt()    { return createdAt; }
}
