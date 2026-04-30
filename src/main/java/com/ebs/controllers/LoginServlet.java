/*


boolean isSuspended = rs.getBoolean("is_suspended");
java.sql.Timestamp suspendedUntil = rs.getTimestamp("suspended_until");
boolean isBanned = rs.getBoolean("is_banned");

// Auto-lift expired suspension
if (isSuspended && suspendedUntil != null && suspendedUntil.before(new java.util.Date())) {
    PreparedStatement lift = conn.prepareStatement(
        "UPDATE users SET is_suspended = false, suspended_until = NULL WHERE id = ?"
    );
    lift.setInt(1, userId);
    lift.executeUpdate();
    isSuspended = false;
}

if (isBanned) {
    request.setAttribute("error", "Your account has been banned.");
    request.getRequestDispatcher("login.jsp").forward(request, response);
    return;
}

if (isSuspended) {
    request.setAttribute("error", "Your account is suspended until " + suspendedUntil + ". You cannot log in during this period.");
    request.getRequestDispatcher("login.jsp").forward(request, response);
    return;
}
// ... proceed to create session normally

















*/