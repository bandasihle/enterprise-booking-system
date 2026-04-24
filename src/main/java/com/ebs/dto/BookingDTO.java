package com.ebs.dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Booking summary passed to mybooking.jsp.
 *
 * Pre-formatted getters are needed because JSTL <fmt:formatDate>
 * only accepts java.util.Date — it cannot handle LocalDateTime.
 * Formatting here keeps the JSP EL clean: ${booking.formattedDate}.
 */
public class BookingDTO {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd MMM yyyy");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    private Long          id;
    private String        labName;
    private String        building;
    private String        seatNumber;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String        status;

    public BookingDTO(Long id, String labName, String building, String seatNumber,
                      LocalDateTime startTime, LocalDateTime endTime, String status) {
        this.id         = id;
        this.labName    = labName;
        this.building   = building;
        this.seatNumber = seatNumber;
        this.startTime  = startTime;
        this.endTime    = endTime;
        this.status     = status;
    }

    // Raw getters
    public Long          getId()         { return id; }
    public String        getLabName()    { return labName; }
    public String        getBuilding()   { return building; }
    public String        getSeatNumber() { return seatNumber; }
    public LocalDateTime getStartTime()  { return startTime; }
    public LocalDateTime getEndTime()    { return endTime; }
    public String        getStatus()     { return status; }

    // Formatted getters — used in JSP EL
    public String getFormattedDate() {
        return startTime != null ? startTime.format(DATE_FMT) : "—";
    }

    public String getFormattedTimeRange() {
        if (startTime == null || endTime == null) return "—";
        return startTime.format(TIME_FMT) + " – " + endTime.format(TIME_FMT);
    }

    /** e.g. #B0042 */
    public String getDisplayId() {
        return "#B" + String.format("%04d", id);
    }
}
