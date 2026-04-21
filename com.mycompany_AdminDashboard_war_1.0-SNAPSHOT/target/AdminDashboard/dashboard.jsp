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

  <link rel="stylesheet" href="css/admin.css">
</head>
<body>

  <header class="top-navbar">
    <div class="nav-left">
      <div class="brand">
        <div class="brand-icon">
          <img src="images/logooo.jpeg" alt="EBS Logo">
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
          <button class="action-btn">Generate Report</button>
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

      <div class="panel">
        <div class="panel-header">
          <h2>System Status</h2>
        </div>
        <div class="status-list">
          <div class="status-item">
            <span>Server</span>
            <span class="badge success">Online</span>
          </div>
          <div class="status-item">
            <span>Database</span>
            <span class="badge success">Connected</span>
          </div>
          <div class="status-item">
            <span>Lab 4</span>
            <span class="badge warning">Maintenance</span>
          </div>
          
        </div>
      </div>
    </section>
  </main>

  <script>
  (function () {
    function esc(s) { var d = document.createElement('div'); d.textContent = String(s || ''); return d.innerHTML; }

    /* ---- STAT CARDS ---- */
    function loadStats() {
      fetch('api/admin/dashboard')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          document.getElementById('totalUsers').textContent     = data.totalUsers      || 0;
          document.getElementById('totalBookings').textContent  = data.totalBookings   || 0;
          document.getElementById('availableLabs').textContent  = data.availableLabs   || 0;
          document.getElementById('totalComplaints').textContent = data.totalComplaints || 0;
        })
        .catch(function() {
          /* silently leave — admin.js also tries this endpoint */
        });
    }

    /* ---- RECENT BOOKINGS (latest 5) ---- */
    function loadRecentBookings() {
      fetch('api/bookings')
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
            var bc = b.status === 'Approved' ? 'success'
                   : b.status === 'Pending'  ? 'warning'
                   : 'danger';
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
      fetch('api/users')
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

    document.addEventListener('DOMContentLoaded', function() {
      loadStats();
      loadRecentBookings();
      loadUserOverview();
    });
  })();
  </script>

  <script src="js/admin.js"></script>
</body>
</html>
