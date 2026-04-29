package com.ebs.ejb;

import com.ebs.entity.Lab;
import com.ebs.entity.LecturerBlock;
import com.ebs.entity.User;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.time.LocalDateTime;
import java.util.List;

/**
 * EJB service for lecturer full-lab block reservations.
 */
@Stateless
public class LecturerBlockService {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    /**
     * Creates a new lab block for a lecturer.
     * Validates for time overlaps on the same lab before persisting.
     *
     * @throws IllegalArgumentException if lecturer or lab not found
     * @throws IllegalStateException    with message "LAB_ALREADY_BLOCKED" on conflict
     */
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public LecturerBlock createBlock(Long lecturerId, Long labId,
                                     String moduleCode, String reason,
                                     LocalDateTime startTime, LocalDateTime endTime) {

        User lecturer = em.find(User.class, lecturerId);
        if (lecturer == null) throw new IllegalArgumentException("Lecturer not found: " + lecturerId);

        Lab lab = em.find(Lab.class, labId);
        if (lab == null) throw new IllegalArgumentException("Lab not found: " + labId);

        if (!startTime.isBefore(endTime))
            throw new IllegalArgumentException("Start time must be before end time.");

        // Check for overlapping confirmed block on this lab
        Long conflicts = em.createQuery(
                "SELECT COUNT(b) FROM LecturerBlock b " +
                "WHERE b.lab.id = :labId " +
                "AND b.status = 'CONFIRMED' " +
                "AND b.startTime < :end " +
                "AND b.endTime   > :start",
                Long.class)
                .setParameter("labId", labId)
                .setParameter("start", startTime)
                .setParameter("end",   endTime)
                .getSingleResult();

        if (conflicts > 0) throw new IllegalStateException("LAB_ALREADY_BLOCKED");

        LecturerBlock block = new LecturerBlock();
        block.setLecturer(lecturer);
        block.setLab(lab);
        block.setModuleCode(moduleCode);
        block.setReason(reason);
        block.setStartTime(startTime);
        block.setEndTime(endTime);
        block.setStatus("CONFIRMED");

        em.persist(block);
        return block;
    }

    /**
     * Returns upcoming CONFIRMED blocks for a specific lecturer, soonest first.
     * Used by the dashboard calendar table.
     */
    public List<LecturerBlock> getUpcomingBlocks(Long lecturerId) {
        return em.createQuery(
                "SELECT b FROM LecturerBlock b " +
                "WHERE b.lecturer.id = :id " +
                "AND b.startTime >= :now " +
                "AND b.status = 'CONFIRMED' " +
                "ORDER BY b.startTime ASC",
                LecturerBlock.class)
                .setParameter("id",  lecturerId)
                .setParameter("now", LocalDateTime.now())
                .getResultList();
    }

    /**
     * Returns ALL blocks for a lecturer (past + future), newest first.
     * Used by the View Bookings page.
     */
    public List<LecturerBlock> getAllBlocks(Long lecturerId) {
        return em.createQuery(
                "SELECT b FROM LecturerBlock b " +
                "WHERE b.lecturer.id = :id " +
                "ORDER BY b.startTime DESC",
                LecturerBlock.class)
                .setParameter("id", lecturerId)
                .getResultList();
    }

    /**
     * Returns all labs — used to populate the building/lab dropdowns.
     */
    public List<Lab> getAllLabs() {
        return em.createQuery(
                "SELECT l FROM Lab l ORDER BY l.building, l.labName",
                Lab.class)
                //.setParameter("id",  lecturerId) // This line is actually unnecessary for getAllLabs, removing in logic
                .getResultList();
    }

    /**
     * Cancels a specific lab block by updating its status to 'CANCELLED'.
     * This ensures the slot becomes available for others while keeping history.
     */
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public void cancelBlock(Long blockId) {
        LecturerBlock block = em.find(LecturerBlock.class, blockId);
        if (block != null) {
            block.setStatus("CANCELLED");
            // JPA will automatically synchronize this change with MySQL at the end of the method.
        } else {
            throw new IllegalArgumentException("Booking not found with ID: " + blockId);
        }
    }
}