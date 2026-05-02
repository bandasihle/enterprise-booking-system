package com.ebs.entity;
import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "labs")
public class Lab {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "lab_name", nullable = false)
    private String labName;

    @Column(name = "building", nullable = false)
    private String building;

    @Column(name = "capacity", nullable = false)
    private int capacity;

    /** Maps the DB `status` column — 'Active' or 'Maintenance'. */
    @Column(name = "status")
    private String status;

    @OneToMany(mappedBy = "lab", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Seat> seats;

    public Long getId()             { return id; }
    public void setId(Long id)      { this.id = id; }

    public String getLabName()              { return labName; }
    public void   setLabName(String n)      { this.labName = n; }

    public String getBuilding()             { return building; }
    public void   setBuilding(String b)     { this.building = b; }

    public int  getCapacity()               { return capacity; }
    public void setCapacity(int c)          { this.capacity = c; }

    public String getStatus()               { return status; }
    public void   setStatus(String s)       { this.status = s; }

    public List<Seat> getSeats()            { return seats; }
    public void       setSeats(List<Seat> s){ this.seats = s; }
}
