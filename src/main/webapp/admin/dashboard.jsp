<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>EBS Admin Dashboard</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/admin.css">

  <style>
    /* ── Chart panels ─────────────────────────────────────────────────────── */
    .charts-row {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 18px;
      margin-bottom: 24px;
    }

    .analytics-row {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 18px;
      margin-bottom: 24px;
    }

    .chart-panel {
      background: var(--white);
      border: 1px solid var(--border);
      padding: 20px;
    }

    .chart-panel-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 18px;
    }

    .chart-panel-header h2 {
      font-size: 16px;
      font-weight: 600;
      color: var(--text);
    }

    .chart-panel-header .chart-sub {
      font-size: 12px;
      color: var(--muted);
      margin-top: 2px;
    }

    .chart-wrap {
      position: relative;
      width: 100%;
    }

    .chart-wrap canvas {
      max-width: 100%;
    }

    /* ── Activity feed ────────────────────────────────────────────────────── */
    .activity-feed {
      display: flex;
      flex-direction: column;
      gap: 0;
    }

    .activity-item {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 11px 0;
      border-bottom: 1px solid var(--border);
    }

    .activity-item:last-child { border-bottom: none; }

    .activity-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-top: 5px;
      flex-shrink: 0;
    }

    .activity-dot.student  { background: #0067b8; }
    .activity-dot.lecturer { background: #5b6af7; }
    .activity-dot.pending  { background: #ffb900; }
    .activity-dot.approved { background: #107c10; }
    .activity-dot.cancelled{ background: #d13438; }

    .activity-text {
      flex: 1;
      min-width: 0;
    }

    .activity-text strong {
      font-size: 13px;
      font-weight: 600;
      display: block;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .activity-text span {
      font-size: 12px;
      color: var(--muted);
    }

    .activity-time {
      font-size: 11px;
      color: #a0a0a0;
      flex-shrink: 0;
      margin-top: 2px;
    }

    /* ── Mini KPI strip ───────────────────────────────────────────────────── */
    .kpi-strip {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }

    .kpi-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }

    .kpi-label {
      font-size: 13px;
      color: var(--muted);
      flex: 1;
    }

    .kpi-bar-wrap {
      flex: 2;
      height: 6px;
      background: #f0f0f0;
      border-radius: 3px;
      overflow: hidden;
    }

    .kpi-bar {
      height: 100%;
      border-radius: 3px;
      transition: width 0.8s ease;
      background: var(--blue);
    }

    .kpi-val {
      font-size: 13px;
      font-weight: 600;
      color: var(--text);
      min-width: 28px;
      text-align: right;
    }

    /* ── Bottom row ───────────────────────────────────────────────────────── */
    .bottom-row {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 18px;
      margin-bottom: 24px;
    }

    /* ── Quick Actions ────────────────────────────────────────────────────── */
    .quick-actions {
      display: grid;
      gap: 10px;
    }

    .action-btn {
      text-align: left;
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 12px 14px;
    }

    .action-icon {
      font-size: 16px;
      width: 22px;
      text-align: center;
      flex-shrink: 0;
    }

    /* ── Skeleton shimmer ─────────────────────────────────────────────────── */
    @keyframes shimmer {
      0%   { background-position: -600px 0; }
      100% { background-position:  600px 0; }
    }

    .skeleton {
      background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
      background-size: 600px 100%;
      animation: shimmer 1.4s infinite;
      border-radius: 3px;
    }

    /* ── Modal ────────────────────────────────────────────────────────────── */
    .modal-overlay {
      display: none; position: fixed; inset: 0;
      background: rgba(0,0,0,0.45); z-index: 999;
      align-items: center; justify-content: center;
    }
    .modal-overlay.open { display: flex; }
    .modal-box {
      background: #fff; border-radius: 12px; padding: 2rem;
      width: 100%; max-width: 400px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.18);
    }
    .modal-box h2 { margin: 0 0 0.4rem; font-size: 1.15rem; }
    .modal-box p  { margin: 0 0 1.4rem; font-size: 0.88rem; color: #666; }
    .report-options { display: flex; flex-direction: column; gap: 0.75rem; margin-bottom: 1.5rem; }
    .report-option {
      display: flex; align-items: center; gap: 0.75rem;
      padding: 0.75rem 1rem; border: 1px solid #e0e0e0;
      border-radius: 8px; cursor: pointer; font-size: 0.92rem;
      font-family: inherit; background: #fff; text-align: left;
      transition: border-color 0.15s, background 0.15s;
    }
    .report-option:hover         { border-color: #2563eb; background: #f0f6ff; }
    .report-option.selected      { border-color: #2563eb; background: #eff6ff; font-weight: 600; }
    .report-option .opt-label    { flex: 1; }
    .report-option .opt-check    {
      width: 18px; height: 18px; border: 2px solid #ccc; border-radius: 4px;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.75rem; color: #2563eb; flex-shrink: 0;
    }
    .report-option.selected .opt-check { border-color: #2563eb; background: #2563eb; color: #fff; }
    .modal-actions { display: flex; gap: 0.75rem; justify-content: flex-end; }
    .modal-actions .cancel-btn {
      padding: 0.55rem 1.2rem; border: 1px solid #ddd; border-radius: 7px;
      background: #fff; cursor: pointer; font-size: 0.9rem; font-family: inherit;
    }
    .modal-actions .cancel-btn:hover { background: #f5f5f5; }
    .modal-actions .primary-btn {
      padding: 0.55rem 1.4rem; background: #2563eb; color: #fff;
      border: none; border-radius: 7px; cursor: pointer;
      font-size: 0.9rem; font-family: inherit; font-weight: 600;
    }
    .modal-actions .primary-btn:hover     { background: #1d4ed8; }
    .modal-actions .primary-btn:disabled  { background: #93c5fd; cursor: not-allowed; }
    #reportStatus {
      font-size: 0.83rem; color: #2563eb; margin-bottom: 0.75rem;
      min-height: 1.1rem; text-align: center;
    }

    @media (max-width: 1100px) {
      .charts-row, .bottom-row { grid-template-columns: 1fr; }
      .analytics-row           { grid-template-columns: 1fr 1fr; }
    }
    @media (max-width: 700px) {
      .analytics-row           { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>

  <header class="top-navbar">
    <div class="nav-left">
      <div class="brand">
        <div class="brand-icon">
          <img src="../images/logo.jpeg" alt="EBS Logo">
        </div>
        <div class="divider"></div>
        <div class="brand-text">EBS Admin</div>
      </div>
      <nav class="nav-menu">
        <a href="dashboard.jsp"  class="nav-item active">Dashboard</a>
        <a href="users.jsp"      class="nav-item">Users</a>
        <a href="bookings.jsp"   class="nav-item">Bookings</a>
        <a href="resources.jsp"  class="nav-item">Resources</a>
        <a href="complaints.jsp" class="nav-item">Complaints</a>
        <a href="${pageContext.request.contextPath}/AdminLogoutServlet" class="nav-item">Logout</a>
      </nav>
    </div>
    <div class="nav-right">
      <a href="#" class="right-link">All EBS</a>
      <div class="search-wrap">
        <input type="text" class="search-box" placeholder="Search" />
      </div>
    </div>
  </header>

  <main class="main-content">

    <section class="hero-section">
      <h1>Admin Dashboard</h1>
      <p>Welcome back, <strong>${not empty sessionScope.userName ? sessionScope.userName : 'Admin'}</strong></p>
    </section>

    <%-- ── Stat cards ─────────────────────────────────────────────────────── --%>
    <section class="stats-grid">
      <div class="stat-card">
        <h3>Total Users</h3>
        <p class="stat-number" id="totalUsers">—</p>
        <span class="stat-note" id="noteUsers">Loading…</span>
      </div>
      <div class="stat-card">
        <h3>Total Bookings</h3>
        <p class="stat-number" id="totalBookings">—</p>
        <span class="stat-note" id="noteBookings">Loading…</span>
      </div>
      <div class="stat-card">
        <h3>Available Labs</h3>
        <p class="stat-number" id="availableLabs">—</p>
        <span class="stat-note success-text" id="noteLabs">Loading…</span>
      </div>
      <div class="stat-card">
        <h3>Complaints</h3>
        <p class="stat-number" id="totalComplaints">—</p>
        <span class="stat-note danger-text" id="noteComplaints">Loading…</span>
      </div>
    </section>

    <%-- ── Row 1: Bookings trend bar + Status donut ───────────────────────── --%>
    <section class="charts-row">

      <div class="chart-panel">
        <div class="chart-panel-header">
          <div>
            <h2>Bookings Over Time</h2>
            <div class="chart-sub">Last 10 recorded dates — students &amp; lecturer blocks</div>
          </div>
        </div>
        <div class="chart-wrap" style="height:230px;">
          <canvas id="trendChart"></canvas>
        </div>
      </div>

      <div class="chart-panel">
        <div class="chart-panel-header">
          <div>
            <h2>Status Breakdown</h2>
            <div class="chart-sub">All booking types</div>
          </div>
        </div>
        <div class="chart-wrap" style="height:230px;display:flex;align-items:center;justify-content:center;">
          <canvas id="statusChart" style="max-height:210px;max-width:210px;"></canvas>
        </div>
      </div>

    </section>

    <%-- ── Row 2: Three mini analytics panels ─────────────────────────────── --%>
    <section class="analytics-row">

      <%-- Booking type split --%>
      <div class="chart-panel">
        <div class="chart-panel-header">
          <div>
            <h2>Booking Types</h2>
            <div class="chart-sub">Student vs Lecturer</div>
          </div>
        </div>
        <div class="chart-wrap" style="height:160px;display:flex;align-items:center;justify-content:center;">
          <canvas id="typeChart" style="max-height:150px;max-width:150px;"></canvas>
        </div>
        <div id="typeLegend" style="margin-top:12px;display:flex;gap:14px;justify-content:center;font-size:12px;color:var(--muted);"></div>
      </div>

      <%-- User role KPI bars --%>
      <div class="chart-panel">
        <div class="chart-panel-header">
          <div>
            <h2>User Roles</h2>
            <div class="chart-sub">Distribution across roles</div>
          </div>
        </div>
        <div class="kpi-strip" id="roleKpis">
          <div class="kpi-item">
            <span class="kpi-label">Students</span>
            <div class="kpi-bar-wrap"><div class="kpi-bar skeleton" style="width:100%;"></div></div>
            <span class="kpi-val">—</span>
          </div>
          <div class="kpi-item">
            <span class="kpi-label">Lecturers</span>
            <div class="kpi-bar-wrap"><div class="kpi-bar skeleton" style="width:100%;"></div></div>
            <span class="kpi-val">—</span>
          </div>
          <div class="kpi-item">
            <span class="kpi-label">Admins</span>
            <div class="kpi-bar-wrap"><div class="kpi-bar skeleton" style="width:100%;"></div></div>
            <span class="kpi-val">—</span>
          </div>
        </div>
      </div>

      <%-- Quick actions --%>
      <div class="chart-panel">
        <div class="chart-panel-header">
          <div><h2>Quick Actions</h2></div>
        </div>
        <div class="quick-actions">
          <button class="action-btn" onclick="window.location.href='users.jsp'">
            <span class="action-icon">👤</span> Manage Users
          </button>
          <button class="action-btn" onclick="window.location.href='resources.jsp'">
            <span class="action-icon">🏫</span> Manage Labs
          </button>
          <button class="action-btn" onclick="window.location.href='complaints.jsp'">
            <span class="action-icon">📋</span> View Complaints
          </button>
          <button class="action-btn" id="generateReportBtn">
            <span class="action-icon">📄</span> Generate Report
          </button>
        </div>
      </div>

    </section>

    <%-- ── Row 3: Recent activity feed + top labs bar chart ───────────────── --%>
    <section class="bottom-row">

      <div class="chart-panel">
        <div class="chart-panel-header">
          <div>
            <h2>Lab Utilisation</h2>
            <div class="chart-sub">Bookings per lab (all time)</div>
          </div>
          <button class="panel-btn" onclick="window.location.href='bookings.jsp'">All Bookings</button>
        </div>
        <div class="chart-wrap" style="height:200px;">
          <canvas id="labChart"></canvas>
        </div>
      </div>

      <div class="chart-panel">
        <div class="chart-panel-header">
          <div>
            <h2>Recent Activity</h2>
            <div class="chart-sub">Latest 8 bookings</div>
          </div>
        </div>
        <div class="activity-feed" id="activityFeed">
          <div class="activity-item">
            <div class="activity-dot student"></div>
            <div class="activity-text">
              <strong class="skeleton" style="height:13px;display:block;width:70%;">&nbsp;</strong>
              <span class="skeleton" style="height:11px;display:block;width:50%;margin-top:4px;">&nbsp;</span>
            </div>
          </div>
        </div>
      </div>

    </section>

  </main>

  <%-- ── Generate Report Modal ──────────────────────────────────────────── --%>
  <div class="modal-overlay" id="reportModal">
    <div class="modal-box">
      <h2>Generate Report</h2>
      <p>Choose what to include in the PDF report</p>
      <div class="report-options">
        <button class="report-option selected" id="optBookings" onclick="toggleOption('bookings')">
          <span class="opt-label">Bookings Report</span>
          <span class="opt-check" id="chkBookings">&#10003;</span>
        </button>
        <button class="report-option selected" id="optUsers" onclick="toggleOption('users')">
          <span class="opt-label">Users Report</span>
          <span class="opt-check" id="chkUsers">&#10003;</span>
        </button>
      </div>
      <div id="reportStatus"></div>
      <div class="modal-actions">
        <button class="cancel-btn"  id="closeReportBtn">Cancel</button>
        <button class="primary-btn" id="downloadPdfBtn">&#11015; Download PDF</button>
      </div>
    </div>
  </div>

  <%-- ── Dependencies ────────────────────────────────────────────────────── --%>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>

  <script>
  (function () {
    'use strict';

    /* ── Design tokens (match admin.css) ─────────────────────────────────── */
    var BLUE      = '#0067b8';
    var BLUE_FADE = 'rgba(0,103,184,0.15)';
    var PURPLE    = '#5b6af7';
    var GREEN     = '#107c10';
    var YELLOW    = '#ffb900';
    var RED       = '#d13438';
    var MUTED     = '#605e5c';

    var chartDefaults = {
      font: { family: "'Segoe UI', Arial, sans-serif", size: 12 },
      color: MUTED
    };
    Chart.defaults.font       = chartDefaults.font;
    Chart.defaults.color      = chartDefaults.color;
    Chart.defaults.plugins.legend.labels.boxWidth = 10;
    Chart.defaults.plugins.legend.labels.padding  = 14;

    function esc(s) {
      var d = document.createElement('div');
      d.textContent = String(s || '');
      return d.innerHTML;
    }

    /* ── Stat cards ──────────────────────────────────────────────────────── */
    function loadStats() {
      fetch('../api/admin/dashboard')
        .then(function (r) { return r.json(); })
        .then(function (d) {
          document.getElementById('totalUsers').textContent      = d.totalUsers      ?? '—';
          document.getElementById('totalBookings').textContent   = d.totalBookings   ?? '—';
          document.getElementById('availableLabs').textContent   = d.availableLabs   ?? '—';
          document.getElementById('totalComplaints').textContent = d.totalComplaints ?? '—';
          document.getElementById('noteUsers').textContent       = (d.activeUsers       ?? 0) + ' active';
          document.getElementById('noteBookings').textContent    = (d.todaysBookings    ?? 0) + ' today';
          document.getElementById('noteLabs').textContent        = (d.availableLabs     ?? 0) + ' operational';
          document.getElementById('noteComplaints').textContent  = (d.pendingComplaints ?? 0) + ' pending';
        })
        .catch(function () {
          ['noteUsers','noteBookings','noteLabs','noteComplaints'].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) el.textContent = 'Unavailable';
          });
        });
    }

    /* ── All charts drawn from /api/bookings data ────────────────────────── */
    function loadBookingCharts() {
      fetch('../api/bookings')
        .then(function (r) { return r.json(); })
        .then(function (data) {
          var bookings = data.bookings || [];

          /* ── Trend: last 10 unique dates, count per date ── */
          var dateMap   = {};
          var studentMap = {};
          var lecturerMap = {};
          bookings.forEach(function (b) {
            var d = b.booking_date || 'Unknown';
            dateMap[d]    = (dateMap[d]    || 0) + 1;
            if (b.booking_type === 'LECTURER') {
              lecturerMap[d] = (lecturerMap[d] || 0) + 1;
            } else {
              studentMap[d]  = (studentMap[d]  || 0) + 1;
            }
          });

          var allDates = Object.keys(dateMap)
            .filter(function (d) { return d !== 'Unknown'; })
            .slice(-10);

          var trendStudentData  = allDates.map(function (d) { return studentMap[d]  || 0; });
          var trendLecturerData = allDates.map(function (d) { return lecturerMap[d] || 0; });

          /* Format dates shorter for axis labels */
          var shortDates = allDates.map(function (d) {
            var parts = d.split(' ');
            return parts.length >= 2 ? parts[0] + ' ' + parts[1] : d;
          });

          new Chart(document.getElementById('trendChart'), {
            type: 'bar',
            data: {
              labels: shortDates.length ? shortDates : ['No data'],
              datasets: [
                {
                  label: 'Students',
                  data: trendStudentData.length ? trendStudentData : [0],
                  backgroundColor: BLUE,
                  borderRadius: 3,
                  barPercentage: 0.55
                },
                {
                  label: 'Lecturers',
                  data: trendLecturerData.length ? trendLecturerData : [0],
                  backgroundColor: PURPLE,
                  borderRadius: 3,
                  barPercentage: 0.55
                }
              ]
            },
            options: {
              responsive: true,
              maintainAspectRatio: false,
              plugins: {
                legend: { position: 'top', align: 'end' },
                tooltip: { mode: 'index', intersect: false }
              },
              scales: {
                x: {
                  grid: { display: false },
                  stacked: true,
                  ticks: { maxRotation: 30, font: { size: 11 } }
                },
                y: {
                  stacked: true,
                  beginAtZero: true,
                  ticks: { stepSize: 1, precision: 0 },
                  grid: { color: '#f0f0f0' }
                }
              }
            }
          });

          /* ── Status donut ── */
          var approved = 0, pending = 0, cancelled = 0;
          bookings.forEach(function (b) {
            var s = (b.status || '').toUpperCase();
            if      (s === 'APPROVED' || s === 'CONFIRMED')  approved++;
            else if (s === 'PENDING')                        pending++;
            else                                             cancelled++;
          });

          new Chart(document.getElementById('statusChart'), {
            type: 'doughnut',
            data: {
              labels: ['Approved / Confirmed', 'Pending', 'Cancelled / Other'],
              datasets: [{
                data: [approved, pending, cancelled],
                backgroundColor: [GREEN, YELLOW, RED],
                borderWidth: 2,
                borderColor: '#fff',
                hoverOffset: 6
              }]
            },
            options: {
              responsive: true,
              maintainAspectRatio: false,
              cutout: '65%',
              plugins: {
                legend: { position: 'bottom', labels: { font: { size: 11 } } }
              }
            }
          });

          /* ── Type doughnut (Student vs Lecturer) ── */
          var typeStudent  = bookings.filter(function (b) { return b.booking_type !== 'LECTURER'; }).length;
          var typeLecturer = bookings.filter(function (b) { return b.booking_type === 'LECTURER'; }).length;

          new Chart(document.getElementById('typeChart'), {
            type: 'doughnut',
            data: {
              labels: ['Students', 'Lecturers'],
              datasets: [{
                data: [typeStudent, typeLecturer],
                backgroundColor: [BLUE, PURPLE],
                borderWidth: 2,
                borderColor: '#fff',
                hoverOffset: 5
              }]
            },
            options: {
              responsive: true,
              maintainAspectRatio: false,
              cutout: '60%',
              plugins: { legend: { display: false } }
            }
          });

          var total = typeStudent + typeLecturer || 1;
          document.getElementById('typeLegend').innerHTML =
            '<span style="color:' + BLUE   + ';">&#9679; Students '  + typeStudent  + ' (' + Math.round(typeStudent/total*100)  + '%)</span>' +
            '<span style="color:' + PURPLE + ';">&#9679; Lecturers ' + typeLecturer + ' (' + Math.round(typeLecturer/total*100) + '%)</span>';

          /* ── Lab utilisation horizontal bar ── */
          var labMap = {};
          bookings.forEach(function (b) {
            var l = b.lab_name || 'Unknown';
            labMap[l] = (labMap[l] || 0) + 1;
          });

          var labEntries = Object.entries(labMap)
            .sort(function (a, b) { return b[1] - a[1]; })
            .slice(0, 6);

          new Chart(document.getElementById('labChart'), {
            type: 'bar',
            data: {
              labels: labEntries.map(function (e) { return e[0]; }),
              datasets: [{
                label: 'Total Bookings',
                data: labEntries.map(function (e) { return e[1]; }),
                backgroundColor: labEntries.map(function (_, i) {
                  return 'rgba(0,103,184,' + (1 - i * 0.12) + ')';
                }),
                borderRadius: 3,
                barPercentage: 0.55
              }]
            },
            options: {
              indexAxis: 'y',
              responsive: true,
              maintainAspectRatio: false,
              plugins: { legend: { display: false } },
              scales: {
                x: {
                  beginAtZero: true,
                  ticks: { stepSize: 1, precision: 0 },
                  grid: { color: '#f0f0f0' }
                },
                y: {
                  grid: { display: false },
                  ticks: { font: { size: 12 } }
                }
              }
            }
          });

          /* ── Recent activity feed ── */
          var recent = bookings.slice(0, 8);
          var feedEl  = document.getElementById('activityFeed');

          if (!recent.length) {
            feedEl.innerHTML = '<div style="padding:1rem;color:var(--muted);font-size:13px;">No activity yet.</div>';
            return;
          }

          var feedHtml = '';
          recent.forEach(function (b) {
            var isLecturer = b.booking_type === 'LECTURER';
            var s          = (b.status || '').toUpperCase();
            var dotClass   = isLecturer ? 'lecturer'
                           : (s === 'APPROVED' || s === 'CONFIRMED') ? 'approved'
                           : (s === 'PENDING') ? 'pending' : 'cancelled';

            var who  = esc(b.user_name || b.user_email || '—');
            var lab  = esc(b.lab_name  || '—');
            var date = esc(b.booking_date || '');
            var tag  = isLecturer ? 'Lecturer block' : 'Seat booking';

            feedHtml +=
              '<div class="activity-item">' +
                '<div class="activity-dot ' + dotClass + '"></div>' +
                '<div class="activity-text">' +
                  '<strong>' + who + '</strong>' +
                  '<span>' + tag + ' &middot; ' + lab + '</span>' +
                '</div>' +
                '<div class="activity-time">' + date + '</div>' +
              '</div>';
          });

          feedEl.innerHTML = feedHtml;
        })
        .catch(function (err) {
          console.warn('Booking charts failed:', err);
        });
    }

    /* ── User role KPI bars ──────────────────────────────────────────────── */
    function loadUserRoles() {
      fetch('../api/users')
        .then(function (r) { return r.json(); })
        .then(function (data) {
          var users     = data.users || [];
          var students  = users.filter(function (u) { return (u.role||'').toLowerCase() === 'student';  }).length;
          var lecturers = users.filter(function (u) { return (u.role||'').toLowerCase() === 'lecturer'; }).length;
          var admins    = users.filter(function (u) { return (u.role||'').toLowerCase() === 'admin';    }).length;
          var total     = users.length || 1;

          var colors = [BLUE, PURPLE, '#00b4d8'];
          var counts = [students, lecturers, admins];
          var labels = ['Students', 'Lecturers', 'Admins'];

          var kpiHtml = '';
          labels.forEach(function (label, i) {
            var pct = Math.round(counts[i] / total * 100);
            kpiHtml +=
              '<div class="kpi-item">' +
                '<span class="kpi-label">' + label + '</span>' +
                '<div class="kpi-bar-wrap">' +
                  '<div class="kpi-bar" style="width:' + pct + '%;background:' + colors[i] + ';"></div>' +
                '</div>' +
                '<span class="kpi-val">' + counts[i] + '</span>' +
              '</div>';
          });

          document.getElementById('roleKpis').innerHTML = kpiHtml;
        })
        .catch(function () { /* leave skeleton */ });
    }

    /* ── Report modal ────────────────────────────────────────────────────── */
    var includeBookings = true, includeUsers = true;

    window.toggleOption = function (type) {
      if (type === 'bookings') {
        includeBookings = !includeBookings;
        document.getElementById('optBookings').classList.toggle('selected', includeBookings);
        document.getElementById('chkBookings').innerHTML = includeBookings ? '&#10003;' : '';
      } else {
        includeUsers = !includeUsers;
        document.getElementById('optUsers').classList.toggle('selected', includeUsers);
        document.getElementById('chkUsers').innerHTML = includeUsers ? '&#10003;' : '';
      }
    };

    document.getElementById('generateReportBtn').addEventListener('click', function () {
      document.getElementById('reportStatus').textContent = '';
      document.getElementById('reportModal').classList.add('open');
    });
    document.getElementById('closeReportBtn').addEventListener('click', function () {
      document.getElementById('reportModal').classList.remove('open');
    });
    document.getElementById('reportModal').addEventListener('click', function (e) {
      if (e.target === this) this.classList.remove('open');
    });

    document.getElementById('downloadPdfBtn').addEventListener('click', function () {
      if (!includeBookings && !includeUsers) {
        document.getElementById('reportStatus').textContent = 'Please select at least one report type.';
        return;
      }
      var btn = document.getElementById('downloadPdfBtn');
      btn.disabled = true; btn.textContent = 'Generating…';
      document.getElementById('reportStatus').textContent = 'Fetching data…';

      var promises = [
        includeBookings ? fetch('../api/bookings').then(function(r){return r.json();}) : Promise.resolve(null),
        includeUsers    ? fetch('../api/users').then(function(r){return r.json();})    : Promise.resolve(null)
      ];

      Promise.all(promises).then(function (results) {
        var bData = results[0], uData = results[1];
        document.getElementById('reportStatus').textContent = 'Building PDF…';

        var doc   = new window.jspdf.jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
        var pageW = doc.internal.pageSize.getWidth();
        var today = new Date().toLocaleDateString('en-ZA', { year: 'numeric', month: 'long', day: 'numeric' });
        var y     = 15;

        doc.setFillColor(0, 103, 184);
        doc.rect(0, 0, pageW, 28, 'F');
        doc.setTextColor(255, 255, 255);
        doc.setFontSize(18); doc.setFont('helvetica', 'bold');
        doc.text('EBS Admin Report', 14, 12);
        doc.setFontSize(9); doc.setFont('helvetica', 'normal');
        doc.text('Generated: ' + today, 14, 20);
        doc.text('Electronic Booking System', pageW - 14, 20, { align: 'right' });
        y = 38; doc.setTextColor(30, 30, 30);

        if (includeBookings && bData) {
          var bookings = bData.bookings || [];
          doc.setFontSize(13); doc.setFont('helvetica', 'bold'); doc.setTextColor(0, 103, 184);
          doc.text('Bookings Report', 14, y); y += 2;
          doc.setDrawColor(0, 103, 184); doc.setLineWidth(0.5);
          doc.line(14, y, pageW - 14, y); y += 6;
          doc.setTextColor(30, 30, 30); doc.setFontSize(9); doc.setFont('helvetica', 'normal');
          doc.text('Total: ' + bookings.length, 14, y); y += 5;
          if (!bookings.length) {
            doc.setTextColor(150,150,150); doc.text('No bookings found.', 14, y); y += 10;
          } else {
            doc.autoTable({
              startY: y,
              head: [['Type', 'Name', 'Lab', 'Seat / Module', 'Date', 'Status']],
              body: bookings.map(function (b) {
                return [
                  b.booking_type || 'STUDENT',
                  b.user_name  || b.user_email  || '—',
                  b.lab_name   || '—',
                  b.seat_label || '—',
                  b.booking_date || '—',
                  b.status || '—'
                ];
              }),
              theme: 'striped',
              headStyles:        { fillColor: [0,103,184], textColor: 255, fontStyle: 'bold', fontSize: 9 },
              bodyStyles:        { fontSize: 8.5 },
              alternateRowStyles:{ fillColor: [239,246,255] },
              margin: { left: 14, right: 14 }
            });
            y = doc.lastAutoTable.finalY + 12;
          }
        }

        if (includeUsers && uData) {
          var users = uData.users || [];
          if (y > 220) { doc.addPage(); y = 20; }
          doc.setFontSize(13); doc.setFont('helvetica', 'bold'); doc.setTextColor(0, 103, 184);
          doc.text('Users Report', 14, y); y += 2;
          doc.setDrawColor(0, 103, 184); doc.setLineWidth(0.5);
          doc.line(14, y, pageW - 14, y); y += 6;
          doc.setTextColor(30, 30, 30); doc.setFontSize(9); doc.setFont('helvetica', 'normal');
          var active = users.filter(function (u) { return !u.is_banned; }).length;
          var banned = users.filter(function (u) { return  u.is_banned; }).length;
          doc.text('Total: ' + users.length + '   Active: ' + active + '   Banned: ' + banned, 14, y); y += 5;
          if (users.length) {
            doc.autoTable({
              startY: y,
              head: [['Name', 'Email', 'Role', 'Status']],
              body: users.map(function (u) {
                return [
                  u.full_name || (u.email ? u.email.split('@')[0] : '—'),
                  u.email || '—',
                  u.role  || '—',
                  u.is_banned ? 'Banned' : 'Active'
                ];
              }),
              theme: 'striped',
              headStyles:        { fillColor: [0,103,184], textColor: 255, fontStyle: 'bold', fontSize: 9 },
              bodyStyles:        { fontSize: 8.5 },
              alternateRowStyles:{ fillColor: [239,246,255] },
              margin: { left: 14, right: 14 }
            });
          }
        }

        var totalPages = doc.internal.getNumberOfPages();
        for (var p = 1; p <= totalPages; p++) {
          doc.setPage(p);
          doc.setFontSize(8); doc.setTextColor(150); doc.setFont('helvetica', 'normal');
          doc.text('EBS Admin System — Confidential', 14, doc.internal.pageSize.getHeight() - 8);
          doc.text('Page ' + p + ' of ' + totalPages, pageW - 14, doc.internal.pageSize.getHeight() - 8, { align: 'right' });
        }

        doc.save('EBS_Report_' + new Date().toISOString().slice(0,10) + '.pdf');
        document.getElementById('reportStatus').textContent = 'Report downloaded!';
        document.getElementById('reportModal').classList.remove('open');
      })
      .catch(function (err) {
        console.error(err);
        document.getElementById('reportStatus').textContent = 'Failed to fetch data. Please try again.';
      })
      .finally(function () {
        btn.disabled = false;
        btn.textContent = '⬇ Download PDF';
      });
    });

    /* ── Boot ─────────────────────────────────────────────────────────────── */
    document.addEventListener('DOMContentLoaded', function () {
      loadStats();
      loadBookingCharts();
      loadUserRoles();
    });

  })();
  </script>

  <script src="../js/admin.js"></script>
</body>
</html>
