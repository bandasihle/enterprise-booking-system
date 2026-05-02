<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Book Lab – EBS</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/lecturer/css/lecturer.css">
  <style>
    :root {
        --primary-green: #065f46;
        --text-main: #1e293b;
        --text-secondary: #64748b;
        --border-color: #e2e8f0;
    }

    /* Layout: Form on left, Quick-Look on right */
    .booking-container {
        display: grid;
        grid-template-columns: 1.5fr 1fr;
        gap: 32px;
        margin-top: 30px;
    }

    .form-card { 
        background: #fff; 
        border-radius: 16px; 
        padding: 32px; 
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05); 
        border: 1px solid var(--border-color);
    }

    .sidebar-panel {
        background: #f8fafc;
        border-radius: 16px;
        padding: 24px;
        border: 1px dashed #cbd5e1;
        height: fit-content;
    }

    .compact-list { list-style: none; padding: 0; margin: 0; }
    .compact-item {
        background: #fff;
        padding: 12px;
        border-radius: 10px;
        margin-bottom: 10px;
        border: 1px solid var(--border-color);
        font-size: 0.85rem;
    }

    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .full { grid-column: span 2; }
    
    .input, .select, .textarea { 
        width: 100%; padding: 10px; border: 1.5px solid var(--border-color); 
        border-radius: 8px; font-family: inherit; margin-top: 5px;
    }


    /* ── Lab preview image in sidebar ─────────────────────── */
    .lab-preview-wrap {
        width: 100%;
        height: 160px;
        border-radius: 10px;
        overflow: hidden;
        margin-bottom: 16px;
        position: relative;
        background: #e2e8f0;
    }

    .lab-preview-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        object-position: center;
        display: block;
        transition: opacity 0.3s ease;
    }

    .lab-preview-label {
        position: absolute;
        bottom: 0; left: 0; right: 0;
        background: linear-gradient(transparent, rgba(6,95,70,0.75));
        color: #fff;
        font-size: 11px;
        font-weight: 700;
        padding: 18px 10px 8px;
        letter-spacing: 0.4px;
    }

    .lab-preview-placeholder {
        width: 100%;
        height: 160px;
        border-radius: 10px;
        background: #f1f5f9;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #94a3b8;
        font-size: 13px;
        margin-bottom: 16px;
        gap: 6px;
    }
    @media (max-width: 900px) {
        .booking-container { grid-template-columns: 1fr; }
    }
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
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="nav-item active">Book Lab</a>
    <a href="${pageContext.request.contextPath}/lecturer/bookings" class="nav-item">My Bookings</a>
  </div>
  <div class="nav-right">
    <span style="color:white; font-size: 0.85rem;">👨‍🏫 ${sessionScope.userName}</span>
  </div>
</nav>

