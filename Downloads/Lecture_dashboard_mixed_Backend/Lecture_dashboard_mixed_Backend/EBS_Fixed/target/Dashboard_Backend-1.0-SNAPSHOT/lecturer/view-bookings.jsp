<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Bookings</title>
   <link rel="stylesheet" href="${pageContext.request.contextPath}/lecturer/lecturer.css">
</head>
<body>

  <header class="top-navbar">
    <div class="nav-left">
        <div class="brand">
            <div class="brand-icon">
                <img src="${pageContext.request.contextPath}/images/logooo.jpeg" alt="EBS Logo">
            </div>
            <div class="divider"></div>
            <div class="brand-text">EBS Lecturer</div>
        </div>
        
        <div class="nav-menu">
            <a href="${pageContext.request.contextPath}/lecturer/lecturer-dashboard.jsp" class="nav-item">Dashboard</a>
            <a href="${pageContext.request.contextPath}/lecturer/block-lab.jsp" class="nav-item">Block Lab</a>
            <a href="${pageContext.request.contextPath}/lecturer/view-bookings.jsp" class="nav-item">View Bookings</a>
        </div>
    </div>
    
    <div class="nav-right">
        <div class="search-wrap">
            <input type="text" class="search-box" placeholder="Search...">
        </div>
        <a href="#" class="right-link">Help</a>
        <a href="#" class="right-link">Sign out</a>
    </div>
</header>

    <main class="main-content">

        <section class="topbar">
            <div>
                <h1>View Bookings</h1>
                <p>Search, review, and manage lecturer lab reservations</p>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/lecturer/block-lab.jsp" class="primary-btn">+ Create New Block</a>
            </div>
        </section>

        <section class="stats-grid">
            <div class="stat-card">
                <h3>Total Bookings</h3>
                <p class="stat-number" id="totalBookings">12</p>
                <span class="stat-note">All lecturer reservations</span>
            </div>

            <div class="stat-card">
                <h3>Upcoming</h3>
                <p class="stat-number" id="upcomingCount">5</p>
                <span class="stat-note success-text">Future sessions</span>
            </div>

            <div class="stat-card">
                <h3>Pending</h3>
                <p class="stat-number" id="pendingCount">2</p>
                <span class="stat-note warning-text">Awaiting confirmation</span>
            </div>

            <div class="stat-card">
                <h3>Completed</h3>
                <p class="stat-number" id="completedCount">4</p>
                <span class="stat-note">Finished sessions</span>
            </div>
        </section>

        <section class="panel">
            <div class="panel-header">
                <h2>Booking Management</h2>

                <div class="lecturer-toolbar">
                    <input type="text" id="searchInput" class="users-search-box" placeholder="Search by module, lab, or building">
                    <select id="statusFilter" class="lecturer-select">
                        <option value="all">All Status</option>
                        <option value="Blocked">Blocked</option>
                        <option value="Upcoming">Upcoming</option>
                        <option value="Pending">Pending</option>
                        <option value="Completed">Completed</option>
                    </select>
                </div>
            </div>

            <div class="table-wrapper">
                <table id="bookingTable">
                    <thead>
                        <tr>
                            <th>Booking ID</th>
                            <th>Module</th>
                            <th>Building</th>
                            <th>Lab</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Status</th>
                            <th>Lecturer</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="bookingsTableBody">
                        <tr data-status="Blocked">
                            <td>LB001</td>
                            <td>CSC211 Practical</td>
                            <td>C4</td>
                            <td>Lab 1</td>
                            <td>2026-03-24</td>
                            <td>08:00 - 10:00</td>
                            <td><span class="badge danger">Blocked</span></td>
                            <td>Dr. Nkosi</td>
                            <td><button class="table-btn view-btn"
                                data-id="LB001"
                                data-module="CSC211 Practical"
                                data-building="C4"
                                data-lab="Lab 1"
                                data-date="2026-03-24"
                                data-time="08:00 - 10:00"
                                data-status="Blocked"
                                data-lecturer="Dr. Nkosi">View</button></td>
                        </tr>
                        <tr data-status="Upcoming">
                            <td>LB002</td>
                            <td>ICT221 Tutorial</td>
                            <td>B1</td>
                            <td>Lab 3</td>
                            <td>2026-03-24</td>
                            <td>11:00 - 13:00</td>
                            <td><span class="badge success">Upcoming</span></td>
                            <td>Dr. Nkosi</td>
                            <td><button class="table-btn view-btn"
                                data-id="LB002"
                                data-module="ICT221 Tutorial"
                                data-building="B1"
                                data-lab="Lab 3"
                                data-date="2026-03-24"
                                data-time="11:00 - 13:00"
                                data-status="Upcoming"
                                data-lecturer="Dr. Nkosi">View</button></td>
                        </tr>
                        <tr data-status="Pending">
                            <td>LB003</td>
                            <td>CSC315 Practical</td>
                            <td>C4</td>
                            <td>Lab 2</td>
                            <td>2026-03-25</td>
                            <td>09:00 - 11:00</td>
                            <td><span class="badge warning">Pending</span></td>
                            <td>Dr. Nkosi</td>
                            <td><button class="table-btn view-btn"
                                data-id="LB003"
                                data-module="CSC315 Practical"
                                data-building="C4"
                                data-lab="Lab 2"
                                data-date="2026-03-25"
                                data-time="09:00 - 11:00"
                                data-status="Pending"
                                data-lecturer="Dr. Nkosi">View</button></td>
                        </tr>
                        <tr data-status="Upcoming">
                            <td>LB004</td>
                            <td>BIT121 Session</td>
                            <td>Library</td>
                            <td>Lab 5</td>
                            <td>2026-03-26</td>
                            <td>10:00 - 12:00</td>
                            <td><span class="badge success">Upcoming</span></td>
                            <td>Dr. Nkosi</td>
                            <td><button class="table-btn view-btn"
                                data-id="LB004"
                                data-module="BIT121 Session"
                                data-building="Library"
                                data-lab="Lab 5"
                                data-date="2026-03-26"
                                data-time="10:00 - 12:00"
                                data-status="Upcoming"
                                data-lecturer="Dr. Nkosi">View</button></td>
                        </tr>
                        <tr data-status="Completed">
                            <td>LB005</td>
                            <td>Database Test Setup</td>
                            <td>C4</td>
                            <td>Lab 1</td>
                            <td>2026-03-20</td>
                            <td>12:00 - 14:00</td>
                            <td><span class="badge success">Completed</span></td>
                            <td>Dr. Nkosi</td>
                            <td><button class="table-btn view-btn"
                                data-id="LB005"
                                data-module="Database Test Setup"
                                data-building="C4"
                                data-lab="Lab 1"
                                data-date="2026-03-20"
                                data-time="12:00 - 14:00"
                                data-status="Completed"
                                data-lecturer="Dr. Nkosi">View</button></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

    </main>

 <!-- Add at the bottom of body -->
<script src="${pageContext.request.contextPath}/js/lecturer.js"></script>
</body>
</html>