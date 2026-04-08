<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EBS | Book a Seat</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
  /* ── Sticky navbar ─────────────────────────────────── */
  .navbar {
    position: sticky;
    top: 0;
    z-index: 1000;
    background: #ffffff;
    border-bottom: 6px solid #e2e8f0;
    box-shadow: 0 1px 10px rgba(0,0,0,0.06);
  }

  /* ── Nav links ─────────────────────────────────────── */
  .navbar .nav-links a {
    color: #334155;
    text-decoration: none;
    padding: 6px 14px;
    border-radius: 8px;
    font-weight: 500;
    font-size: 14px;
    transition: background 0.15s, color 0.15s;
  }

  .navbar .nav-links a:hover {
    background: #eff6ff;
    color: #2563eb;
  }

  .navbar .nav-links a.active {
    background: #dbeafe;
    color: #1d4ed8;
    font-weight: 600;
  }

  /* ── Logo text ─────────────────────────────────────── */
  .navbar .logo span {
    color: #1e293b;
    font-weight: 700;
    font-size: 18px;
  }
</style>

</head>
<body>

<nav class="navbar">
    <div class="logo">
        <img src="${pageContext.request.contextPath}/images/logo.jpeg" class="logo-img" alt="EBS">
        <span>EBS</span>
    </div>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/dashboard.jsp">Dashboard</a>
        <a href="${pageContext.request.contextPath}/student/booking.jsp" class="active">Book Seat</a>
        <a href="${pageContext.request.contextPath}/student/mybooking.jsp">My Bookings</a>
    </div>
</nav>

<div class="container">

    <%-- Error banners from failed POST --%>
    <c:choose>
        <c:when test="${error == 'USER_BANNED'}">
            <div class="alert alert-danger">
                <i class="fas fa-ban"></i>
                <strong>Account banned.</strong> You cannot make new bookings while your account is suspended.
            </div>
        </c:when>
        <c:when test="${error == 'SEAT_TAKEN'}">
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i>
                That seat was just taken. Please choose another seat.
            </div>
        </c:when>
        <c:when test="${error == 'BOOKING_FAILED'}">
            <div class="alert alert-danger">
                <i class="fas fa-times-circle"></i>
                Booking failed due to a server error. Please try again.
            </div>
        </c:when>
    </c:choose>

    <c:choose>
        <c:when test="${empty lab}">
            <div class="empty-state">
                <i class="fas fa-building"></i>
                No lab selected.
                <a href="${pageContext.request.contextPath}/student/dashboard">Back to Dashboard</a>
            </div>
        </c:when>
        <c:otherwise>

            <h1 class="page-title">Book a Seat &mdash; ${lab.labName}</h1>

            <%-- Hero image chosen by building type --%>
            <c:set var="img" value="${pageContext.request.contextPath}/images/lab.jpg"/>
            <c:if test="${fn:containsIgnoreCase(lab.building, 'auditorium')}">
                <c:set var="img" value="${pageContext.request.contextPath}/images/Auditorium.jpg"/>
            </c:if>
            <c:if test="${fn:containsIgnoreCase(lab.building, 'lecture')}">
                <c:set var="img" value="${pageContext.request.contextPath}/images/LectureHall.jpg"/>
            </c:if>
            <img src="${img}" class="booking-image" alt="${lab.labName}">

            <%-- Lab info card --%>
            <div class="info-card">
                <h3><i class="fas fa-info-circle"></i> Lab Information</h3>
                <p><i class="fas fa-building"></i>&nbsp; ${lab.building}</p>
                <p><i class="fas fa-desktop"></i>&nbsp; Total seats: ${lab.capacity}</p>
                <p>
                    <i class="fas fa-check-circle" style="color:#10B981"></i>&nbsp;
                    Available now: <strong style="color:#10B981">${lab.availableSeats}</strong>
                </p>
            </div>

            <%-- WebSocket live indicator --%>
            <div class="ws-status">
                <span class="ws-dot" id="wsDot"></span>
                <span id="wsText">Connecting to live updates...</span>
            </div>

            <%-- Booking form: POST to BookingServlet --%>
            <form method="post"
                  action="${pageContext.request.contextPath}/student/booking"
                  id="bookingForm"
                  onsubmit="return validateForm()">

                <input type="hidden" name="labId"  value="${lab.id}">
                <input type="hidden" name="seatId" id="seatIdInput" value="">

                <%-- Date and time --%>
                <div class="form-row">
                    <div class="form-group">
                        <label for="bookingDate">Date</label>
                        <input type="date" class="form-control" name="bookingDate"
                               id="bookingDate" min="${minDate}" value="${today}" required>
                    </div>
                    <div class="form-group">
                        <label for="startHour">Start Time (2-hour slot)</label>
                        <select class="form-control" name="startHour" id="startHour">
                            <c:forEach begin="8" end="20" var="h">
                                <option value="${h}">
                                    <c:if test="${h < 10}">0</c:if>${h}:00
                                    &ndash;
                                    <c:if test="${h+2 < 10}">0</c:if>${h+2}:00
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <%-- Seat grid --%>
                <h2 style="margin-bottom:0.75rem">Select Your Seat</h2>

                <div class="legend">
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#d1fae5;border:2px solid #6ee7b7"></div>
                        Available
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#fee2e2;border:2px solid #fca5a5"></div>
                        Booked
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#2563EB;border:2px solid #2563EB"></div>
                        Selected
                    </div>
                </div>

                <div class="seat-grid" id="seatGrid">
                    <c:forEach var="seat" items="${lab.seats}">
                        <div class="seat ${seat.available ? 'available' : 'booked'}"
                             id="seat-${seat.id}"
                             data-seat-id="${seat.id}"
                             data-seat-num="${seat.seatNumber}"
                             onclick="selectSeat(this, ${seat.available})">
                            ${seat.seatNumber}
                        </div>
                    </c:forEach>
                </div>

                <%-- Summary panel --%>
                <div class="summary-panel">
                    <h3>Booking Summary</h3>
                    <div class="summary-row">
                        <span class="label">Lab</span>
                        <span class="value">${lab.labName}</span>
                    </div>
                    <div class="summary-row">
                        <span class="label">Seat</span>
                        <span class="value" id="summarySeat">None selected</span>
                    </div>
                    <div class="summary-row">
                        <span class="label">Date</span>
                        <span class="value" id="summaryDate">${today}</span>
                    </div>
                    <div class="summary-row">
                        <span class="label">Time</span>
                        <span class="value" id="summaryTime">08:00 &ndash; 10:00</span>
                    </div>
                </div>

                <button type="submit" class="book-btn" id="confirmBtn" disabled>
                    Confirm Booking
                </button>

            </form>

        </c:otherwise>
    </c:choose>

