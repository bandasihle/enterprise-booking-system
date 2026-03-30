<%-- 
    Document   : resource
    Created on : 29 Mar 2026, 22:25:38
    Author     : axole
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Resources</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
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
        <h1>Resources</h1>
        <p>Manage labs, seats, and computer availability</p>
      </div>

      <div class="topbar-right">
        <button class="primary-btn">+ Add Lab</button>
      </div>
    </header>

    <section class="resource-grid">
      <div class="resource-card">
        <h3>Lab 1</h3>
        <p>40 PCs available</p>
        <span class="badge success">Active</span>
      </div>

      <div class="resource-card">
        <h3>Lab 2</h3>
        <p>35 PCs available</p>
        <span class="badge success">Active</span>
      </div>

      <div class="resource-card">
        <h3>Lab 3</h3>
        <p>28 PCs available</p>
        <span class="badge success">Active</span>
      </div>

      <div class="resource-card">
        <h3>Lab 4</h3>
        <p>0 PCs available</p>
        <span class="badge warning">Maintenance</span>
      </div>
    </section>

    <section class="panel">
      <div class="panel-header">
        <h2>Lab Resource Table</h2>
        <button class="panel-btn">Update Status</button>
      </div>

      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Lab</th>
              <th>Total PCs</th>
              <th>Available</th>
              <th>Booked</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Lab 1</td>
              <td>50</td>
              <td>40</td>
              <td>10</td>
              <td><span class="badge success">Active</span></td>
              <td><button class="table-btn">Edit</button></td>
            </tr>
            <tr>
              <td>Lab 2</td>
              <td>45</td>
              <td>35</td>
              <td>10</td>
              <td><span class="badge success">Active</span></td>
              <td><button class="table-btn">Edit</button></td>
            </tr>
            <tr>
              <td>Lab 3</td>
              <td>30</td>
              <td>28</td>
              <td>2</td>
              <td><span class="badge success">Active</span></td>
              <td><button class="table-btn">Edit</button></td>
            </tr>
            <tr>
              <td>Lab 4</td>
              <td>35</td>
              <td>0</td>
              <td>0</td>
              <td><span class="badge warning">Maintenance</span></td>
              <td><button class="table-btn">Edit</button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>

  <script src="js/admin.js"></script>
</body>
</html>

