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
    /* ── Report modal overlay ── */
    .modal-overlay {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.45);
      z-index: 999;
      align-items: center;
      justify-content: center;
    }
    .modal-overlay.open { display: flex; }

    .modal-box {
      background: #fff;
      border-radius: 12px;
      padding: 2rem;
      width: 100%;
      max-width: 400px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.18);
    }
    .modal-box h2 { margin: 0 0 0.4rem; font-size: 1.15rem; }
    .modal-box p  { margin: 0 0 1.4rem; font-size: 0.88rem; color: #666; }

    .report-options { display: flex; flex-direction: column; gap: 0.75rem; margin-bottom: 1.5rem; }

    .report-option {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.75rem 1rem;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      cursor: pointer;
      font-size: 0.92rem;
      font-family: inherit;
      background: #fff;
      text-align: left;
      transition: border-color 0.15s, background 0.15s;
    }
    .report-option:hover { border-color: #2563eb; background: #f0f6ff; }
    .report-option.selected { border-color: #2563eb; background: #eff6ff; font-weight: 600; }
    .report-option .opt-icon { font-size: 1.3rem; }
    .report-option .opt-label { flex: 1; }
    .report-option .opt-check {
      width: 18px; height: 18px;
      border: 2px solid #ccc;
      border-radius: 4px;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.75rem;
      color: #2563eb;
      flex-shrink: 0;
    }
    .report-option.selected .opt-check { border-color: #2563eb; background: #2563eb; color: #fff; }

    .modal-actions { display: flex; gap: 0.75rem; justify-content: flex-end; }
    .modal-actions .cancel-btn {
      padding: 0.55rem 1.2rem;
      border: 1px solid #ddd;
      border-radius: 7px;
      background: #fff;
      cursor: pointer;
      font-size: 0.9rem;
      font-family: inherit;
    }
    .modal-actions .cancel-btn:hover { background: #f5f5f5; }
    .modal-actions .primary-btn {
      padding: 0.55rem 1.4rem;
      background: #2563eb;
      color: #fff;
      border: none;
      border-radius: 7px;
      cursor: pointer;
      font-size: 0.9rem;
      font-family: inherit;
      font-weight: 600;
    }
    .modal-actions .primary-btn:hover { background: #1d4ed8; }
    .modal-actions .primary-btn:disabled { background: #93c5fd; cursor: not-allowed; }

    #reportStatus {
      font-size: 0.83rem;
      color: #2563eb;
      margin-bottom: 0.75rem;
      min-height: 1.1rem;
      text-align: center;
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
        <a href="dashboard.jsp" class="nav-item active">Dashboard</a>
        <a href="users.jsp" class="nav-item">Users</a>
        <a href="bookings.jsp" class="nav-item">Bookings</a>
        <a href="resources.jsp" class="nav-item">Resources</a>
        <a href="complaints.jsp" class="nav-item">Complaints</a>
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
      <p>Welcome back, Admin</p>
    </section>

    <section class="stats-grid">
      <div class="stat-card">
        <h3>Total Users</h3>
        <p class="stat-number" id="totalUsers">—</p>
        <span class="stat-note">+12 this week</span>
      </div>
      <div class="stat-card">
        <h3>Total Bookings</h3>
        <p class="stat-number" id="totalBookings">—</p>
        <span class="stat-note">Today's bookings</span>
      </div>
      <div class="stat-card">
        <h3>Available Labs</h3>
        <p class="stat-number" id="availableLabs">—</p>
        <span class="stat-note success-text">Operational</span>
      </div>
      <div class="stat-card">
        <h3>Complaints</h3>
        <p class="stat-number" id="totalComplaints">—</p>
        <span class="stat-note danger-text">Needs attention</span>
      </div>
    </section>

    <section class="content-grid">
      <div class="panel">
        <div class="panel-header">
          <h2>Recent Bookings</h2>
          <button class="panel-btn">View All</button>
        </div>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Student</th>
                <th>Lab</th>
                <th>Seat</th>
                <th>Date</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody id="recentBookingsBody">
              <tr><td colspan="5" style="text-align:center;padding:1.5rem;color:#888;">Loading...</td></tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <h2>Quick Actions</h2>
        </div>
        <div class="quick-actions">
          <button class="action-btn" onclick="window.location.href='users.jsp'">Suspend User</button>
          <button class="action-btn">Manage Labs</button>
          <button class="action-btn">View Complaints</button>
          <button class="action-btn" id="generateReportBtn">Generate Report</button>
        </div>
      </div>
    </section>

    <section class="bottom-grid">
      <div class="panel">
        <div class="panel-header">
          <h2>User Management Overview</h2>
        </div>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Role</th>
                <th>Status</th>
                <th>Last Login</th>
              </tr>
            </thead>
            <tbody id="userOverviewBody">
              <tr><td colspan="4" style="text-align:center;padding:1.5rem;color:#888;">Loading...</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>
  </main>

  <!-- ── Generate Report Modal ── -->
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
        <button class="cancel-btn" id="closeReportBtn">Cancel</button>
        <button class="primary-btn" id="downloadPdfBtn">&#11015; Download PDF</button>
      </div>
    </div>
  </div>

  <!-- jsPDF from CDN -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <!-- jsPDF AutoTable plugin -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>

  <script>
  (function () {
    function esc(s) { var d = document.createElement('div'); d.textContent = String(s || ''); return d.innerHTML; }

    /* ---- STAT CARDS ---- */
    function loadStats() {
      fetch('../api/admin/dashboard')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          document.getElementById('totalUsers').textContent      = data.totalUsers      || 0;
          document.getElementById('totalBookings').textContent   = data.totalBookings   || 0;
          document.getElementById('availableLabs').textContent   = data.availableLabs   || 0;
          document.getElementById('totalComplaints').textContent = data.totalComplaints || 0;
        })
        .catch(function() {});
    }

    /* ---- RECENT BOOKINGS (latest 5) ---- */
    function loadRecentBookings() {
      fetch('../api/bookings')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var bookings = (data.bookings || []).slice(0, 5);
          var tbody = document.getElementById('recentBookingsBody');
          if (!bookings.length) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;padding:1.5rem;color:#888;">No bookings yet.</td></tr>';
            return;
          }
          var html = '';
          for (var i = 0; i < bookings.length; i++) {
            var b  = bookings[i];
            var bc = b.status === 'Approved' ? 'success' : b.status === 'Pending' ? 'warning' : 'danger';
            html += '<tr>'
              + '<td>' + esc(b.student_name || b.student_email || '') + '</td>'
              + '<td>' + esc(b.lab_name || '') + '</td>'
              + '<td>' + esc(b.seat_label || b.seat_id || '') + '</td>'
              + '<td>' + esc(b.booking_date || '') + '</td>'
              + '<td><span class="badge ' + bc + '">' + esc(b.status) + '</span></td>'
              + '</tr>';
          }
          tbody.innerHTML = html;
        })
        .catch(function() {
          document.getElementById('recentBookingsBody').innerHTML =
            '<tr><td colspan="5" style="text-align:center;padding:1.5rem;color:#888;">No booking data available.</td></tr>';
        });
    }

    /* ---- USER OVERVIEW (latest 5) ---- */
    function loadUserOverview() {
      fetch('../api/users')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var users = (data.users || []).slice(0, 5);
          var tbody = document.getElementById('userOverviewBody');
          if (!users.length) {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align:center;padding:1.5rem;color:#888;">No users yet.</td></tr>';
            return;
          }
          var html = '';
          for (var i = 0; i < users.length; i++) {
            var u    = users[i];
            var bc   = u.is_banned ? 'danger' : 'success';
            var st   = u.is_banned ? 'Banned' : 'Active';
            var name = u.full_name || u.email.split('@')[0];
            html += '<tr>'
              + '<td>' + esc(name) + '</td>'
              + '<td>' + esc(u.role) + '</td>'
              + '<td><span class="badge ' + bc + '">' + st + '</span></td>'
              + '<td>—</td>'
              + '</tr>';
          }
          tbody.innerHTML = html;
        })
        .catch(function() {
          document.getElementById('userOverviewBody').innerHTML =
            '<tr><td colspan="4" style="text-align:center;padding:1.5rem;color:#888;">No user data available.</td></tr>';
        });
    }

    /* ============================================================
       GENERATE REPORT — PDF export using jsPDF + AutoTable
    ============================================================ */

    var includeBookings = true;
    var includeUsers    = true;

    /* Toggle checkbox options */
    window.toggleOption = function(type) {
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

    /* Open / close modal */
    document.getElementById('generateReportBtn').addEventListener('click', function() {
      document.getElementById('reportStatus').textContent = '';
      document.getElementById('reportModal').classList.add('open');
    });
    document.getElementById('closeReportBtn').addEventListener('click', function() {
      document.getElementById('reportModal').classList.remove('open');
    });
    document.getElementById('reportModal').addEventListener('click', function(e) {
      if (e.target === this) this.classList.remove('open');
    });

    /* ── Build and download PDF ── */
    document.getElementById('downloadPdfBtn').addEventListener('click', function() {
      if (!includeBookings && !includeUsers) {
        document.getElementById('reportStatus').textContent = 'Please select at least one report type.';
        return;
      }

      var btn = document.getElementById('downloadPdfBtn');
      btn.disabled    = true;
      btn.textContent = 'Generating...';
      document.getElementById('reportStatus').textContent = 'Fetching data...';

      var promises = [];
      if (includeBookings) promises.push(fetch('api/bookings').then(function(r) { return r.json(); }));
      else promises.push(Promise.resolve(null));

      if (includeUsers) promises.push(fetch('api/users').then(function(r) { return r.json(); }));
      else promises.push(Promise.resolve(null));

      Promise.all(promises)
        .then(function(results) {
          var bookingsData = results[0];
          var usersData    = results[1];

          document.getElementById('reportStatus').textContent = 'Building PDF...';

          /* Init jsPDF */
          var doc = new window.jspdf.jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
          var pageW  = doc.internal.pageSize.getWidth();
          var today  = new Date().toLocaleDateString('en-ZA', { year: 'numeric', month: 'long', day: 'numeric' });
          var y      = 15;

          /* ── Header banner ── */
          doc.setFillColor(37, 99, 235);
          doc.rect(0, 0, pageW, 28, 'F');
          doc.setTextColor(255, 255, 255);
          doc.setFontSize(18);
          doc.setFont('helvetica', 'bold');
          doc.text('EBS Admin Report', 14, 12);
          doc.setFontSize(9);
          doc.setFont('helvetica', 'normal');
          doc.text('Generated: ' + today, 14, 20);
          doc.text('Electronic Booking System', pageW - 14, 20, { align: 'right' });

          y = 38;
          doc.setTextColor(30, 30, 30);

          /* ── BOOKINGS SECTION ── */
          if (includeBookings && bookingsData) {
            var bookings = bookingsData.bookings || [];

            doc.setFontSize(13);
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(37, 99, 235);
            doc.text('Bookings Report', 14, y);
            y += 2;

            doc.setDrawColor(37, 99, 235);
            doc.setLineWidth(0.5);
            doc.line(14, y, pageW - 14, y);
            y += 6;

            doc.setTextColor(30, 30, 30);
            doc.setFontSize(9);
            doc.setFont('helvetica', 'normal');
            doc.text('Total bookings: ' + bookings.length, 14, y);
            y += 5;

            if (bookings.length === 0) {
              doc.setTextColor(150, 150, 150);
              doc.text('No bookings found.', 14, y);
              y += 10;
            } else {
              var bookingRows = bookings.map(function(b) {
                return [
                  b.student_name || b.student_email || '—',
                  b.lab_name     || '—',
                  b.seat_label   || b.seat_id || '—',
                  b.booking_date || '—',
                  b.status       || '—'
                ];
              });

              doc.autoTable({
                startY: y,
                head: [['Student', 'Lab', 'Seat', 'Date', 'Status']],
                body: bookingRows,
                theme: 'striped',
                headStyles: {
                  fillColor: [37, 99, 235],
                  textColor: 255,
                  fontStyle: 'bold',
                  fontSize: 9
                },
                bodyStyles: { fontSize: 8.5 },
                alternateRowStyles: { fillColor: [239, 246, 255] },
                columnStyles: {
                  0: { cellWidth: 42 },
                  1: { cellWidth: 30 },
                  2: { cellWidth: 22 },
                  3: { cellWidth: 35 },
                  4: { cellWidth: 25 }
                },
                margin: { left: 14, right: 14 },
                didDrawCell: function(data) {
                  if (data.section === 'body' && data.column.index === 4) {
                    var status = (data.cell.raw || '').toString();
                    var color  = status === 'Approved' ? [22, 163, 74]
                               : status === 'Pending'  ? [217, 119, 6]
                               : [220, 38, 38];
                    doc.setTextColor(color[0], color[1], color[2]);
                    doc.setFontSize(8);
                    doc.setFont('helvetica', 'bold');
                    doc.text(status, data.cell.x + data.cell.width / 2, data.cell.y + data.cell.height / 2 + 1, { align: 'center' });
                    doc.setTextColor(30, 30, 30);
                    doc.setFont('helvetica', 'normal');
                  }
                }
              });

              y = doc.lastAutoTable.finalY + 12;
            }
          }

          /* ── USERS SECTION ── */
          if (includeUsers && usersData) {
            var users = usersData.users || [];

            /* Start new page if not enough space */
            if (y > 220) { doc.addPage(); y = 20; }

            doc.setFontSize(13);
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(37, 99, 235);
            doc.text('Users Report', 14, y);
            y += 2;

            doc.setDrawColor(37, 99, 235);
            doc.setLineWidth(0.5);
            doc.line(14, y, pageW - 14, y);
            y += 6;

            doc.setTextColor(30, 30, 30);
            doc.setFontSize(9);
            doc.setFont('helvetica', 'normal');

            var activeCount = users.filter(function(u) { return !u.is_banned; }).length;
            var bannedCount = users.filter(function(u) { return  u.is_banned; }).length;
            doc.text('Total users: ' + users.length + '   |   Active: ' + activeCount + '   |   Banned: ' + bannedCount, 14, y);
            y += 5;

            if (users.length === 0) {
              doc.setTextColor(150, 150, 150);
              doc.text('No users found.', 14, y);
              y += 10;
            } else {
              var userRows = users.map(function(u) {
                var name = u.full_name || (u.email ? u.email.split('@')[0] : '—');
                return [
                  name,
                  u.email  || '—',
                  u.role   || '—',
                  u.is_banned ? 'Banned' : 'Active'
                ];
              });

              doc.autoTable({
                startY: y,
                head: [['Name', 'Email', 'Role', 'Status']],
                body: userRows,
                theme: 'striped',
                headStyles: {
                  fillColor: [37, 99, 235],
                  textColor: 255,
                  fontStyle: 'bold',
                  fontSize: 9
                },
                bodyStyles: { fontSize: 8.5 },
                alternateRowStyles: { fillColor: [239, 246, 255] },
                columnStyles: {
                  0: { cellWidth: 45 },
                  1: { cellWidth: 65 },
                  2: { cellWidth: 25 },
                  3: { cellWidth: 25 }
                },
                margin: { left: 14, right: 14 },
                didDrawCell: function(data) {
                  if (data.section === 'body' && data.column.index === 3) {
                    var status = (data.cell.raw || '').toString();
                    var color  = status === 'Active' ? [22, 163, 74] : [220, 38, 38];
                    doc.setTextColor(color[0], color[1], color[2]);
                    doc.setFontSize(8);
                    doc.setFont('helvetica', 'bold');
                    doc.text(status, data.cell.x + data.cell.width / 2, data.cell.y + data.cell.height / 2 + 1, { align: 'center' });
                    doc.setTextColor(30, 30, 30);
                    doc.setFont('helvetica', 'normal');
                  }
                }
              });
            }
          }

          /* ── Footer on every page ── */
          var totalPages = doc.internal.getNumberOfPages();
          for (var p = 1; p <= totalPages; p++) {
            doc.setPage(p);
            doc.setFontSize(8);
            doc.setTextColor(150);
            doc.setFont('helvetica', 'normal');
            doc.text('EBS Admin System — Confidential', 14, doc.internal.pageSize.getHeight() - 8);
            doc.text('Page ' + p + ' of ' + totalPages, pageW - 14, doc.internal.pageSize.getHeight() - 8, { align: 'right' });
          }

          /* ── Save ── */
          var filename = 'EBS_Report_' + new Date().toISOString().slice(0, 10) + '.pdf';
          doc.save(filename);

          document.getElementById('reportStatus').textContent = 'Report downloaded successfully!';
          document.getElementById('reportModal').classList.remove('open');
        })
        .catch(function(err) {
          console.error(err);
          document.getElementById('reportStatus').textContent = 'Failed to fetch data. Please try again.';
        })
        .finally(function() {
          btn.disabled    = false;
          btn.textContent = '⬇ Download PDF';
        });
    });

    /* ---- Init ---- */
    document.addEventListener('DOMContentLoaded', function() {
      loadStats();
      loadRecentBookings();
      loadUserOverview();
    });
  })();
  </script>

  <script src="../js/admin.js"></script>
</body>
</html>
