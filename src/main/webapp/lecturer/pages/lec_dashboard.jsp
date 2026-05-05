<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Lecturer Dashboard – EBS</title>
  <%-- This file lives at: src/main/webapp/lecturer/pages/lec_dashboard.jsp --%>
  <%-- CSS at:             src/main/webapp/lecturer/css/lecturer.css        --%>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/lecturer/css/lecturer.css">
</head>
<body>

<%-- ── NAVBAR ─────────────────────────────────────────────── --%>
<nav class="top-navbar">
  <div style="display:flex;align-items:center;gap:28px;">
    <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
      
      <div class="nav-brand-text">
        <strong>EBS</strong><span> Lecturer</span>
      </div>
    </a>
    <nav class="nav-menu">
      <a href="${pageContext.request.contextPath}/lecturer/dashboard">Dashboard</a>
      <a href="${pageContext.request.contextPath}/lecturer/book-lab">Book Lab</a>
      <a href="${pageContext.request.contextPath}/lecturer/bookings">My Bookings</a>

      <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="primary-btn">
        + New Reservation
      </a>

      <a href="${pageContext.request.contextPath}/lecturer/book-lab?labId=${lab.id}" class="btn-main">
        Book Lab
      </a>
    </nav>
  </div>
  <div class="nav-right">
    <span class="user-chip">👨‍🏫 ${sessionScope.userName}</span>
    <a href="${pageContext.request.contextPath}/logout" class="logout-link">Logout</a>
  </div>
</nav>

