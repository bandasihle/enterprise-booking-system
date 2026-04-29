package com.ebs.dto;

public class SeatDTO {

    private Long    id;
    private String  seatNumber;
    private boolean available;

    public SeatDTO(Long id, String seatNumber, boolean available) {
        this.id          = id;
        this.seatNumber  = seatNumber;
        this.available   = available;
    }

    public Long    getId()          { return id; }
    public String  getSeatNumber()  { return seatNumber; }
    public boolean isAvailable()    { return available; }
}
