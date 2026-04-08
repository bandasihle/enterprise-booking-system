package com.ebs.dto;

import java.util.List;

public class LabDTO {

    private Long        id;
    private String      labName;
    private String      building;
    private int         capacity;
    private int         availableSeats;
    private List<SeatDTO> seats;

    /** Used by dashboard listing — no seat detail needed */
    public LabDTO(Long id, String labName, String building, int capacity, int availableSeats) {
        this.id             = id;
        this.labName        = labName;
        this.building       = building;
        this.capacity       = capacity;
        this.availableSeats = availableSeats;
    }

    /** Used by booking page — includes full seat map */
    public LabDTO(Long id, String labName, String building,
                  int capacity, int availableSeats, List<SeatDTO> seats) {
        this(id, labName, building, capacity, availableSeats);
        this.seats = seats;
    }

    public Long          getId()             { return id; }
    public String        getLabName()        { return labName; }
    public String        getBuilding()       { return building; }
    public int           getCapacity()       { return capacity; }
    public int           getAvailableSeats() { return availableSeats; }
    public List<SeatDTO> getSeats()          { return seats; }
}
