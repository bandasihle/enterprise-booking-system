package com.ebs.ejb;

import com.ebs.dto.BookingDTO;
import com.ebs.dto.LabDTO;
import com.ebs.dto.SeatDTO;
import com.ebs.dto.StudentProfileDTO;
import com.ebs.entity.Booking;
import com.ebs.entity.Lab;
import com.ebs.entity.Seat;
import com.ebs.entity.Student;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.ws.rs.NotFoundException;

import java.util.List;
import java.util.stream.Collectors;

/**
 * All read operations needed by the student dashboard Servlets.
 *
 * Kept @Stateless — no conversational state, safe for container pooling.
 * All write operations (booking, cancellation) remain in BookingService.
 */
@Stateless
public class StudentDashboardService {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    // ─────────────────────────────────────────────────────────────
    // Labs
    // ─────────────────────────────────────────────────────────────

    /**
     * All labs with a live available-seat count each.
     * Uses a subquery COUNT per lab to avoid N+1 fetching.
     */
    @TransactionAttribute(TransactionAttributeType.SUPPORTS)
    public List<LabDTO> getAllLabsWithAvailability() {
        List<Lab> labs = em.createQuery("SELECT l FROM Lab l", Lab.class)
                           .getResultList();

        return labs.stream().map(lab -> {
            long available = em.createQuery(
                    "SELECT COUNT(s) FROM Seat s WHERE s.lab.id = :labId AND s.available = true",
                    Long.class)
                    .setParameter("labId", lab.getId())
                    .getSingleResult();

            return new LabDTO(lab.getId(), lab.getLabName(),
                              lab.getBuilding(), lab.getCapacity(), (int) available);
        }).collect(Collectors.toList());
    }

    /**
     * Single lab including full seat map — used by booking.jsp to render the grid.
     *
     * @throws NotFoundException if no lab with that ID exists
     */
    @TransactionAttribute(TransactionAttributeType.SUPPORTS)
    public LabDTO getLabWithSeats(Long labId) {
        Lab lab = em.find(Lab.class, labId);
        if (lab == null) throw new NotFoundException("Lab not found: " + labId);

        List<SeatDTO> seats = em.createQuery(
                "SELECT s FROM Seat s WHERE s.lab.id = :labId ORDER BY s.seatNumber",
                Seat.class)
                .setParameter("labId", labId)
                .getResultList()
                .stream()
                .map(s -> new SeatDTO(s.getId(), s.getSeatNumber(), s.isAvailable()))
                .collect(Collectors.toList());

        long available = seats.stream().filter(SeatDTO::isAvailable).count();
        return new LabDTO(lab.getId(), lab.getLabName(), lab.getBuilding(),
                          lab.getCapacity(), (int) available, seats);
    }

    // ─────────────────────────────────────────────────────────────
    // Bookings
    // ─────────────────────────────────────────────────────────────

    /**
     * Full booking history for a student, newest first.
     * JOIN FETCH prevents LazyInitializationException after the transaction closes.
     */
    @TransactionAttribute(TransactionAttributeType.SUPPORTS)
    public List<BookingDTO> getStudentBookings(Long studentId) {
        return em.createQuery(
                "SELECT b FROM Booking b " +
                "JOIN FETCH b.seat s JOIN FETCH s.lab l " +
                "WHERE b.user.id = :studentId " +
                "ORDER BY b.createdAt DESC",
                Booking.class)
                .setParameter("studentId", studentId)
                .getResultList()
                .stream()
                .map(b -> new BookingDTO(
                        b.getId(),
                        b.getSeat().getLab().getLabName(),
                        b.getSeat().getLab().getBuilding(),
                        b.getSeat().getSeatNumber(),
                        b.getStartTime(),
                        b.getEndTime(),
                        b.getStatus().name()))
                .collect(Collectors.toList());
    }

    // ─────────────────────────────────────────────────────────────
    // Profile
    // ─────────────────────────────────────────────────────────────

    /**
     * Student profile — never exposes raw entity (contains password hash).
     *
     * @throws NotFoundException if student does not exist
     */
    @TransactionAttribute(TransactionAttributeType.SUPPORTS)
    public StudentProfileDTO getStudentProfile(Long studentId) {
        try {
            Student s = em.createQuery(
                    "SELECT s FROM Student s WHERE s.id = :id", Student.class)
                    .setParameter("id", studentId)
                    .getSingleResult();

            return new StudentProfileDTO(s.getId(), s.getFullName(), s.getEmail(),
                                         s.getStudentNumber(), s.getCourse(),
                                         s.isBanned(), s.getCancellationCount());
        } catch (NoResultException e) {
            throw new NotFoundException("Student not found: " + studentId);
        }
    }
}
