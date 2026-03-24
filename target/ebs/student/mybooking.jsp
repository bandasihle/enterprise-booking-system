<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EBS | My Bookings</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

<nav class="navbar">
    <div class="logo">
        <img src="${pageContext.request.contextPath}/images/logo.jpeg" class="logo-img" alt="EBS">
        <span>EBS</span>
    </div>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/student/booking">Book Seat</a>
        <a href="${pageContext.request.contextPath}/student/mybookings" class="active">My Bookings</a>
    </div>
</nav>

<div class="container">

    <h1 class="page-title">My Bookings</h1>

    <c:if test="${not empty flash}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> ${flash}
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <i class="fas fa-times-circle"></i> ${error}
        </div>
    </c:if>

    <c:if test="${loadError}">
        <div class="alert alert-danger">
            <i class="fas fa-wifi"></i> Could not load your bookings. Please refresh.
        </div>
    </c:if>

    <%-- Filter bar — JS shows/hides already-rendered rows, no server round-trip --%>
    <div class="filter-bar">
        <button class="filter-btn active" onclick="filterTable('ALL', this)">All</button>
        <button class="filter-btn" onclick="filterTable('CONFIRMED', this)">Confirmed</button>
        <button class="filter-btn" onclick="filterTable('COMPLETED', this)">Completed</button>
        <button class="filter-btn" onclick="filterTable('CANCELLED', this)">Cancelled</button>
        <button class="filter-btn" onclick="filterTable('NO_SHOW', this)">No Show</button>
    </div>

    <c:choose>
        <c:when test="${empty bookings}">
            <div class="empty-state">
                <i class="fas fa-calendar-times"></i>
                You have no bookings yet.
                <br>
                <a href="${pageContext.request.contextPath}/student/dashboard"
                   class="btn btn-primary" style="margin-top:1rem;display:inline-flex">
                    Browse Labs
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <table class="booking-table" id="bookingsTable">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Lab</th>
                        <th>Seat</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="b" items="${bookings}">
                        <tr data-status="${b.status}">
                            <td>${b.displayId}</td>
                            <td>
                                ${b.labName}
                                <span class="sub-text">${b.building}</span>
                            </td>
                            <td>${b.seatNumber}</td>
                            <td>${b.formattedDate}</td>
                            <td>${b.formattedTimeRange}</td>
                            <td>
                                <span class="status-badge status-${b.status}">${b.status}</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${b.status == 'CONFIRMED'}">
                                        <%--
                                          HTML forms only support GET/POST.
                                          We POST action=cancel to MyBookingsServlet.doPost().
                                          The confirm() dialog prevents accidental cancellations.
                                        --%>
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/student/mybookings"
                                              onsubmit="return confirm('Cancel this booking?');"
                                              style="margin:0">
                                            <input type="hidden" name="action"    value="cancel">
                                            <input type="hidden" name="bookingId" value="${b.id}">
                                            <button type="submit" class="cancel-btn">Cancel</button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="cancel-btn" disabled
                                                style="background:#E5E7EB;color:#9CA3AF;cursor:default">
                                            &mdash;
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div id="emptyFilter" class="empty-state" style="display:none">
                <i class="fas fa-filter"></i>
                No bookings match this filter.
            </div>

        </c:otherwise>
    </c:choose>

</div>

<script>
    function filterTable(status, btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        let shown = 0;
        document.querySelectorAll('#bookingsTable tbody tr').forEach(row => {
            const match = status === 'ALL' || row.dataset.status === status;
            row.style.display = match ? '' : 'none';
            if (match) shown++;
        });

        document.getElementById('emptyFilter').style.display = shown === 0 ? '' : 'none';
    }
</script>

</body>
</html>