<div class="main-content" style="max-width:1100px; margin: 40px auto;">
  
  <div class="page-header">
    <h1>New Lab Reservation</h1>
    <p style="color: var(--text-secondary);">Fill in the details below to block a venue.</p>
  </div>

  <div class="booking-container">
    
    <!-- LEFT: THE FORM -->
    <div class="form-card">
      <form id="blockForm" action="${pageContext.request.contextPath}/lecturer/book-lab" method="POST">
        <div class="form-grid">
          <div class="form-group">
            <label style="font-weight:600;">Building</label>
            <select class="select" id="buildingFilter">
              <option value="">All Buildings</option>
              <c:set var="lastB" value=""/>
              <c:forEach var="lab" items="${labs}">
                <c:if test="${lab.building != lastB}">
                  <option value="${lab.building}">${lab.building}</option>
                  <c:set var="lastB" value="${lab.building}"/>
                </c:if>
              </c:forEach>
            </select>
          </div>

          <div class="form-group">
            <label style="font-weight:600;">Lab / Venue *</label>
            <select class="select" id="labId" name="labId" required>
              <option value="">Select Lab</option>
              <c:forEach var="lab" items="${labs}">
                <option value="${lab.id}" data-building="${lab.building}"
                  <c:if test="${not empty preLabId and preLabId eq lab.id.toString()}">selected</c:if>>
                  ${lab.labName}
                </option>
              </c:forEach>
            </select>
          </div>

          <div class="form-group">
            <label style="font-weight:600;">Date *</label>
            <input class="input" type="date" id="date" name="date" required/>
          </div>

          <div class="form-group">
            <label style="font-weight:600;">Module Code *</label>
            <input class="input" type="text" name="moduleCode" placeholder="e.g. BICT112" required/>
          </div>

          <div class="form-group">
            <label style="font-weight:600;">Start Time *</label>
            <input class="input" type="time" id="startTime" name="startTime" required/>
          </div>

          <div class="form-group">
            <label style="font-weight:600;">End Time *</label>
            <input class="input" type="time" id="endTime" name="endTime" required/>
          </div>

          <div class="form-group full">
            <label style="font-weight:600;">Session Notes</label>
            <textarea class="textarea" name="reason" rows="2" placeholder="Purpose..."></textarea>
          </div>
        </div>

        <div style="margin-top: 24px; display: flex; justify-content: flex-end;">
          <button type="submit" class="primary-btn" style="background: var(--primary-green); padding: 12px 40px; border-radius: 10px;">
            Confirm Booking
          </button>
        </div>
      </form>
    </div>

    <!-- RIGHT: THE "QUICK-LOOK" (Replaced duplicate full table) -->
    <div class="sidebar-panel">
      <%-- Lab preview image — swaps via JS when a lab is selected --%>
      <div id="labPreviewWrap" class="lab-preview-placeholder">
        <span style="font-size:28px;">🏫</span>
        <span>Select a lab to preview</span>
      </div>

      <h3 style="margin-top:0; font-size: 1.1rem;">Upcoming Sessions</h3>
      <p style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 20px;">Your next 5 reservations</p>
      
      <div class="compact-list">
        <c:choose>
          <c:when test="${not empty blocks}">
            <c:forEach var="b" items="${blocks}" end="4">
              <div class="compact-item">
                <div style="display:flex; justify-content:space-between; margin-bottom: 4px;">
                  <span style="font-weight:800; color: var(--primary-green);">${b.moduleCode}</span>
                  <span style="color: var(--text-secondary); font-size: 0.75rem;">${fn:substring(b.startTime.toString(),0,10)}</span>
                </div>
                <div style="color: var(--text-main); font-weight: 500;">${b.lab.labName}</div>
                <div style="color: var(--text-secondary); font-size: 0.8rem; margin-top: 4px;">
                   🕒 ${fn:substring(b.startTime.toString(),11,16)} - ${fn:substring(b.endTime.toString(),11,16)}
                </div>
              </div>
            </c:forEach>
            <a href="${pageContext.request.contextPath}/lecturer/bookings" 
               style="display:block; text-align:center; font-size: 0.8rem; color: var(--primary-green); text-decoration:none; font-weight:700; margin-top: 15px;">
               View All Bookings →
            </a>
          </c:when>
          <c:otherwise>
            <p style="font-size: 0.85rem; color: var(--text-secondary); text-align:center;">No upcoming bookings found.</p>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

  </div>
</div>

<script>
  // Building Filter Logic
  document.getElementById('buildingFilter').addEventListener('change', function() {
    const v = this.value;
    const sel = document.getElementById('labId');
    Array.from(sel.options).forEach(o => {
      if (!o.value) return;
      o.hidden = !!(v && o.dataset.building !== v);
    });
    if (sel.selectedOptions[0]?.hidden) sel.value = '';
  });

  // Date Logic
  document.getElementById('date').min = new Date().toISOString().split('T')[0];

  // ── Lab preview image switcher ────────────────────────────
  (function () {
    // Maps keywords in a lab name → image filename (all in /lecturer/images/)
    // Computer labs get the 4 real lab photos; anything else gets seminar/lecture-hall
    var computerImages = [
      'lab-wide.jpeg',
      'lab-color.jpeg',
      'lab-evening.jpeg',
      'lab-dark.jpeg'
    ];
    var seminarImages = [
      'seminar.jpeg',
      'lecture-hall.jpeg'
    ];

    // Resolve image for an option index + name
    function resolveImage(idx, labName) {
      var lower = labName.toLowerCase();
      var isComputer = lower.indexOf('lab') >= 0 || lower.indexOf('lg') >= 0 || lower.indexOf('computer') >= 0;
      if (isComputer) {
        return computerImages[idx % computerImages.length];
      }
      return seminarImages[idx % seminarImages.length];
    }

    function updatePreview(selectEl) {
      var wrap = document.getElementById('labPreviewWrap');
      var selectedOpt = selectEl.options[selectEl.selectedIndex];

      if (!selectEl.value) {
        wrap.className = 'lab-preview-placeholder';
        wrap.innerHTML = '<span style="font-size:28px;">🏫</span><span>Select a lab to preview</span>';
        return;
      }

      // index within real options (skip the placeholder option at index 0)
      var realIdx = selectEl.selectedIndex - 1;
      var labName = selectedOpt.text;
      var imgFile = resolveImage(realIdx, labName);
      var ctx = '${pageContext.request.contextPath}';

      wrap.className = 'lab-preview-wrap';
      wrap.innerHTML =
        '<img class="lab-preview-img" src="' + ctx + '/lecturer/images/' + imgFile + '"' +
        '     alt="' + labName + '"' +
        '     onerror="this.src=\'' + ctx + '/lecturer/images/logo.jpeg\'"/>' +
        '<div class="lab-preview-label">' + labName + '</div>';
    }

    var labSel = document.getElementById('labId');
    labSel.addEventListener('change', function () { updatePreview(this); });

    // Pre-populate if a lab was already selected (e.g. arriving from dashboard with ?labId=)
    if (labSel.value) { updatePreview(labSel); }
  })();
</script>
</body>
</html>