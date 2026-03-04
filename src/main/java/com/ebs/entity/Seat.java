package com.ebs.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "seats")
public class Seat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "seat_number", nullable = false)
    private String seatNumber; // e.g. "PC-01", "PC-14"

    @Column(name = "is_available", nullable = false)
    private boolean available = true;

    @ManyToOne
    @JoinColumn(name = "lab_id", nullable = false)
    private Lab lab;

    // Version field for optimistic locking - THIS IS HOW WE HANDLE THE DEADLOCK
    // If two users grab the same seat simultaneously, JPA throws OptimisticLockException
    // for the second one. This is the proper enterprise solution for the "Ant Mechanism".
    @Version
    @Column(name = "version")
    private Long version;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }

    public Lab getLab() { return lab; }
    public void setLab(Lab lab) { this.lab = lab; }

    public Long getVersion() { return version; }
}
