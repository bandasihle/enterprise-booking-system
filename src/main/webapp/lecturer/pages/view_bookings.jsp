<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Bookings – EBS</title>
  <link rel="stylesheet" href="../css/lecturer.css"/>
</head>
<body>

<nav class="top-navbar">
  <div style="display:flex;align-items:center;gap:28px;">
    <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
     
      <div class="nav-brand-text"><strong>EBS</strong><span> Lecturer</span></div>
    </a>
    <nav class="nav-menu">
      <a href="${pageContext.request.contextPath}/lecturer/dashboard" class="nav-item">Dashboard</a>
      <a href="${pageContext.request.contextPath}/lecturer/book-lab"  class="nav-item">Book Lab</a>
      <a href="${pageContext.request.contextPath}/lecturer/bookings"  class="nav-item active">My Bookings</a>
    </nav>
  </div>
  <div class="nav-right">
    <span class="user-chip">👨‍🏫 ${sessionScope.userName}</span>
    <a href="${pageContext.request.contextPath}/logout" class="logout-link">Logout</a>
  </div>
</nav>

<div class="main-content">

  <c:if test="${not empty flashMsg}">
    <div class="flash ${flashType}">${flashMsg}</div>
  </c:if>
  <c:if test="${not empty loadError}">
    <div class="flash error">${loadError}</div>
  </c:if>

  <div class="page-header">
    <div>
      <h1>My Bookings</h1>
      <p>All your lab reservations — past and upcoming</p>
    </div>
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="primary-btn">+ New Reservation</a>
  </div>

  <%-- Stats strip --%>
  <div class="stats-grid">
    <div class="stat-card">
      <h4>Total</h4>
      <div class="stat-number">${empty blocks ? 0 : fn:length(blocks)}</div>
      <div class="stat-label">All reservations</div>
    </div>
    <div class="stat-card">
      <h4>Confirmed</h4>
      <div class="stat-number" id="confirmedCount">—</div>
      <div class="stat-label">Active blocks</div>
    </div>
    <div class="stat-card">
      <h4>Cancelled</h4>
      <div class="stat-number" id="cancelledCount">—</div>
      <div class="stat-label">Removed</div>
    </div>
  </div>

  <div class="panel">
    <%-- Toolbar --%>
    <div class="bookings-toolbar">
      <input type="text" class="search-box" id="searchInput" placeholder="Search module, lab, building…">
      <select class="select" id="statusFilter">
        <option value="all">All Status</option>
        <option value="CONFIRMED">Confirmed</option>
        <option value="CANCELLED">Cancelled</option>
      </select>
    </div>

    <c:choose>
      <c:when test="${empty blocks}">
        <div class="table-empty-state">
          <div class="empty-icon">🗂️</div>
          <h3>No reservations yet</h3>
          <p>Create your first lab block — it will appear here.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="table-wrapper">
          <table id="bookingsTable">
<thead>
  <tr>
    <th>#</th>
    <th>Module</th>
    <th>Lab</th>
    <th>Date</th>
    <th>Time</th>
    <th>Status</th>
    <th>Actions</th> </tr>
</thead>
<tbody>
  <c:forEach var="block" items="${blocks}" varStatus="loop">
    <tr data-status="${block.status}">
      <td>${loop.count}</td>
      <td style="font-weight:700;">${block.moduleCode}</td>
      <td>${block.lab.labName}</td>
      <td>${fn:substring(block.startTime.toString(), 0, 10)}</td>
      <td>
        ${fn:substring(block.startTime.toString(), 11, 16)} – 
        ${fn:substring(block.endTime.toString(), 11, 16)}
      </td>
      <td>
        <span class="badge ${block.status == 'CONFIRMED' ? 'badge-green' : 'badge-red'}">
          ${block.status}
        </span>
      </td>
      <td>
        <c:if test="${block.status == 'CONFIRMED'}">
          <a href="${pageContext.request.contextPath}/lecturer/cancel-booking?id=${block.id}" 
             class="outline-btn" 
             style="color:red; border-color:red; padding:4px 8px;"
             onclick="return confirm('Are you sure you want to cancel this booking?')">
             Cancel
          </a>
        </c:if>
      </td>
    </tr>
  </c:forEach>
</tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</div>

<script>
  const rows = document.querySelectorAll('#bookingsTable tbody tr');

  function filterAndCount() {
    const term   = document.getElementById('searchInput').value.toLowerCase();
    const status = document.getElementById('statusFilter').value;
    let confirmed = 0, cancelled = 0;

    rows.forEach(function (row) {
      const match = row.textContent.toLowerCase().includes(term) &&
                    (status === 'all' || row.dataset.status === status);
      row.style.display = match ? '' : 'none';
      if (match) {
        if (row.dataset.status === 'CONFIRMED') confirmed++;
        if (row.dataset.status === 'CANCELLED') cancelled++;
      }
    });

    document.getElementById('confirmedCount').textContent = confirmed;
    document.getElementById('cancelledCount').textContent = cancelled;
  }

  filterAndCount(); // set counts on page load
  document.getElementById('searchInput').addEventListener('input',  filterAndCount);
  document.getElementById('statusFilter').addEventListener('change', filterAndCount);
</script>

</body>
</html>
