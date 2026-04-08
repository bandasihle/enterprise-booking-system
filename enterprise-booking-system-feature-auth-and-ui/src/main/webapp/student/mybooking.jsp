<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EBS | My Bookings</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            background: #f8fafc; 
            color: #1e293b; 
            font-family: 'Segoe UI', Arial, sans-serif; 
            min-height: 100vh; 
        }

        /* Navbar */
        .navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            box-shadow: 0 1px 8px rgba(0,0,0,0.06);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 28px;
            height: 60px;
        }
        
        .navbar .logo { 
            display: flex; 
            align-items: center; 
            gap: 10px; 
            text-decoration: none; 
        }
        
        .navbar .logo img { 
            width: 32px; 
            height: 32px; 
            border-radius: 8px; 
            object-fit: cover; 
        }
        
        .navbar .logo span { 
            color: #1e293b; 
            font-weight: 700; 
            font-size: 18px; 
        }
        
        .navbar .nav-links { 
            display: flex; 
            align-items: center; 
            gap: 4px; 
        }
        
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

        /* Container */
        .container { 
            max-width: 1100px; 
            margin: 0 auto; 
            padding: 32px 24px; 
        }

        .page-title { 
            font-size: 26px; 
            font-weight: 700; 
            color: #1e293b; 
            margin-bottom: 6px; 
        }
        
        .page-sub { 
            font-size: 14px; 
            color: #64748b; 
            margin-bottom: 24px; 
        }

        /* Tabs */
        .tabs {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 0;
        }
        
        .tab {
            padding: 12px 20px;
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            font-size: 14px;
            font-weight: 600;
            color: #64748b;
            cursor: pointer;
            transition: all 0.15s;
            margin-bottom: -1px;
        }
        
        .tab:hover {
            color: #2563eb;
        }
        
        .tab.active {
            color: #2563eb;
            border-bottom-color: #2563eb;
        }

        /* Booking Cards */
        .bookings-grid {
            display: grid;
            gap: 16px;
        }

        .booking-card {
            background: #fff;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            padding: 20px 24px;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: transform 0.15s, box-shadow 0.15s;
        }
        
        .booking-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
        }

        .booking-icon {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            flex-shrink: 0;
        }
        
        .booking-icon.pc {
            background: #dbeafe;
            color: #1d4ed8;
        }
        
        .booking-icon.venue {
            background: #dcfce7;
            color: #15803d;
        }

        .booking-details {
            flex: 1;
        }
        
        .booking-title {
            font-size: 16px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 4px;
        }
        
        .booking-meta {
            font-size: 13px;
            color: #64748b;
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }
        
        .booking-meta span {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .booking-status {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }
        
        .status-upcoming {
            background: #dbeafe;
            color: #1d4ed8;
        }
        
        .status-active {
            background: #dcfce7;
            color: #15803d;
        }
        
        .status-completed {
            background: #f1f5f9;
            color: #64748b;
        }
        
        .status-cancelled {
            background: #fef2f2;
            color: #dc2626;
        }

        .booking-actions {
            display: flex;
            gap: 8px;
        }
        
        .btn-action {
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.15s;
            border: none;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        
        .btn-cancel {
            background: #fef2f2;
            color: #dc2626;
        }
        
        .btn-cancel:hover {
            background: #fee2e2;
        }
        
        .btn-view {
            background: #f1f5f9;
            color: #475569;
        }
        
        .btn-view:hover {
            background: #e2e8f0;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
        }
        
        .empty-state i {
            font-size: 64px;
            margin-bottom: 16px;
            display: block;
            color: #cbd5e1;
        }
        
        .empty-state h3 {
            font-size: 18px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 8px;
        }
        
        .empty-state p {
            font-size: 14px;
            margin-bottom: 20px;
        }
        
        .btn-primary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background: #2563eb;
            color: #fff;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: background 0.15s;
        }
        
        .btn-primary:hover {
            background: #1d4ed8;
        }

        /* Alert Messages */
        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
        }
        
        .alert-success {
            background: #f0fdf4;
            color: #15803d;
            border: 1px solid #86efac;
        }
        
        .alert-error {
            background: #fef2f2;
            color: #dc2626;
            border: 1px solid #fca5a5;
        }

        @media (max-width: 768px) {
            .booking-card {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .booking-actions {
                width: 100%;
                justify-content: flex-end;
            }
        }
    </style>
</head>
<body>

<!-- NAV -->
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/index.jsp" style="text-decoration: none; color: inherit;">
        <div class="logo">
            <img src="${pageContext.request.contextPath}/images/logo.jpeg" class="logo-img" alt="EBS">
            <span>EBS</span>
        </div>
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/dashboard.jsp">Dashboard</a>
        <a href="${pageContext.request.contextPath}/student/ict-lab-seats.jsp">Book PC</a>
        <a href="${pageContext.request.contextPath}/student/mybooking.jsp" class="active">My Bookings</a>
    </div>
</nav>

<div class="container">

    <h1 class="page-title">My Bookings</h1>
    <p class="page-sub">View and manage your lab and venue bookings.</p>

    <div id="bookingList"></div>
    <!-- Success/Error Messages -->
    <c:if test="${not empty param.success}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            ${param.success}
        </div>
    </c:if>
    
    <c:if test="${not empty param.error}">
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i>
            ${param.error}
        </div>
    </c:if>

    <!-- Tabs -->
    <div class="tabs">
        <button class="tab active" onclick="showTab('upcoming')">Upcoming</button>
        <button class="tab" onclick="showTab('past')">Past</button>
        <button class="tab" onclick="showTab('cancelled')">Cancelled</button>
    </div>

    <!-- Upcoming Bookings -->
    <div id="upcoming" class="bookings-grid">
        <c:choose>
            <c:when test="${empty upcomingBookings}">
                <div class="empty-state">
                    <i class="fas fa-calendar-plus"></i>
                    <h3>No upcoming bookings</h3>
                    <p>You don't have any upcoming lab or venue reservations.</p>
                    <a href="${pageContext.request.contextPath}/student/dashboard.jsp" class="btn-primary">
                        <i class="fas fa-plus"></i> Make a Booking
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="booking" items="${upcomingBookings}">
                    <div class="booking-card">
                        <div class="booking-icon ${booking.type == 'PC' ? 'pc' : 'venue'}">
                            <i class="fas ${booking.type == 'PC' ? 'fa-desktop' : 'fa-building'}"></i>
                        </div>
                        <div class="booking-details">
                            <div class="booking-title">
                                ${booking.type == 'PC' ? booking.seatLabel : booking.venueName}
                                <c:if test="${booking.type == 'PC'}">
                                    <span style="color: #64748b; font-weight: 500;">— ${booking.labName}</span>
                                </c:if>
                            </div>
                            <div class="booking-meta">
                                <span><i class="fas fa-calendar"></i> ${booking.bookingDate}</span>
                                <span><i class="fas fa-clock"></i> ${booking.timeLabel}</span>
                                <c:if test="${booking.type == 'PC'}">
                                    <span><i class="fas fa-desktop"></i> ${booking.seatLabel}</span>
                                </c:if>
                            </div>
                        </div>
                        <span class="booking-status status-upcoming">Upcoming</span>
                        <div class="booking-actions">
                            <a href="${pageContext.request.contextPath}/student/booking?id=${booking.id}" class="btn-action btn-view">
                                <i class="fas fa-eye"></i> View
                            </a>
                            <form method="POST" action="${pageContext.request.contextPath}/student/booking" style="display: inline;">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="bookingId" value="${booking.id}">
                                <button type="submit" class="btn-action btn-cancel" onclick="return confirm('Cancel this booking?')">
                                    <i class="fas fa-times"></i> Cancel
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Past Bookings (Hidden by default) -->
    <div id="past" class="bookings-grid" style="display: none;">
        <c:choose>
            <c:when test="${empty pastBookings}">
                <div class="empty-state">
                    <i class="fas fa-history"></i>
                    <h3>No past bookings</h3>
                    <p>You haven't completed any bookings yet.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="booking" items="${pastBookings}">
                    <div class="booking-card">
                        <div class="booking-icon ${booking.type == 'PC' ? 'pc' : 'venue'}">
                            <i class="fas ${booking.type == 'PC' ? 'fa-desktop' : 'fa-building'}"></i>
                        </div>
                        <div class="booking-details">
                            <div class="booking-title">
                                ${booking.type == 'PC' ? booking.seatLabel : booking.venueName}
                                <c:if test="${booking.type == 'PC'}">
                                    <span style="color: #64748b; font-weight: 500;">— ${booking.labName}</span>
                                </c:if>
                            </div>
                            <div class="booking-meta">
                                <span><i class="fas fa-calendar"></i> ${booking.bookingDate}</span>
                                <span><i class="fas fa-clock"></i> ${booking.timeLabel}</span>
                            </div>
                        </div>
                        <span class="booking-status status-completed">Completed</span>
                        <div class="booking-actions">
                            <a href="${pageContext.request.contextPath}/student/booking?id=${booking.id}" class="btn-action btn-view">
                                <i class="fas fa-eye"></i> View
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Cancelled Bookings (Hidden by default) -->
    <div id="cancelled" class="bookings-grid" style="display: none;">
        <c:choose>
            <c:when test="${empty cancelledBookings}">
                <div class="empty-state">
                    <i class="fas fa-ban"></i>
                    <h3>No cancelled bookings</h3>
                    <p>You don't have any cancelled reservations.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="booking" items="${cancelledBookings}">
                    <div class="booking-card" style="opacity: 0.7;">
                        <div class="booking-icon ${booking.type == 'PC' ? 'pc' : 'venue'}">
                            <i class="fas ${booking.type == 'PC' ? 'fa-desktop' : 'fa-building'}"></i>
                        </div>
                        <div class="booking-details">
                            <div class="booking-title">
                                ${booking.type == 'PC' ? booking.seatLabel : booking.venueName}
                                <c:if test="${booking.type == 'PC'}">
                                    <span style="color: #64748b; font-weight: 500;">— ${booking.labName}</span>
                                </c:if>
                            </div>
                            <div class="booking-meta">
                                <span><i class="fas fa-calendar"></i> ${booking.bookingDate}</span>
                                <span><i class="fas fa-clock"></i> ${booking.timeLabel}</span>
                            </div>
                        </div>
                        <span class="booking-status status-cancelled">Cancelled</span>
                        <div class="booking-actions">
                            <a href="${pageContext.request.contextPath}/student/booking?id=${booking.id}" class="btn-action btn-view">
                                <i class="fas fa-eye"></i> View
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<script>
    function showTab(tabName) {
        // Hide all grids
        document.getElementById('upcoming').style.display = 'none';
        document.getElementById('past').style.display = 'none';
        document.getElementById('cancelled').style.display = 'none';
        
        // Remove active from all tabs
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        
        // Show selected and activate tab
        document.getElementById(tabName).style.display = 'grid';
        event.target.classList.add('active');
    }
    
   
(function () {
    const STORAGE_KEY = 'ebs_student_bookings';

    document.addEventListener('DOMContentLoaded', function () {
        renderBookings();
    });

    function getBookings() {
        try {
            return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
        } catch (e) {
            return [];
        }
    }

    function renderBookings() {
        const bookings = getBookings().sort((a, b) => {
            return new Date(b.createdAt) - new Date(a.createdAt);
        });

        const container =
            document.getElementById('bookingList') ||
            document.getElementById('myBookingsContainer') ||
            document.getElementById('bookingsTableBody');

        if (!container) return;

        if (container.tagName && container.tagName.toLowerCase() === 'tbody') {
            container.innerHTML = '';
            if (!bookings.length) {
                container.innerHTML = `
                    <tr>
                        <td colspan="5" style="text-align:center;padding:20px;color:#64748b;">
                            No bookings yet.
                        </td>
                    </tr>
                `;
                return;
            }

            bookings.forEach(b => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${b.labName}</td>
                    <td>${b.seatLabel}</td>
                    <td>${b.date}</td>
                    <td>${b.slotLabel}</td>
                    <td>${b.status}</td>
                `;
                container.appendChild(tr);
            });
            return;
        }

        container.innerHTML = '';
        if (!bookings.length) {
            container.innerHTML = `
                <div style="padding:20px;color:#64748b;text-align:center;">
                    No bookings yet.
                </div>
            `;
            return;
        }

        bookings.forEach(b => {
            const card = document.createElement('div');
            card.style.cssText = `
                background:#fff;
                border:1px solid #e2e8f0;
                border-radius:14px;
                padding:16px;
                margin-bottom:12px;
                box-shadow:0 2px 8px rgba(0,0,0,0.05);
            `;
            card.innerHTML = `
                <div style="font-weight:700;color:#1e293b;margin-bottom:8px;">${b.labName}</div>
                <div style="font-size:14px;color:#475569;line-height:1.7;">
                    <div><strong>PC:</strong> ${b.seatLabel}</div>
                    <div><strong>Date:</strong> ${b.date}</div>
                    <div><strong>Time Slot:</strong> ${b.slotLabel}</div>
                    <div><strong>Status:</strong> ${b.status}</div>
                </div>
            `;
            container.appendChild(card);
        });
    }
})();
</script>

</body>
</html>