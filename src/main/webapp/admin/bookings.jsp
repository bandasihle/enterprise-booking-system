<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Bookings</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/admin.css" />
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
        <a href="dashboard.jsp"   class="nav-item">Dashboard</a>
        <a href="users.jsp"       class="nav-item">Users</a>
        <a href="bookings.jsp"    class="nav-item active">Bookings</a>
        <a href="resources.jsp"   class="nav-item">Resources</a>
        <a href="complaints.jsp"  class="nav-item">Complaints</a>
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
    <header class="topbar">
      <div>
        <h1>Bookings</h1>
        <p>All student seat reservations and lecturer lab blocks</p>
      </div>
      <div class="topbar-right">
        <input type="text" id="searchInput" class="search-box" placeholder="Search bookings..." oninput="filterTable()" />
      </div>
    </header>

    <%-- ── Stats row (counts both booking types) ── --%>
    <section class="stats-grid three-grid">
      <div class="stat-card">
        <h3>Approved / Confirmed</h3>
        <p class="stat-number" id="approvedCount">—</p>
        <span class="stat-note success-text">Students approved + Lecturer blocks</span>
      </div>
      <div class="stat-card">
        <h3>Pending</h3>
        <p class="stat-number" id="pendingCount">—</p>
        <span class="stat-note warning-text">Awaiting action</span>
      </div>
      <div class="stat-card">
        <h3>Cancelled / No-show</h3>
        <p class="stat-number" id="cancelledCount">—</p>
        <span class="stat-note danger-text">Declined or removed</span>
      </div>
    </section>

    <%-- ── Unified bookings table ── --%>
    <section class="panel">
      <div class="panel-header">
        <h2>Booking Records</h2>
        <%-- Export CSV: downloads all bookings (including hidden filtered rows) --%>
        <button class="panel-btn" onclick="exportCSV()">Export CSV</button>
      </div>
      <div class="table-wrapper">
        <table id="bookingsTable">
          <thead>
            <tr>
              <th>Type</th>
              <th>Name</th>
              <th>Lab</th>
              <th>Seat / Module</th>
              <th>Date</th>
              <th>Time</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody id="bookingsTableBody">
            <tr>
              <td colspan="8" style="text-align:center;padding:1.5rem;color:#888;">Loading…</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>

  <script>
  (function () {

    /* ── Tiny XSS-safe escaper ── */
    function esc(s) {
      var d = document.createElement('div');
      d.textContent = String(s || '');
      return d.innerHTML;
    }

    /* ── Keep a copy of all booking data for clean CSV export ── */
    var allBookings = [];

    /* ── Build a coloured badge from raw status string ── */
    function statusBadge(rawStatus) {
      var s  = (rawStatus || '').toUpperCase();
      var cls = (s === 'APPROVED' || s === 'CONFIRMED') ? 'success'
              : (s === 'PENDING')                       ? 'warning'
              :                                           'danger';
      var label = (s === 'NO_SHOW') ? 'Not confirmed' : rawStatus;
      return '<span class="badge ' + cls + '">' + esc(label) + '</span>';
    }

    /* ── Render the type badge (STUDENT vs LECTURER) ── */
    function typeBadge(type) {
      return (type === 'LECTURER')
        ? '<span class="badge" style="background:#5b6af7;color:#fff;">Lecturer</span>'
        : '<span class="badge" style="background:#0ea5e9;color:#fff;">Student</span>';
    }

    /* ── Main data load ── */
    function loadBookings() {
      fetch('../api/bookings')
        .then(function (r) {
          if (!r.ok) throw new Error('HTTP ' + r.status);
          return r.json();
        })
        .then(function (data) {
          allBookings = data.bookings || [];
          var approved = 0, pending = 0, cancelled = 0;

          for (var i = 0; i < allBookings.length; i++) {
            var s = (allBookings[i].status || '').toUpperCase();
            if (s === 'APPROVED' || s === 'CONFIRMED')  { approved++;  }
            else if (s === 'PENDING')                    { pending++;   }
            else                                         { cancelled++; }
          }

          document.getElementById('approvedCount').textContent  = approved;
          document.getElementById('pendingCount').textContent   = pending;
          document.getElementById('cancelledCount').textContent = cancelled;

          var tbody = document.getElementById('bookingsTableBody');

          if (!allBookings.length) {
            tbody.innerHTML =
              '<tr><td colspan="8" style="text-align:center;padding:1.5rem;color:#888;">' +
              'No bookings found.</td></tr>';
            return;
          }

          var html = '';
          for (var j = 0; j < allBookings.length; j++) {
            var b    = allBookings[j];
            var type = b.booking_type || 'STUDENT';
            var sUp  = (b.status || '').toUpperCase();

            var actionBtn = (sUp === 'PENDING' && type === 'STUDENT')
              ? '<button class="table-btn" data-id="'   + b.id + '" data-action="approve">Approve</button>'
              : '<button class="table-btn secondary" data-id="' + b.id + '" data-type="' + type + '" data-action="view">View</button>';

            html += '<tr>'
              + '<td>'  + typeBadge(type)                      + '</td>'
              + '<td>'  + esc(b.user_name  || b.user_email || '') + '</td>'
              + '<td>'  + esc(b.lab_name   || '')               + '</td>'
              + '<td>'  + esc(b.seat_label || '')               + '</td>'
              + '<td>'  + esc(b.booking_date || '')             + '</td>'
              + '<td>'  + esc(b.booking_time || '')             + '</td>'
              + '<td>'  + statusBadge(b.status)                 + '</td>'
              + '<td>'  + actionBtn                             + '</td>'
              + '</tr>';
          }
          tbody.innerHTML = html;

          tbody.addEventListener('click', function (e) {
            var btn = e.target.closest('[data-action]');
            if (!btn) return;

            if (btn.dataset.action === 'approve') {
              fetch('../api/bookings/approve', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: '{\"id\":' + btn.dataset.id + '}'
              })
              .then(function (r) { return r.json(); })
              .then(function (res) {
                if (res.success) { loadBookings(); }
                else             { alert(res.message || 'Approval failed.'); }
              })
              .catch(function () { alert('Server error during approval.'); });

            } else {
              var row = btn.closest('tr');
              alert(
                'Type:     ' + row.cells[0].textContent.trim() + '\n' +
                'Name:     ' + row.cells[1].textContent        + '\n' +
                'Lab:      ' + row.cells[2].textContent        + '\n' +
                'Seat/Mod: ' + row.cells[3].textContent        + '\n' +
                'Date:     ' + row.cells[4].textContent        + '\n' +
                'Time:     ' + row.cells[5].textContent        + '\n' +
                'Status:   ' + row.cells[6].textContent.trim()
              );
            }
          });
        })
        .catch(function (err) {
          document.getElementById('bookingsTableBody').innerHTML =
            '<tr><td colspan="8" style="text-align:center;padding:1.5rem;color:#c00;">' +
            'Could not load bookings — ' + err.message + '</td></tr>';
        });
    }

    /* ── Live search / filter ── */
    window.filterTable = function () {
      var term  = document.getElementById('searchInput').value.toLowerCase();
      var rows  = document.querySelectorAll('#bookingsTableBody tr');
      rows.forEach(function (row) {
        row.style.display = row.textContent.toLowerCase().includes(term) ? '' : 'none';
      });
    };

    /* ── CSV export — uses raw data array, not DOM, so it's always complete ── */
    window.exportCSV = function () {
      if (!allBookings.length) {
        alert('No booking data to export.');
        return;
      }

      var headers = ['Type','Name','Lab','Seat / Module','Date','Time','Status'];
      var rows    = [headers];

      for (var i = 0; i < allBookings.length; i++) {
        var b    = allBookings[i];
        var type = b.booking_type || 'STUDENT';
        rows.push([
          type,
          b.user_name  || b.user_email || '',
          b.lab_name   || '',
          b.seat_label || '',
          b.booking_date || '',
          b.booking_time || '',
          b.status || ''
        ]);
      }

      var csv = rows.map(function (row) {
        return row.map(function (cell) {
          return '"' + String(cell).replace(/"/g, '""') + '"';
        }).join(',');
      }).join('\n');

      /* Build a dated filename: bookings-2026-05-02.csv */
      var today    = new Date();
      var dateStr  = today.getFullYear() + '-'
                   + String(today.getMonth() + 1).padStart(2, '0') + '-'
                   + String(today.getDate()).padStart(2, '0');

      var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
      var a    = document.createElement('a');
      a.href   = URL.createObjectURL(blob);
      a.download = 'bookings-' + dateStr + '.csv';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(a.href);
    };

    document.addEventListener('DOMContentLoaded', loadBookings);
  })();
  </script>

  <script src="../js/admin.js"></script>
</body>
</html>
