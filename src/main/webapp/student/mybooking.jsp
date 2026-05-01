<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EBS | My Bookings</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #f8fafc; color: #1e293b; font-family: 'Segoe UI', Arial, sans-serif; min-height: 100vh; }

        .navbar { position: sticky; top: 0; z-index: 1000; background: #ffffff; border-bottom: 1px solid #e2e8f0; box-shadow: 0 1px 8px rgba(0,0,0,0.06); display: flex; align-items: center; justify-content: space-between; padding: 0 28px; height: 60px; }
        .navbar .logo { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .navbar .logo img { width: 32px; height: 32px; border-radius: 8px; object-fit: cover; }
        .navbar .logo span { color: #1e293b; font-weight: 700; font-size: 18px; }
        .navbar .nav-links { display: flex; align-items: center; gap: 4px; }
        .navbar .nav-links a { color: #334155; text-decoration: none; padding: 6px 14px; border-radius: 8px; font-weight: 500; font-size: 14px; transition: background 0.15s, color 0.15s; }
        .navbar .nav-links a:hover { background: #eff6ff; color: #2563eb; }
        .navbar .nav-links a.active { background: #dbeafe; color: #1d4ed8; font-weight: 600; }

        .container { max-width: 1100px; margin: 0 auto; padding: 32px 24px; }
        .page-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; margin-bottom: 8px; }
        .page-title { font-size: 26px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
        .page-sub { font-size: 14px; color: #64748b; margin-bottom: 24px; }

        .alert { padding: 14px 18px; border-radius: 12px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 500; }
        .alert-success { background: #f0fdf4; color: #15803d; border: 1px solid #86efac; }
        .alert-error   { background: #fef2f2; color: #dc2626; border: 1px solid #fca5a5; }

        .stats-row { display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; }
        .stat-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px 20px; flex: 1; min-width: 120px; box-shadow: 0 1px 4px rgba(0,0,0,0.04); }
        .stat-card .stat-num { font-size: 28px; font-weight: 700; color: #1e293b; }
        .stat-card .stat-lbl { font-size: 12px; color: #64748b; font-weight: 500; margin-top: 2px; }
        .stat-card.upcoming .stat-num { color: #2563eb; }
        .stat-card.past .stat-num { color: #64748b; }
        .stat-card.cancelled .stat-num { color: #dc2626; }

        .tabs { display: flex; gap: 4px; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; }
        .tab { padding: 11px 20px; background: none; border: none; border-bottom: 2px solid transparent; font-size: 14px; font-weight: 600; color: #64748b; cursor: pointer; transition: all 0.15s; margin-bottom: -1px; }
        .tab:hover { color: #2563eb; }
        .tab.active { color: #2563eb; border-bottom-color: #2563eb; }

        .bookings-grid { display: grid; gap: 14px; }
        .booking-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 2px 8px rgba(0,0,0,0.05); padding: 18px 22px; display: flex; align-items: center; gap: 18px; transition: transform 0.15s, box-shadow 0.15s; }
        .booking-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
        .booking-card.cancelled-card { opacity: 0.7; }

        .booking-icon { width: 52px; height: 52px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; background: #dbeafe; color: #1d4ed8; }

        .booking-details { flex: 1; min-width: 0; }
        .booking-id { font-size: 11px; color: #94a3b8; font-weight: 600; letter-spacing: 0.05em; margin-bottom: 3px; }
        .booking-title { font-size: 16px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
        .booking-meta { font-size: 13px; color: #64748b; display: flex; gap: 14px; flex-wrap: wrap; }
        .booking-meta span { display: flex; align-items: center; gap: 5px; }

        .booking-status { padding: 5px 13px; border-radius: 20px; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; white-space: nowrap; flex-shrink: 0; }
        .status-upcoming  { background: #dbeafe; color: #1d4ed8; }
        .status-completed { background: #f1f5f9; color: #64748b; }
        .status-cancelled { background: #fef2f2; color: #dc2626; }
        .status-no_show   { background: #fef3c7; color: #b45309; }

        .booking-actions { display: flex; gap: 8px; flex-shrink: 0; }
        .btn-action { padding: 7px 14px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.15s; border: none; text-decoration: none; display: inline-flex; align-items: center; gap: 5px; }
        .btn-cancel { background: #fef2f2; color: #dc2626; }
        .btn-cancel:hover { background: #fee2e2; }
        .btn-complaint { background: #fef3c7; color: #b45309; }
        .btn-complaint:hover { background: #fde68a; }

        /* ── COMPLAINT MODAL ── */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.5); z-index: 2000; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal { background: #fff; border-radius: 20px; padding: 32px; width: 100%; max-width: 480px; box-shadow: 0 24px 64px rgba(0,0,0,0.18); }
        .modal h2 { font-size: 20px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
        .modal-sub { font-size: 13px; color: #64748b; margin-bottom: 22px; }
        .modal-booking-info { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px 16px; margin-bottom: 20px; font-size: 13px; color: #475569; }
        .modal-booking-info strong { color: #1e293b; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px; }
        .form-group select, .form-group textarea { width: 100%; padding: 10px 14px; border: 1.5px solid #e2e8f0; border-radius: 10px; font-size: 14px; font-family: inherit; color: #1e293b; background: #fff; transition: border-color 0.15s; outline: none; }
        .form-group select:focus, .form-group textarea:focus { border-color: #2563eb; }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 22px; }
        .btn-modal-cancel { padding: 9px 18px; border-radius: 9px; font-size: 14px; font-weight: 600; background: #f1f5f9; color: #64748b; border: none; cursor: pointer; }
        .btn-modal-cancel:hover { background: #e2e8f0; }
        .btn-modal-submit { padding: 9px 18px; border-radius: 9px; font-size: 14px; font-weight: 600; background: #2563eb; color: #fff; border: none; cursor: pointer; }
        .btn-modal-submit:hover { background: #1d4ed8; }

        .empty-state { text-align: center; padding: 56px 20px; color: #94a3b8; }
        .empty-state i { font-size: 56px; margin-bottom: 14px; display: block; color: #cbd5e1; }
        .empty-state h3 { font-size: 18px; font-weight: 600; color: #475569; margin-bottom: 8px; }
        .empty-state p { font-size: 14px; margin-bottom: 20px; }
        .btn-primary { display: inline-flex; align-items: center; gap: 8px; padding: 11px 22px; background: #2563eb; color: #fff; border-radius: 10px; text-decoration: none; font-weight: 600; font-size: 14px; transition: background 0.15s; }
        .btn-primary:hover { background: #1d4ed8; }

        @media (max-width: 640px) {
            .booking-card { flex-direction: column; align-items: flex-start; }
            .booking-actions { width: 100%; }
        }
    </style>
</head>
<body>

<nav class="navbar">
    <a href="${pageContext.request.contextPath}/test-index.html" style="text-decoration:none;color:inherit;">
        <div class="logo">
            <img src="${pageContext.request.contextPath}/images/logo.jpeg" alt="EBS">
            <span>EBS</span>
        </div>
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/student/ict-lab-seats.jsp">Book PC</a>
        <a href="${pageContext.request.contextPath}/student/mybookings" class="active">My Bookings</a>
    </div>
</nav>

<div class="container">

    <div class="page-header">
        <div>
            <h1 class="page-title">My Bookings</h1>
            <p class="page-sub">All your lab seat reservations in one place.</p>
        </div>
        <a href="${pageContext.request.contextPath}/student/ict-lab-seats.jsp" class="btn-primary">
            <i class="fas fa-plus"></i> New Booking
        </a>
    </div>

    <c:if test="${not empty flash}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> ${flash}
        </div>
    </c:if>

    <c:if test="${loadError}">
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i> Could not load your bookings. Please refresh the page.
        </div>
    </c:if>

    <div class="stats-row">
        <div class="stat-card upcoming">
            <div class="stat-num">${fn:length(upcomingBookings)}</div>
            <div class="stat-lbl">Upcoming</div>
        </div>
        <div class="stat-card past">
            <div class="stat-num">${fn:length(pastBookings)}</div>
            <div class="stat-lbl">Past</div>
        </div>
        <div class="stat-card cancelled">
            <div class="stat-num">${fn:length(cancelledBookings)}</div>
            <div class="stat-lbl">Cancelled</div>
        </div>
        <div class="stat-card">
            <div class="stat-num">${totalBookings}</div>
            <div class="stat-lbl">Total</div>
        </div>
    </div>

    <div class="tabs">
        <button class="tab active" onclick="showTab('upcoming', this)">Upcoming</button>
        <button class="tab" onclick="showTab('past', this)">Past</button>
        <button class="tab" onclick="showTab('cancelled', this)">Cancelled</button>
    </div>

    <div id="tab-upcoming" class="bookings-grid">
        <c:choose>
            <c:when test="${empty upcomingBookings}">
                <div class="empty-state">
                    <i class="fas fa-calendar-plus"></i>
                    <h3>No upcoming bookings</h3>
                    <p>You don't have any confirmed upcoming reservations.</p>
                    <a href="${pageContext.request.contextPath}/student/ict-lab-seats.jsp" class="btn-primary">
                        <i class="fas fa-plus"></i> Book a Seat
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="b" items="${upcomingBookings}">
                    <div class="booking-card">
                        <div class="booking-icon"><i class="fas fa-desktop"></i></div>
                        <div class="booking-details">
                            <div class="booking-id">Booking #${b.id}</div>
                            <div class="booking-title">
                                ${b.seatNumber}
                                <span style="color:#64748b;font-weight:500;"> — ${b.labName}</span>
                            </div>
                            <div class="booking-meta">
                                <span><i class="fas fa-map-marker-alt"></i> ${b.building}</span>
                                <span><i class="fas fa-calendar"></i> ${b.startTime}</span>
                                <span><i class="fas fa-clock"></i> ${b.startTime} - ${b.endTime}</span>
                            </div>
                        </div>
                        <span class="booking-status status-upcoming">${b.status}</span>
                        <div class="booking-actions">
                            <form method="POST" action="${pageContext.request.contextPath}/student/mybookings">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="bookingId" value="${b.id}">
                                <button type="submit" class="btn-action btn-cancel"
                                        onclick="return confirm('Cancel booking #${b.id}?')">
                                    <i class="fas fa-times"></i> Cancel
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

    <div id="tab-past" class="bookings-grid" style="display:none;">
        <c:choose>
            <c:when test="${empty pastBookings}">
                <div class="empty-state">
                    <i class="fas fa-history"></i>
                    <h3>No past bookings</h3>
                    <p>Completed bookings will appear here.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="b" items="${pastBookings}">
                    <div class="booking-card">
                        <div class="booking-icon" style="background:#f1f5f9;color:#64748b;">
                            <i class="fas fa-desktop"></i>
                        </div>
                        <div class="booking-details">
                            <div class="booking-id">Booking #${b.id}</div>
                            <div class="booking-title">
                                ${b.seatNumber}
                                <span style="color:#64748b;font-weight:500;"> — ${b.labName}</span>
                            </div>
                            <div class="booking-meta">
                                <span><i class="fas fa-map-marker-alt"></i> ${b.building}</span>
                                <span><i class="fas fa-calendar"></i> ${b.startTime}</span>
                                <span><i class="fas fa-clock"></i> ${b.startTime} - ${b.endTime}</span>
                            </div>
                        </div>
                        <span class="booking-status status-completed">${b.status}</span>
                        <div class="booking-actions">
                            <button type="button" class="btn-action btn-complaint"
                                    onclick="openComplaintModal('${b.id}','${b.seatNumber}','${b.labName}','${b.startTime}')">
                                <i class="fas fa-flag"></i> Report Issue
                            </button>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

    <div id="tab-cancelled" class="bookings-grid" style="display:none;">
        <c:choose>
            <c:when test="${empty cancelledBookings}">
                <div class="empty-state">
                    <i class="fas fa-ban"></i>
                    <h3>No cancelled bookings</h3>
                    <p>Cancelled reservations will appear here.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="b" items="${cancelledBookings}">
                    <div class="booking-card cancelled-card">
                        <div class="booking-icon" style="background:#fef2f2;color:#dc2626;">
                            <i class="fas fa-desktop"></i>
                        </div>
                        <div class="booking-details">
                            <div class="booking-id">Booking #${b.id}</div>
                            <div class="booking-title">
                                ${b.seatNumber}
                                <span style="color:#64748b;font-weight:500;"> — ${b.labName}</span>
                            </div>
                            <div class="booking-meta">
                                <span><i class="fas fa-map-marker-alt"></i> ${b.building}</span>
                                <span><i class="fas fa-calendar"></i> ${b.startTime}</span>
                                <span><i class="fas fa-clock"></i> ${b.startTime} - ${b.endTime}</span>
                            </div>
                        </div>
                        <span class="booking-status status-cancelled">${b.status}</span>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<!-- ══════════════════════════════════════
     COMPLAINT MODAL
     ══════════════════════════════════════ -->
<div class="modal-overlay" id="complaintModal">
    <div class="modal">
        <h2>⚠️ Report an Issue</h2>
        <p class="modal-sub">Describe the problem you experienced during this booking.</p>

        <div class="modal-booking-info" id="modalBookingInfo"></div>

        <form method="POST" action="${pageContext.request.contextPath}/submitComplaint">
            <input type="hidden" name="bookingId" id="modalBookingId"/>

            <div class="form-group">
                <label for="category">Category</label>
                <select name="category" id="category" required>
                    <option value="" disabled selected>Select a category...</option>
                    <option value="HARDWARE">🖥️ Hardware (PC, monitor, keyboard)</option>
                    <option value="SOFTWARE">💿 Software (crashes, errors)</option>
                    <option value="NETWORK">📶 Network / Internet</option>
                    <option value="CLEANLINESS">🧹 Cleanliness</option>
                    <option value="NOISE">🔊 Noise / Disturbance</option>
                    <option value="OTHER">📝 Other</option>
                </select>
            </div>

            <div class="form-group">
                <label for="description">Description</label>
                <textarea name="description" id="description" required
                          placeholder="Describe the issue in detail..."></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-modal-cancel" onclick="closeComplaintModal()">Cancel</button>
                <button type="submit" class="btn-modal-submit">Submit Complaint</button>
            </div>
        </form>
    </div>
</div>

<script>
    function showTab(name, btn) {
        ['upcoming', 'past', 'cancelled'].forEach(function(tab) {
            document.getElementById('tab-' + tab).style.display = 'none';
        });
        document.querySelectorAll('.tab').forEach(function(t) { t.classList.remove('active'); });
        document.getElementById('tab-' + name).style.display = 'grid';
        btn.classList.add('active');
    }

    function openComplaintModal(bookingId, seatNumber, labName, startTime) {
        document.getElementById('modalBookingId').value = bookingId;
        document.getElementById('modalBookingInfo').innerHTML =
            '<strong>Booking #' + bookingId + '</strong> &nbsp;·&nbsp; ' +
            seatNumber + ' — ' + labName + ' &nbsp;·&nbsp; ' + startTime;
        document.getElementById('category').value = '';
        document.getElementById('description').value = '';
        document.getElementById('complaintModal').classList.add('open');
    }

    function closeComplaintModal() {
        document.getElementById('complaintModal').classList.remove('open');
    }

    document.getElementById('complaintModal').addEventListener('click', function(e) {
        if (e.target === this) closeComplaintModal();
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeComplaintModal();
    });
</script>

</body>
</html>