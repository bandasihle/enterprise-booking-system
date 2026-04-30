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
        <a href="dashboard.jsp" class="nav-item">Dashboard</a>
        <a href="users.jsp" class="nav-item">Users</a>
        <a href="bookings.jsp" class="nav-item active">Bookings</a>
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
    <header class="topbar">
      <div>
        <h1>Bookings</h1>
        <p>Track and manage all seat bookings</p>
      </div>
      <div class="topbar-right">
        <input type="text" class="search-box" placeholder="Search bookings..." />
      </div>
    </header>

    <section class="stats-grid three-grid">
      <div class="stat-card">
        <h3>Approved</h3>
        <p class="stat-number" id="approvedCount">—</p>
        <span class="stat-note success-text">Confirmed seats</span>
      </div>
      <div class="stat-card">
        <h3>Pending</h3>
        <p class="stat-number" id="pendingCount">—</p>
        <span class="stat-note warning-text">Awaiting action</span>
      </div>
      <div class="stat-card">
        <h3>Cancelled</h3>
        <p class="stat-number" id="cancelledCount">—</p>
        <span class="stat-note danger-text">Declined or removed</span>
      </div>
    </section>

    <section class="panel">
      <div class="panel-header">
        <h2>Booking Records</h2>
        <button class="panel-btn">Export</button>
      </div>
      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Student</th>
              <th>Lab</th>
              <th>Seat</th>
              <th>Date</th>
              <th>Time</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody id="bookingsTableBody">
            <tr><td colspan="7" style="text-align:center;padding:1.5rem;color:#888;">Loading...</td></tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>

  <script>
  (function () {
    function esc(s) { var d = document.createElement('div'); d.textContent = String(s || ''); return d.innerHTML; }

    function loadBookings() {
      fetch('../api/bookings')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var bookings = data.bookings || [];
          var approved = 0, pending = 0, cancelled = 0;
          for (var i = 0; i < bookings.length; i++) {
            // Force uppercase to prevent case-sensitivity bugs
            var s = (bookings[i].status || '').toUpperCase();
            
            // Map the database vocabulary to the UI cards
            if (s === 'APPROVED' || s === 'CONFIRMED') {
                approved++;
            } else if (s === 'PENDING') {
                pending++;
            } else if (s === 'CANCELLED' || s === 'NO_SHOW') {
                cancelled++;
            }
          }
          document.getElementById('approvedCount').textContent  = approved;
          document.getElementById('pendingCount').textContent   = pending;
          document.getElementById('cancelledCount').textContent = cancelled;

          var tbody = document.getElementById('bookingsTableBody');
          if (!bookings.length) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:1.5rem;color:#888;">No bookings found.</td></tr>';
            return;
          }
          
          var html = '';
          for (var j = 0; j < bookings.length; j++) {
            var b  = bookings[j];
            var sUpper = (b.status || '').toUpperCase();
            
            // Fix the badge colors to match the new vocabulary
            var bc = (sUpper === 'APPROVED' || sUpper === 'CONFIRMED') ? 'success' : 
                     (sUpper === 'PENDING') ? 'warning' : 'danger';
            
            var btn = (sUpper === 'PENDING')
              ? '<button class="table-btn" data-id="' + b.id + '" data-action="approve">Approve</button>'
              : '<button class="table-btn" data-id="' + b.id + '" data-action="view">View</button>';
              
            html += '<tr>'
              + '<td>' + esc(b.student_name || b.student_email || '') + '</td>'
              + '<td>' + esc(b.lab_name || '') + '</td>'
              + '<td>' + esc(b.seat_label || b.seat_id || '') + '</td>'
              + '<td>' + esc(b.booking_date || '') + '</td>'
              + '<td>' + esc(b.booking_time || '') + '</td>'
              + '<td><span class="badge ' + bc + '">' + esc(b.status) + '</span></td>'
              + '<td>' + btn + '</td>'
              + '</tr>';
          }
          tbody.innerHTML = html;

          tbody.addEventListener('click', function(e) {
            var btn = e.target.closest('[data-action]');
            if (!btn) return;
            if (btn.dataset.action === 'approve') {
              fetch('../api/bookings/approve', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: '{"id":' + btn.dataset.id + '}'
              }).then(function(r){ return r.json(); })
                .then(function(res){ if (res.success) loadBookings(); else alert(res.message || 'Failed'); })
                .catch(function(){ alert('Server error.'); });
            } else {
              var row = btn.closest('tr');
              alert('Student: ' + row.cells[0].textContent + '\nLab: ' + row.cells[1].textContent + '\nSeat: ' + row.cells[2].textContent + '\nDate: ' + row.cells[3].textContent + '\nStatus: ' + row.cells[5].textContent.trim());
            }
          });
        })
        .catch(function() {
          document.getElementById('bookingsTableBody').innerHTML =
            '<tr><td colspan="7" style="text-align:center;padding:1.5rem;color:#c00;">Could not load bookings. Check that BookingServlet is deployed.</td></tr>';
        });
    }

    document.addEventListener('DOMContentLoaded', loadBookings);
  })();
  </script>

  <script src="../js/admin.js"></script>
</body>
</html>
