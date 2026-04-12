package com.ebs.ejb;

import com.ebs.entity.Booking;
import com.ebs.websocket.SeatAvailabilityBroadcaster;
import jakarta.ejb.Schedule;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.time.LocalDateTime;
import java.util.List;

/**
 * EJB Timer — runs every 5 minutes to auto-release no-show bookings.
 *
 * If a student has not shown up within 15 minutes of their start time,
 * the seat is released back into the pool.
 *
 * Fix: now broadcasts WebSocket updates for freed seats so every connected
 * browser sees the seat turn green in real time without a page refresh.
 */
@Singleton
@Startup
public class NoShowScheduler {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Inject
    private SeatAvailabilityBroadcaster broadcaster;

    @Schedule(minute = "*/5", hour = "*", persistent = false)
    public void releaseNoShows() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(15);

        List<Booking> noShows = em.createQuery(
                "SELECT b FROM Booking b " +
                "JOIN FETCH b.seat s " +
                "JOIN FETCH s.lab l " +
                "WHERE b.status = :status AND b.startTime <= :cutoff",
                Booking.class)
                .setParameter("status", Booking.Status.CONFIRMED)
                .setParameter("cutoff", cutoff)
                .getResultList();

        for (Booking booking : noShows) {
            booking.setStatus(Booking.Status.NO_SHOW);
            booking.getSeat().setAvailable(true);

            System.out.printf("[NoShowScheduler] Released seat %s (booking #%d)%n",
                    booking.getSeat().getSeatNumber(), booking.getId());

            broadcaster.broadcastSeatUpdate(
                    booking.getSeat().getLab().getId(),
                    booking.getSeat().getId(),
                    true
            );
        }
    }
}