</div>

<script>
    const LAB_ID = '${lab.id}';
    const WS_URL = 'ws://' + location.host + '${pageContext.request.contextPath}/seats';

    // ── Seat selection ────────────────────────────────────────────
    function selectSeat(el, available) {
        if (!available) return;
        document.querySelectorAll('.seat.selected').forEach(s => s.classList.remove('selected'));
        el.classList.add('selected');
        document.getElementById('seatIdInput').value      = el.dataset.seatId;
        document.getElementById('summarySeat').textContent = el.dataset.seatNum;
        document.getElementById('confirmBtn').disabled     = false;
    }

    function validateForm() {
        if (!document.getElementById('seatIdInput').value) {
            alert('Please select a seat before confirming.');
            return false;
        }
        document.getElementById('confirmBtn').disabled    = true;
        document.getElementById('confirmBtn').textContent = 'Booking...';
        return true;
    }

    // ── Sync summary display ──────────────────────────────────────
    document.getElementById('bookingDate').addEventListener('change', function () {
        document.getElementById('summaryDate').textContent = this.value;
    });

    document.getElementById('startHour').addEventListener('change', function () {
        const h   = parseInt(this.value);
        const fmt = n => (n < 10 ? '0' : '') + n + ':00';
        document.getElementById('summaryTime').textContent = fmt(h) + ' \u2013 ' + fmt(h + 2);
    });

    // ── WebSocket: real-time seat availability ────────────────────
    (function connectWS() {
        const ws  = new WebSocket(WS_URL);
        const dot = document.getElementById('wsDot');
        const txt = document.getElementById('wsText');

        ws.onopen = () => {
            dot.classList.add('live');
            txt.textContent = 'Live seat updates active';
        };

        ws.onmessage = ({ data }) => {
            const msg = JSON.parse(data);
            if (String(msg.labId) !== LAB_ID) return;

            const el = document.getElementById('seat-' + msg.seatId);
            if (!el) return;

            el.classList.add('ws-flash');
            el.addEventListener('animationend', () => el.classList.remove('ws-flash'), { once: true });

            if (msg.available) {
                el.classList.remove('booked');
                el.classList.add('available');
                el.setAttribute('onclick', 'selectSeat(this, true)');
            } else {
                el.classList.remove('available');
                el.classList.add('booked');
                el.setAttribute('onclick', 'selectSeat(this, false)');

                // Deselect if our chosen seat was just taken by someone else
                if (el.dataset.seatId === document.getElementById('seatIdInput').value) {
                    el.classList.remove('selected');
                    document.getElementById('seatIdInput').value      = '';
                    document.getElementById('summarySeat').textContent = 'None \u2014 just taken by another user';
                    document.getElementById('confirmBtn').disabled     = true;
                }
            }
        };

        ws.onclose = () => {
            dot.classList.remove('live');
            txt.textContent = 'Reconnecting...';
            setTimeout(connectWS, 4000);
        };

        ws.onerror = () => ws.close();
    })();
</script>

</body>
</html>
