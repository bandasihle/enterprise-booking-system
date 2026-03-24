<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EBS | Student Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

<nav class="navbar">
    <div class="logo">
        <img src="${pageContext.request.contextPath}/images/logo.jpeg" class="logo-img" alt="EBS">
        <span>EBS</span>
    </div>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/dashboard.jsp" class="active">Dashboard</a>
        <a href="${pageContext.request.contextPath}/student/booking.jsp">Book Seat</a>
        <a href="${pageContext.request.contextPath}/student/mybooking.jsp">My Bookings</a>
    </div>
</nav>

<div class="container">

    <h1 class="page-title">Student Dashboard</h1>

    <%-- Flash message after a successful booking redirect --%>
    <c:if test="${not empty flash}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> ${flash}
        </div>
    </c:if>

    <%-- Profile bar --%>
    <c:if test="${not empty profile}">
        <div class="profile-bar">
            <div>
                <div class="name">${profile.fullName}</div>
                <div class="meta">${profile.studentNumber}&nbsp;&middot;&nbsp;${profile.course}</div>
            </div>
            <c:if test="${profile.cancellationCount > 0}">
                <span class="badge">
                    ${profile.cancellationCount}
                    cancellation<c:if test="${profile.cancellationCount > 1}">s</c:if>
                </span>
            </c:if>
        </div>

        <%-- Ban / warning banners --%>
        <c:choose>
            <c:when test="${profile.banned}">
                <div class="alert alert-danger">
                    <i class="fas fa-ban"></i>
                    <strong>Account banned.</strong>
                    Your account is suspended due to excessive cancellations.
                    New bookings are blocked until the ban expires.
                </div>
            </c:when>
            <c:when test="${profile.atRiskOfBan}">
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    <strong>Warning:</strong> You have ${profile.cancellationCount} cancellation(s).
                    One more will result in a 24-hour booking ban.
                </div>
            </c:when>
        </c:choose>
    </c:if>

    <c:if test="${loadError}">
        <div class="alert alert-danger">
            <i class="fas fa-wifi"></i> Could not load data. Please refresh.
        </div>
    </c:if>

    <%-- Search — filters already-rendered cards on the client, no server round-trip --%>
    <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" id="searchInput" placeholder="Search by name or building...">
    </div>

    <h2 style="margin-bottom:1rem">
        All Labs &amp; Venues
        <c:if test="${not empty labs}">
            <span style="font-size:0.9rem;font-weight:400;color:#6B7280">(${labs.size()})</span>
        </c:if>
    </h2>

    <c:choose>
        <c:when test="${empty labs}">
            <div class="empty-state">
                <i class="fas fa-building"></i>
                No venues available at the moment.
            </div>
        </c:when>
        <c:otherwise>
            <div class="lab-list" id="labList">
                <c:forEach var="lab" items="${labs}">

                    <%-- Pick image by building type --%>
                    <c:set var="img" value="${pageContext.request.contextPath}/images/lab.jpg"/>
                    <c:if test="${fn:containsIgnoreCase(lab.building, 'auditorium')}">
                        <c:set var="img" value="${pageContext.request.contextPath}/images/Auditorium.jpg"/>
                    </c:if>
                    <c:if test="${fn:containsIgnoreCase(lab.building, 'lecture')}">
                        <c:set var="img" value="${pageContext.request.contextPath}/images/LectureHall.jpg"/>
                    </c:if>

                    <div class="venue-card"
                         data-search="${fn:toLowerCase(lab.labName)} ${fn:toLowerCase(lab.building)}">
                        <img src="${img}" class="venue-image" alt="${lab.labName}">
                        <div class="venue-content">
                            <h3 class="venue-name">${lab.labName}</h3>
                            <p><i class="fas fa-building"></i> ${lab.building}</p>
                            <p>
                                <i class="fas fa-desktop"></i>
                                <span class="available-seats">${lab.availableSeats}</span>
                                &nbsp;/&nbsp;${lab.capacity} seats available
                            </p>
                            <a href="${pageContext.request.contextPath}/student/booking?labId=${lab.id}"
                               class="btn btn-primary" style="margin-top:0.6rem;display:inline-flex">
                                Book a Seat <i class="fas fa-arrow-right" style="margin-left:0.4rem"></i>
                            </a>
                        </div>
                    </div>

                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<script>
    document.getElementById('searchInput').addEventListener('input', function () {
        const q = this.value.toLowerCase().trim();
        document.querySelectorAll('#labList .venue-card').forEach(card => {
            card.style.display = (!q || card.dataset.search.includes(q)) ? '' : 'none';
        });
    });
</script>

</body>
</html>
