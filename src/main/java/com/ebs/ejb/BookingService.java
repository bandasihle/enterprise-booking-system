package com.ebs.ejb;


import com.ebs.entity.*;
import com.ebs.websocket.SeatAvailabilityBroadcaster;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.inject.Inject;
import jakarta.persistence.*;

/**
 * Core booking business logic.
 * @Stateless EJB gives us automatic transaction management and thread safety.
 */
@Stateless
public class BookingService {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Inject
    private SeatAvailabilityBroadcaster broadcaster;

    /**
     * Attempts to book a seat.
     * Uses OPTIMISTIC LOCKING (@Version on Seat entity) to handle
     * the "Ant Mechanism" - concurrent booking attempts on the same seat.
     * The first transaction to commit wins; the second throws OptimisticLockException.
     */
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public Booking bookSeat(Long userId, Long seatId, java.time.LocalDateTime start, java.time.LocalDateTime end) {
        Seat seat = em.find(Seat.class, seatId, LockModeType.OPTIMISTIC_FORCE_INCREMENT);

        if (!seat.isAvailable()) {
            throw new IllegalStateException("SEAT_TAKEN");
        }

        User user = em.find(User.class, userId);
        seat.setAvailable(false);

        Booking booking = new Booking();
        booking.setUser(user);
        booking.setSeat(seat);
        booking.setStartTime(start);
        booking.setEndTime(end);
        booking.setStatus(Booking.Status.CONFIRMED);

        em.persist(booking);

        // Broadcast real-time update to all connected WebSocket clients
        broadcaster.broadcastSeatUpdate(seat.getLab().getId(), seatId, false);

        return booking;
    }

    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public void cancelBooking(Long bookingId) {
        Booking booking = em.find(Booking.class, bookingId);
        booking.setStatus(Booking.Status.CANCELLED);
        booking.getSeat().setAvailable(true);

        // Track cancellations for admin ban logic
        User user = booking.getUser();
        user.setCancellationCount(user.getCancellationCount() + 1);

        broadcaster.broadcastSeatUpdate(
            booking.getSeat().getLab().getId(),
            booking.getSeat().getId(),
            true
        );
    }
}
