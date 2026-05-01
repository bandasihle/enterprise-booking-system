<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Book Lab – EBS</title>
  <%-- Location: src/main/webapp/pages/lecturer/book-lab.jsp --%>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/lecturer/css/lecturer.css">
</head>
<body>

<nav class="top-navbar">
  <div style="display:flex;align-items:center;gap:24px;">
    <a href="${pageContext.request.contextPath}/test-index.html" class="nav-brand">
     
      <div class="nav-brand-text"><strong>EBS</strong><span> Lecturer</span></div>
    </a>
    <nav class="nav-menu">
      <a href="${pageContext.request.contextPath}/lecturer/dashboard" class="nav-item">Dashboard</a>
      <a href="${pageContext.request.contextPath}/lecturer/book-lab"  class="nav-item active">Book Lab</a>
      <a href="${pageContext.request.contextPath}/lecturer/bookings"  class="nav-item">My Bookings</a>
    </nav>
  </div>
  <div class="nav-right">
    <span class="user-chip">👨‍🏫 ${sessionScope.userName}</span>
    <a href="${pageContext.request.contextPath}/logout" class="logout-link">Logout</a>
  </div>
</nav>

<div class="main-content" style="max-width:820px;">

  <c:if test="${not empty flashMsg}">
    <div class="flash ${flashType}">${flashMsg}</div>
  </c:if>
  <c:if test="${not empty loadError}">
    <div class="flash error">Could not load labs: ${loadError}</div>
  </c:if>

  <div class="page-header">
    <div>
      <h1>Book a Lab</h1>
      <p>Reserve an entire venue for your class, practical or test session.</p>
    </div>
    <a href="${pageContext.request.contextPath}/lecturer/bookings" class="outline-btn">My Bookings</a>
  </div>

  <div class="form-card">
    <div class="section-title">Reservation Details</div>
    <p class="section-subtitle">All fields marked * are required.</p>

    <%--
      action="/lecturer/book-lab" → LecturerServlet.doPost()
      which calls LecturerBlockService.createBlock() → inserts to lecturer_blocks table
    --%>
    <form id="blockForm" action="${pageContext.request.contextPath}/lecturer/book-lab" method="POST">

      <div class="form-grid">

        <%-- Building filter: client-side only, no name attr --%>
        <div class="form-group">
          <label class="form-label" for="buildingFilter">Building</label>
          <select class="select" id="buildingFilter">
            <option value="">— All Buildings —</option>
            <c:set var="lastB" value=""/>
            <c:forEach var="lab" items="${labs}">
              <c:if test="${lab.building != lastB}">
                <option value="${lab.building}">${lab.building}</option>
                <c:set var="lastB" value="${lab.building}"/>
              </c:if>
            </c:forEach>
          </select>
        </div>

        <%-- labId: labs.id PK — sent to servlet --%>
        <div class="form-group">
          <label class="form-label" for="labId">Lab / Venue *</label>
          <select class="select" id="labId" name="labId" required>
            <option value="">— Select Lab —</option>
            <c:forEach var="lab" items="${labs}">
              <option value="${lab.id}"
                      data-building="${lab.building}"
                      <c:if test="${not empty preLabId and preLabId eq lab.id.toString()}">selected</c:if>>
                ${lab.labName} (${lab.building})
              </option>
            </c:forEach>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label" for="date">Date *</label>
          <input class="input" type="date" id="date" name="date" required/>
        </div>

        <div class="form-group">
          <label class="form-label" for="moduleCode">Module Code *</label>
          <input class="input" type="text" id="moduleCode" name="moduleCode"
                 placeholder="e.g. BICT112" required maxlength="20"/>
        </div>

        <div class="form-group">
          <label class="form-label" for="startTime">Start Time *</label>
          <input class="input" type="time" id="startTime" name="startTime" required/>
        </div>

        <div class="form-group">
          <label class="form-label" for="endTime">End Time *</label>
          <input class="input" type="time" id="endTime" name="endTime" required/>
        </div>

        <div class="form-group full">
          <label class="form-label" for="reason">Session Notes (optional)</label>
          <textarea class="textarea" id="reason" name="reason"
                    placeholder="Purpose of this reservation, class group, or any notes…"></textarea>
        </div>

        <div class="form-group full" id="timeErrWrap" style="display:none;">
          <div class="flash error">⚠ End time must be after start time.</div>
        </div>

      </div>

      <div class="form-actions">
        <a href="${pageContext.request.contextPath}/lecturer/dashboard" class="outline-btn">← Cancel</a>
        <button type="submit" class="primary-btn">Submit Reservation</button>
      </div>
    </form>
  </div>

  <%-- Existing blocks: helps lecturer avoid clashes --%>
  <c:if test="${not empty blocks}">
    <div class="panel">
      <div class="panel-head"><h2>Your Existing Reservations</h2></div>
      <div class="table-wrapper">
        <table>
          <thead><tr><th>Module</th><th>Lab</th><th>Date</th><th>Time</th></tr></thead>
          <tbody>
            <c:forEach var="b" items="${blocks}">
              <tr>
                <td style="font-weight:700;">${b.moduleCode}</td>
                <td>${b.lab.labName}</td>
                <td>${fn:substring(b.startTime.toString(),0,10)}</td>
                <td>${fn:substring(b.startTime.toString(),11,16)} – ${fn:substring(b.endTime.toString(),11,16)}</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>
  </c:if>

</div>

<script>
  document.getElementById('date').min = new Date().toISOString().split('T')[0];

  document.getElementById('buildingFilter').addEventListener('change', function () {
    const v = this.value;
    const sel = document.getElementById('labId');
    Array.from(sel.options).forEach(function(o){
      if (!o.value) return;
      o.hidden = !!(v && o.dataset.building !== v);
    });
    if (sel.selectedOptions[0] && sel.selectedOptions[0].hidden) sel.value = '';
  });

  document.getElementById('blockForm').addEventListener('submit', function (e) {
    const s = document.getElementById('startTime').value;
    const d = document.getElementById('endTime').value;
    const w = document.getElementById('timeErrWrap');
    if (s && d && s >= d) { e.preventDefault(); w.style.display='block'; document.getElementById('endTime').focus(); }
    else w.style.display = 'none';
  });
</script>
</body>
</html>
