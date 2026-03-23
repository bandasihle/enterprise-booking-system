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
        <a href="index.jsp" class="nav-item active">Dashboard</a>
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
        <p class="stat-number">1,248</p>
        <span class="stat-note">+12 this week</span>
      </div>

      <div class="stat-card">
        <h3>Total Bookings</h3>
        <p class="stat-number">326</p>
        <span class="stat-note">Today’s bookings</span>
      </div>

      <div class="stat-card">
        <h3>Available Labs</h3>
        <p class="stat-number">08</p>
        <span class="stat-note success-text">Operational</span>
      </div>

      <div class="stat-card">
        <h3>Complaints</h3>
        <p class="stat-number">14</p>
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
            <tbody>
              <tr>
                <td>Zwivhuya N.</td>
                <td>Lab 1</td>
                <td>A12</td>
                <td>07 Mar 2026</td>
                <td><span class="badge success">Approved</span></td>
              </tr>
              <tr>
                <td>Lerato M.</td>
                <td>Lab 2</td>
                <td>B05</td>
                <td>07 Mar 2026</td>
                <td><span class="badge warning">Pending</span></td>
              </tr>
              <tr>
                <td>Thabo K.</td>
                <td>Lab 3</td>
                <td>C08</td>
                <td>07 Mar 2026</td>
                <td><span class="badge success">Approved</span></td>
              </tr>
              <tr>
                <td>Ayanda P.</td>
                <td>Lab 1</td>
                <td>D02</td>
                <td>07 Mar 2026</td>
                <td><span class="badge danger">Cancelled</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <h2>Quick Actions</h2>
        </div>

        <div class="quick-actions">
          <button class="action-btn">Add User</button>
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
            <tbody>
              <tr>
                <td>Admin One</td>
                <td>Administrator</td>
                <td><span class="badge success">Active</span></td>
                <td>Today, 10:20</td>
              </tr>
              <tr>
                <td>Ntsako M.</td>
                <td>Student</td>
                <td><span class="badge success">Active</span></td>
                <td>Today, 09:40</td>
              </tr>
              <tr>
                <td>Refilwe T.</td>
                <td>Student</td>
                <td><span class="badge warning">Offline</span></td>
                <td>Yesterday</td>
              </tr>
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
          <div class="status-item">
            <span>Notifications</span>
            <span class="badge success">Running</span>
          </div>
        </div>
      </div>
    </section>
  </main>

  <script src="js/admin.js"></script>
</body>
</html>
