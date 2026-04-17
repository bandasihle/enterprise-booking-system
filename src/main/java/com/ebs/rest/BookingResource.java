
package com.ebs.rest;
import com.ebs.ejb.BookingService;
import com.ebs.entity.Booking;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import java.time.LocalDateTime;

/**
 * REST API endpoint for bookings.
 * Base path: /api/bookings
 */
@Path("/bookings")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class BookingResource {

    @Inject
    private BookingService bookingService;

    /**
     * POST /api/bookings
     * Body: { "userId": 1, "seatId": 5, "startTime": "...", "endTime": "..." }
     */
    @POST
    public Response createBooking(BookingRequest request) {
        try {
            Booking booking = bookingService.bookSeat(
                request.userId,
                request.seatId,
                request.startTime,
                request.endTime
            );
            return Response.status(Response.Status.CREATED)
                           .entity(booking.getId())
                           .build();
        } catch (IllegalStateException e) {
            // Seat already taken (deadlock resolved - second user loses)
            return Response.status(Response.Status.CONFLICT)
                           .entity("{\"error\":\"SEAT_TAKEN\"}")
                           .build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                           .entity("{\"error\":\"BOOKING_FAILED\"}")
                           .build();
        }
    }

    /**
     * DELETE /api/bookings/{id}
     */
    @DELETE
    @Path("/{id}")
    public Response cancelBooking(@PathParam("id") Long id) {
        bookingService.cancelBooking(id);
        return Response.noContent().build();
    }

    // Inner class for request body deserialization
    public static class BookingRequest {
        public Long userId;
        public Long seatId;
        public LocalDateTime startTime;
        public LocalDateTime endTime;
    }
}
