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
    <a href="${pageContext.request.contextPath}/test-index.html" class="nav-brand">
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

  <div class="page-header">
    <div>
      <h1>My Bookings</h1>
      <p>All your lab reservations — past and upcoming</p>
    </div>
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="primary-btn">+ New Reservation</a>
  </div>

  <div class="stats-grid">
    <div class="stat-card">
      <h4>Total</h4>
      <div class="stat-number">${empty blocks ? 0 : fn:length(blocks)}</div>
    </div>
    <div class="stat-card">
      <h4>Confirmed</h4>
      <div class="stat-number" id="confirmedCount">—</div>
    </div>
    <div class="stat-card">
      <h4>Cancelled</h4>
      <div class="stat-number" id="cancelledCount">—</div>
    </div>
  </div>

  <!-- CANCEL CONFIRMATION BANNER -->
  <div id="cancelModal" style="display:none; width:100%; margin-bottom:20px;">
    <div style="
      background:#ffffff;
      border:1.5px solid #fca5a5;
      border-left:5px solid #dc2626;
      border-radius:16px;
      padding:20px 28px;
      box-shadow:0 8px 32px rgba(220,38,38,0.10), 0 2px 8px rgba(15,23,42,0.06);
      display:flex;
      align-items:center;
      gap:20px;
      flex-wrap:wrap;
    ">
      <!-- Icon -->
      <div style="
        flex-shrink:0;
        width:48px; height:48px;
        background:#fee2e2;
        border-radius:50%;
        display:flex; align-items:center; justify-content:center;
        color:#dc2626;
      ">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </div>
      <!-- Text -->
      <div style="flex:1; min-width:180px;">
        <div style="font-size:15px; font-weight:800; color:#dc2626; margin-bottom:3px;">Cancel Booking</div>
        <div style="font-size:13px; color:#64748b; margin:0;">This action cannot be undone. Are you sure you want to cancel this reservation?</div>
      </div>
      <!-- Buttons -->
      <div style="display:flex; align-items:center; gap:10px; flex-shrink:0;">
        <button id="closeModal" style="
          background:#ffffff;
          color:#64748b;
          border:1.5px solid #e2e8f0;
          border-radius:999px;
          padding:8px 20px;
          font-size:13px; font-weight:700;
          cursor:pointer;
          font-family:inherit;
        ">Keep Booking</button>
        <button id="confirmCancel" style="
          background:#dc2626;
          color:#ffffff;
          border:none;
          border-radius:999px;
          padding:9px 20px;
          font-size:13px; font-weight:700;
          cursor:pointer;
          font-family:inherit;
        ">Yes, Cancel It</button>
      </div>
    </div>
  </div>

  <div class="panel">
    <div class="bookings-toolbar">
      <input type="text" class="search-box" id="searchInput" placeholder="Search...">
      <select class="select" id="statusFilter">
        <option value="all">All Status</option>
        <option value="CONFIRMED">Confirmed</option>
        <option value="CANCELLED">Cancelled</option>
      </select>
    </div>

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
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="block" items="${blocks}" varStatus="loop">
            <tr data-status="${block.status}">
              <td>${loop.count}</td>
              <td><b>${block.moduleCode}</b></td>
              <td>${block.lab.labName}</td>
              <td>${fn:substring(block.startTime.toString(), 0, 10)}</td>
              <td>${fn:substring(block.startTime.toString(), 11, 16)} – ${fn:substring(block.endTime.toString(), 11, 16)}</td>
              <td>
                <span class="badge ${block.status == 'CONFIRMED' ? 'badge-green' : 'badge-red'}">
                  ${block.status}
                </span>
              </td>
              <td>
                <c:if test="${block.status == 'CONFIRMED'}">
                  <button class="cancel-row-btn" data-id="${block.id}" style="
                    display:inline-block;
                    background:#fee2e2;
                    color:#dc2626;
                    border:1.5px solid #dc2626;
                    border-radius:999px;
                    padding:6px 11px;
                    font-size:13px;
                    font-weight:700;
                    cursor:pointer;
                    font-family:inherit;
                    white-space:nowrap;
                  " onmouseover="this.style.background='#dc2626';this.style.color='#fff';"
                     onmouseout="this.style.background='#fee2e2';this.style.color='#dc2626';">Cancel</button>
                </c:if>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

</div>

<script>
document.addEventListener("DOMContentLoaded", function () {

  let selectedId = null;
  const modal = document.getElementById('cancelModal');

  // Open modal
  document.querySelectorAll('.cancel-row-btn').forEach(btn => {
    btn.addEventListener('click', function () {
      selectedId = this.dataset.id;
      modal.style.display = 'block';
      modal.setAttribute('aria-hidden', 'false');
    });
  });

  // Close modal
  function closeModal() {
    modal.style.display = 'none';
    modal.setAttribute('aria-hidden', 'true');
    selectedId = null;
  }

  document.getElementById('closeModal').addEventListener('click', closeModal);

  // Close on backdrop click
  modal.addEventListener('click', function(e) {
    if (e.target === modal) closeModal();
  });

  // Close on Escape key
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeModal();
  });

  // Confirm cancel
  document.getElementById('confirmCancel').addEventListener('click', function () {
    if (selectedId) {
      window.location.href = '/EnterpriseBookingSystem/lecturer/cancel-booking?id=' + selectedId;
    }
  });

  // Filter + count
  const rows = document.querySelectorAll('#bookingsTable tbody tr');

  function filterAndCount() {
    const term = document.getElementById('searchInput').value.toLowerCase();
    const status = document.getElementById('statusFilter').value;
    let confirmed = 0, cancelled = 0;

    rows.forEach(row => {
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

  filterAndCount();
  document.getElementById('searchInput').addEventListener('input', filterAndCount);
  document.getElementById('statusFilter').addEventListener('change', filterAndCount);

});
</script>

</body>
</html>