<%-- ── MAIN ──────────────────────────────────────────────── --%>
<div class="main-content">

  <%-- Flash --%>
  <c:if test="${not empty flashMsg}">
    <div class="flash ${flashType}">${flashMsg}</div>
  </c:if>
  <c:if test="${not empty loadError}">
    <div class="flash error">${loadError}</div>
  </c:if>

  <%-- Header --%>
  <div class="page-header">
    <div>
      <h1>Lecturer Dashboard</h1>
      <p>Manage lab reservations and view upcoming blocks</p>
    </div>
    <%--
      PRIMARY ACTION — links to /lecturer/book-lab (GET)
      LecturerServlet.doGet loads labs from DB and forwards to book_lab.jsp
    --%>
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="primary-btn">
      + New Reservation
    </a>
  </div>

  <%-- Stats --%>
  <div class="stats-grid">
    <div class="stat-card">
      <h4>Upcoming Blocks</h4>
      <div class="stat-number">${empty blocks ? 0 : fn:length(blocks)}</div>
      <div class="stat-label">Confirmed reservations</div>
    </div>
    <div class="stat-card">
      <h4>Available Labs</h4>
      <div class="stat-number">${empty labs ? 0 : fn:length(labs)}</div>
      <div class="stat-label">Ready to reserve</div>
    </div>
  </div>

  <%-- Toolbar --%>
  <div class="section-title">Available Venues</div>
  <div class="toolbar">
    <input type="text" class="search-box" id="labSearch" placeholder="Search by name or building…">
    <div class="filter-chips">
      <button class="chip active" data-filter="all">All</button>
      <button class="chip" data-filter="computer">Computer Labs</button>
      <button class="chip" data-filter="seminar">Seminar Rooms</button>
    </div>
  </div>

  <%-- Lab Grid --%>
  <div class="lab-grid" id="labGrid">
    <c:choose>
      <c:when test="${empty labs}">
        <div class="empty-state">
          <div class="empty-icon">🏫</div>
          <h3>No labs available</h3>
          <p>Contact your administrator to add venues.</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="lab" items="${labs}">
          <%-- Determine card type for filter chips --%>
          <c:set var="isComputer" value="${fn:containsIgnoreCase(lab.labName,'Lab') or fn:containsIgnoreCase(lab.labName,'LG')}"/>
          <c:set var="cardType"   value="${isComputer ? 'computer' : 'seminar'}"/>

          <div class="lab-card" data-category="${cardType}"
               data-search="${fn:toLowerCase(lab.labName)} ${fn:toLowerCase(lab.building)}">

            <c:choose>
              <c:when test="${isComputer}">
                <img src="../images/lab.jpg" alt="${lab.labName}" class="lab-image"
                     onerror="this.src='../images/logooo.jpeg'"/>
              </c:when>
              <c:otherwise>
                <img src="../images/LectureHall.jpg" alt="${lab.labName}" class="lab-image"
                     onerror="this.src='../images/logooo.jpeg'"/>
              </c:otherwise>
            </c:choose>

            <div class="lab-body">
              <span class="lab-tag ${isComputer ? 'tag-blue' : 'tag-green'}">
                ${isComputer ? '💻 COMPUTER LAB' : '🏛️ SEMINAR ROOM'}
              </span>
              <div class="lab-title">${lab.labName}</div>
              <div class="lab-meta">${lab.building} &bull; Capacity: ${lab.capacity}</div>
              <div class="lab-status">Available for reservation</div>

              <div class="card-actions">
                <%--
                  "Book Lab" and "Block Venue" both go to the SAME endpoint:
                  GET /lecturer/book-lab?labId={id}
                  LecturerServlet loads the form with that lab pre-selected.
                  The POST in book_lab.jsp actually creates the reservation.
                --%>
                <a href="${pageContext.request.contextPath}/lecturer/book-lab?labId=${lab.id}"
                   class="primary-btn">
                  ${isComputer ? 'Book Lab' : 'Block Venue'}
                </a>
                <a href="${pageContext.request.contextPath}/lecturer/bookings"
                   class="outline-btn">
                  View Bookings
                </a>
              </div>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>

  <%-- Upcoming Blocks Table --%>
  <div class="panel">
    <div class="panel-head">
      <h2>Upcoming Reservations</h2>
      <a href="${pageContext.request.contextPath}/lecturer/bookings" class="outline-btn" style="padding:8px 16px;font-size:13px;">
        View All →
      </a>
    </div>

    <c:choose>
      <c:when test="${empty blocks}">
        <div class="table-empty-state">
          <div class="empty-icon">🗂️</div>
          <h3>No upcoming reservations</h3>
          <p>Use the <strong>+ New Reservation</strong> button above to book a lab.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Module</th>
                <th>Lab</th>
                <th>Building</th>
                <th>Date</th>
                <th>Time</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="block" items="${blocks}">
                <tr>
                  <td style="font-weight:700;">${block.moduleCode}</td>
                  <td>${block.lab.labName}</td>
                  <td>${block.lab.building}</td>
                  <td>${fn:substring(block.startTime.toString(), 0, 10)}</td>
                  <td>
                    ${fn:substring(block.startTime.toString(), 11, 16)} –
                    ${fn:substring(block.endTime.toString(),   11, 16)}
                  </td>
                  <td><span class="badge badge-green">${block.status}</span></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</div><%-- /main-content --%>

<script>
  // ── Lab search ───────────────────────────────────────────
  document.getElementById('labSearch').addEventListener('input', function () {
    const term = this.value.toLowerCase();
    filterCards(term, document.querySelector('.chip.active').dataset.filter);
  });

  // ── Filter chips ─────────────────────────────────────────
  document.querySelectorAll('.chip').forEach(function (chip) {
    chip.addEventListener('click', function () {
      document.querySelectorAll('.chip').forEach(function (c) { c.classList.remove('active'); });
      this.classList.add('active');
      filterCards(document.getElementById('labSearch').value.toLowerCase(), this.dataset.filter);
    });
  });

  function filterCards(term, category) {
    document.querySelectorAll('.lab-card').forEach(function (card) {
      const matchSearch   = !term || card.dataset.search.includes(term);
      const matchCategory = category === 'all' || card.dataset.category === category;
      card.style.display = (matchSearch && matchCategory) ? '' : 'none';
    });
  }
</script>

</body>
</html>
