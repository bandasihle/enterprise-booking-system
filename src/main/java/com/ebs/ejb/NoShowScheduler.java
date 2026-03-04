package com.ebs.ejb;

import com.ebs.entity.Booking;
import jakarta.ejb.Schedule;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

/**
 * EJB Timer - runs every 5 minutes to auto-release no-show bookings.
 * If a student hasn't checked in within 15 minutes of their start time,
 * their seat is automatically released back into the pool.
 */
@Singleton
@Startup
public class NoShowScheduler {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Schedule(minute = "*/5", hour = "*", persistent = false)
    public void releaseNoShows() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(15);

        List<Booking> noShows = em.createQuery(
            "SELECT b FROM Booking b WHERE b.status = :status AND b.startTime <= :cutoff",
            Booking.class)
            .setParameter("status", Booking.Status.CONFIRMED)
            .setParameter("cutoff", cutoff)
            .getResultList();

        for (Booking booking : noShows) {
            booking.setStatus(Booking.Status.NO_SHOW);
            booking.getSeat().setAvailable(true);
            System.out.println("[NoShowScheduler] Released seat: " + booking.getSeat().getSeatNumber());
        }
    }
}
