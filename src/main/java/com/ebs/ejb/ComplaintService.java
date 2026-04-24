package com.ebs.ejb;

import com.ebs.entity.Booking;
import com.ebs.entity.Complaint;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * EJB for complaint submission.
 * Uses JPA + container-managed transactions — no raw JDBC, no hardcoded credentials.
 */
@Stateless
public class ComplaintService {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public Complaint submitComplaint(Long bookingId, String categoryStr, String description) {

        Booking booking = em.find(Booking.class, bookingId);
        if (booking == null)
            throw new IllegalArgumentException("Booking not found: " + bookingId);

        long existing = em.createQuery(
                "SELECT COUNT(c) FROM Complaint c WHERE c.booking.id = :bid", Long.class)
                .setParameter("bid", bookingId)
                .getSingleResult();

        if (existing > 0)
            throw new IllegalStateException("A complaint already exists for this booking.");

        Complaint.Category category;
        try {
            category = Complaint.Category.valueOf(categoryStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            category = Complaint.Category.OTHER;
        }

        Complaint c = new Complaint();
        c.setBooking(booking);
        c.setCategory(category);
        c.setDescription(description);
        em.persist(c);
        return c;
    }
}
