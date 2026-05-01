<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Bookings – EBS</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/lecturer/css/lecturer.css"/>
  <style>
    :root { --primary-green: #065f46; --red-accent: #dc2626; }
    
    .top-navbar { display: flex; justify-content: space-between; align-items: center; padding: 0.75rem 2rem; background: var(--primary-green); }
    .nav-menu { display: flex; gap: 8px; flex: 2; justify-content: center; }
    .nav-menu .nav-item { background: transparent; color: rgba(255, 255, 255, 0.8); padding: 8px 16px; border-radius: 8px; text-decoration: none; transition: 0.2s; }
    .nav-menu .nav-item.active { background: rgba(255, 255, 255, 0.15); color: #fff; }

    .stat-card { background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 4px 20px rgba(0,0,0,0.04); text-align: center; border: 1px solid #f1f5f9; }
    .stat-number { font-size: 2rem; font-weight: 800; color: var(--primary-green); }
    
    .badge { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
    .badge-green { background: #ecfdf5; color: #059669; }
    .badge-red { background: #fef2f2; color: #dc2626; }

    .cancel-btn { background: #fef2f2; color: #dc2626; border: 1px solid #fee2e2; border-radius: 8px; padding: 6px 14px; cursor: pointer; transition: 0.2s; font-weight: 600; }
    .cancel-btn:hover { background: #dc2626; color: #fff; }

    #cancelModal { position: fixed; top: 20px; left: 50%; transform: translateX(-50%); z-index: 1000; width: 90%; max-width: 500px; }
  </style>
</head>
<body>

<nav class="top-navbar">
  <div class="nav-left">
    <a href="${pageContext.request.contextPath}/test-index.html" class="nav-brand" style="text-decoration:none; color:white;">
      <strong>EBS</strong><span style="opacity: 0.8;"> Lecturer</span>
    </a>
  </div>
  <div class="nav-menu">
    <a href="${pageContext.request.contextPath}/lecturer/dashboard" class="nav-item">Dashboard</a>
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="nav-item">Book Lab</a>
    <a href="${pageContext.request.contextPath}/lecturer/bookings" class="nav-item active">My Bookings</a>
  </div>
  <div class="nav-right">
    <span style="color:white; font-size: 0.85rem;">👨‍🏫 ${sessionScope.userName}</span>
  </div>
</nav>

<div class="main-content" style="margin: 40px auto; max-width: 1100px;">
  <div class="page-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 30px;">
    <div>
      <h1>My Bookings</h1>
      <p style="color: #64748b;">Manage your past and upcoming reservations</p>
    </div>
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="primary-btn" style="background:var(--primary-green); border-radius:10px;">+ New Reservation</a>
  </div>

  <div class="stats-grid" style="display:grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 40px;">
    <div class="stat-card">
      <div style="font-size: 0.8rem; color: #64748b; text-transform:uppercase;">Total</div>
      <div class="stat-number">${empty blocks ? 0 : fn:length(blocks)}</div>
    </div>
    <div class="stat-card">
      <div style="font-size: 0.8rem; color: #64748b; text-transform:uppercase;">Confirmed</div>
      <div class="stat-number" id="confirmedCount" style="color: #059669;">—</div>
    </div>
    <div class="stat-card">
      <div style="font-size: 0.8rem; color: #64748b; text-transform:uppercase;">Cancelled</div>
      <div class="stat-number" id="cancelledCount" style="color: #dc2626;">—</div>
    </div>
  </div>

  <!-- INLINE CANCEL ALERT -->
  <div id="cancelModal" style="display:none;">
    <div style="background:#fff; border-radius:16px; padding:20px; box-shadow: 0 20px 50px rgba(0,0,0,0.15); border-top: 4px solid var(--red-accent);">
      <h4 style="margin:0; color: var(--red-accent);">Confirm Cancellation</h4>
      <p style="font-size: 0.9rem; color: #64748b;">Are you sure? This cannot be undone.</p>
      <div style="display:flex; gap:10px; margin-top: 15px;">
        <button id="confirmCancel" class="primary-btn" style="background:var(--red-accent); flex:1;">Yes, Cancel</button>
        <button id="closeModal" class="outline-btn" style="flex:1;">Keep it</button>
      </div>
    </div>
  </div>

  <div class="panel">
    <div class="table-wrapper">
      <table>
        <thead>
          <tr>
            <th>Module</th>
            <th>Lab</th>
            <th>Date</th>
            <th>Time</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="block" items="${blocks}">
            <tr data-status="${block.status}">
              <td><strong>${block.moduleCode}</strong></td>
              <td>${block.lab.labName}</td>
              <td>${fn:substring(block.startTime.toString(), 0, 10)}</td>
              <td>${fn:substring(block.startTime.toString(), 11, 16)} – ${fn:substring(block.endTime.toString(), 11, 16)}</td>
              <td><span class="badge ${block.status == 'CONFIRMED' ? 'badge-green' : 'badge-red'}">${block.status}</span></td>
              <td>
                <c:if test="${block.status == 'CONFIRMED'}">
                  <button class="cancel-btn" data-id="${block.id}">Cancel</button>
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

    document.querySelectorAll('.cancel-btn').forEach(btn => {
      btn.addEventListener('click', function() {
        selectedId = this.dataset.id;
        modal.style.display = 'block';
      });
    });

    document.getElementById('closeModal').addEventListener('click', () => modal.style.display = 'none');
    
    document.getElementById('confirmCancel').addEventListener('click', () => {
      if (selectedId) window.location.href = '${pageContext.request.contextPath}/lecturer/cancel-booking?id=' + selectedId;
    });

    // Simple Counter
    let conf = 0, canc = 0;
    document.querySelectorAll('tr[data-status]').forEach(tr => {
      if(tr.dataset.status === 'CONFIRMED') conf++;
      else canc++;
    });
    document.getElementById('confirmedCount').innerText = conf;
    document.getElementById('cancelledCount').innerText = canc;
  });
</script>
</body>
</html>