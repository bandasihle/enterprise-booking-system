<%-- 
    Document   : complaints
    Created on : 29 Mar 2026, 22:24:32
    Author     : axole
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Complaints</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="css/admin.css" />
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
        <a href="dashboard.jsp" class="nav-item">Dashboard</a>
        <a href="users.jsp" class="nav-item active">Users</a>
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

    <header class="topbar">
      <div>
        <h1>Complaints</h1>
        <p>Review complaints and system issues</p>
      </div>

      <div class="topbar-right">
        <input type="text" class="search-box" placeholder="Search complaints..." />
      </div>
    </header>

    <section class="stats-grid three-grid">

      <div class="stat-card">
        <h3>Open Cases</h3>
        <p class="stat-number">14</p>
        <span class="stat-note danger-text">Need response</span>
      </div>

      <div class="stat-card">
        <h3>Resolved</h3>
        <p class="stat-number">32</p>
        <span class="stat-note success-text">Closed successfully</span>
      </div>

      <div class="stat-card">
        <h3>In Progress</h3>
        <p class="stat-number">6</p>
        <span class="stat-note warning-text">Currently handled</span>
      </div>

    </section>

    <section class="panel">

      <div class="panel-header">
        <h2>Complaint List</h2>
        <button class="panel-btn">Resolve Selected</button>
      </div>

      <div class="table-wrapper">

        <table>
          <thead>
            <tr>
              <th>Student</th>
              <th>Issue</th>
              <th>Category</th>
              <th>Date</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>

          <tbody>

            <tr>
              <td>Zwivhuya N.</td>
              <td>Seat was already occupied</td>
              <td>Booking</td>
              <td>07 Mar 2026</td>
              <td><span class="badge warning">Open</span></td>
              <td><button class="table-btn">Review</button></td>
            </tr>

            <tr>
              <td>Lerato M.</td>
              <td>System login failed</td>
              <td>Authentication</td>
              <td>06 Mar 2026</td>
              <td><span class="badge danger">Urgent</span></td>
              <td><button class="table-btn">Review</button></td>
            </tr>

            <tr>
              <td>Thabo K.</td>
              <td>Computer not working</td>
              <td>Hardware</td>
              <td>05 Mar 2026</td>
              <td><span class="badge success">Resolved</span></td>
              <td><button class="table-btn">View</button></td>
            </tr>

            <tr>
              <td>Ayanda P.</td>
              <td>Booking disappeared</td>
              <td>System</td>
              <td>05 Mar 2026</td>
              <td><span class="badge warning">In Progress</span></td>
              <td><button class="table-btn">Review</button></td>
            </tr>

          </tbody>
        </table>

      </div>
    </section>

  </main>

  <script src="js/admin.js"></script>

</body>
</html>
