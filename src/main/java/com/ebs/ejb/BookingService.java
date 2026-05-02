package com.ebs.ejb;

import com.ebs.entity.*;
import com.ebs.websocket.SeatAvailabilityBroadcaster;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.inject.Inject;
import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Core booking business logic.
 *
 * Fixes applied:
 *  1. bookSeat()      — checks for active ban before allowing a booking
 *  2. bookSeat()      — rejects booking if the lab is under maintenance
 *  3. cancelBooking() — triggers a 24-hour auto-ban when cancellationCount >= 3
 */
@Stateless
public class BookingService {

    private static final int BAN_THRESHOLD       = 3;
    private static final int BAN_DURATION_HOURS  = 24;

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Inject
    private SeatAvailabilityBroadcaster broadcaster;

    // ─────────────────────────────────────────────────────────────
    // Book a seat
    // ─────────────────────────────────────────────────────────────

    /**
     * Attempts to book a seat.
     *
     * Uses OPTIMISTIC LOCKING (@Version on Seat entity) to resolve
     * concurrent booking attempts on the same seat — the "Ant Mechanism".
     * First transaction to commit wins; the second throws OptimisticLockException.
     *
     * @throws SecurityException     if the user is currently banned
     * @throws IllegalStateException "SEAT_TAKEN"              if seat is already booked
     * @throws IllegalStateException "LAB_UNDER_MAINTENANCE"   if the lab is not Active
     * @throws IllegalArgumentException if user or seat ID not found
     */
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public Booking bookSeat(Long userId, Long seatId,
                            LocalDateTime start, LocalDateTime end) {

        // 1. Validate user and check ban
        User user = em.find(User.class, userId);
        if (user == null) {
            throw new IllegalArgumentException("User not found: " + userId);
        }
        if (user.isBanned()) {
            throw new SecurityException("USER_BANNED");
        }

        // 2. Acquire seat with optimistic lock
        // OPTIMISTIC_FORCE_INCREMENT bumps @Version even on read —
        // guarantees a second concurrent attempt fails fast.
        Seat seat = em.find(Seat.class, seatId, LockModeType.OPTIMISTIC_FORCE_INCREMENT);
        if (seat == null) {
            throw new IllegalArgumentException("Seat not found: " + seatId);
        }

        // 3. Guard: refuse booking if the lab is under maintenance
        Lab lab = seat.getLab();
        if (lab == null || !"Active".equalsIgnoreCase(lab.getStatus())) {
            throw new IllegalStateException("LAB_UNDER_MAINTENANCE");
        }

        if (!seat.isAvailable()) {
            throw new IllegalStateException("SEAT_TAKEN");
        }

        // 4. Create and persist booking
        seat.setAvailable(false);

        Booking booking = new Booking();
        booking.setUser(user);
        booking.setSeat(seat);
        booking.setStartTime(start);
        booking.setEndTime(end);
        booking.setStatus(Booking.Status.CONFIRMED);
        em.persist(booking);

        // 5. Broadcast real-time seat update to all WebSocket clients
        broadcaster.broadcastSeatUpdate(lab.getId(), seatId, false);

        return booking;
    }

    // ─────────────────────────────────────────────────────────────
    // Cancel a booking
    // ─────────────────────────────────────────────────────────────

    /**
     * Cancels a booking, frees the seat, increments cancellation count,
     * and triggers a 24-hour auto-ban if the threshold is reached.
     *
     * @throws IllegalArgumentException if the booking does not exist
     * @throws IllegalStateException    if the booking is not CONFIRMED
     */
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public void cancelBooking(Long bookingId) {
        Booking booking = em.find(Booking.class, bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found: " + bookingId);
        }
        if (booking.getStatus() != Booking.Status.CONFIRMED) {
            throw new IllegalStateException("Only CONFIRMED bookings can be cancelled");
        }

        // Update booking and seat
        booking.setStatus(Booking.Status.CANCELLED);
        Seat seat = booking.getSeat();
        seat.setAvailable(true);

        // Track cancellation and auto-ban if threshold reached
        User user = booking.getUser();
        user.setCancellationCount(user.getCancellationCount() + 1);

        if (user.getCancellationCount() >= BAN_THRESHOLD) {
            user.setBanned(true);
            user.setBanExpiry(LocalDateTime.now().plusHours(BAN_DURATION_HOURS));
            System.out.printf("[BookingService] Auto-banned %s for %d hours (cancellations: %d)%n",
                    user.getEmail(), BAN_DURATION_HOURS, user.getCancellationCount());
        }

        // Broadcast seat freed
        broadcaster.broadcastSeatUpdate(seat.getLab().getId(), seat.getId(), true);
    }
}
