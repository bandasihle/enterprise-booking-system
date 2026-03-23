package com.ebs.websocket;


import jakarta.enterprise.context.ApplicationScoped;
import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * WebSocket endpoint for real-time seat availability updates.
 * When a seat is booked or released, ALL connected clients receive
 * a JSON message immediately - no polling required.
 *
 * Frontend connects via: new WebSocket("ws://localhost:8080/ebs/seats")
 */
@ApplicationScoped
@ServerEndpoint("/seats")
public class SeatAvailabilityBroadcaster {

    // Thread-safe set of all connected clients
    private static final Set<Session> sessions =
        Collections.synchronizedSet(new HashSet<>());

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
        System.out.println("[WebSocket] Client connected: " + session.getId());
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
    }

    @OnError
    public void onError(Session session, Throwable t) {
        sessions.remove(session);
        t.printStackTrace();
    }

    /**
     * Broadcasts seat status change to all connected clients.
     * Message format: {"labId": 1, "seatId": 5, "available": false}
     */
    public void broadcastSeatUpdate(Long labId, Long seatId, boolean available) {
        String message = String.format(
            "{\"labId\":%d,\"seatId\":%d,\"available\":%b}",
            labId, seatId, available
        );
        synchronized (sessions) {
            for (Session s : sessions) {
                if (s.isOpen()) {
                    try {
                        s.getBasicRemote().sendText(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
