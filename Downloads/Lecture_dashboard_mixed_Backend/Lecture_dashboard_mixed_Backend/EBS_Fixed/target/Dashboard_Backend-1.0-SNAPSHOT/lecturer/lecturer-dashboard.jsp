<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lecturer Dashboard</title>
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
                <h1>Lecturer Dashboard</h1>
                <p>Track weekly lab blocks and lecturer reservations</p>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/lecturer/block-lab.jsp" class="primary-btn">+ Create New Block</a>
            </div>
        </section>

        <section class="stats-grid">
            <div class="stat-card">
                <h3>This Week's Blocks</h3>
                <p class="stat-number" id="thisWeekBlocks">6</p>
                <span class="stat-note">Scheduled sessions</span>
            </div>

            <div class="stat-card">
                <h3>Today's Sessions</h3>
                <p class="stat-number" id="todaySessions">2</p>
                <span class="stat-note success-text">Lecturer activities</span>
            </div>

            <div class="stat-card">
                <h3>Pending Requests</h3>
                <p class="stat-number" id="pendingRequests">1</p>
                <span class="stat-note warning-text">Needs attention</span>
            </div>

            <div class="stat-card">
                <h3>Available Labs</h3>
                <p class="stat-number" id="availableLabs">9</p>
                <span class="stat-note">Open for reservation</span>
            </div>
        </section>

        <section class="lecturer-layout">
            <div class="panel">
                <div class="panel-header">
                    <div>
                        <h2>Calendar Week View</h2>
                        <p class="calendar-subtext">Overview of your upcoming lab blocks</p>
                    </div>
                </div>

                <div class="week-calendar">
                    <div class="week-grid">

                        <div class="day-card today">
                            <div class="day-header">
                                <h3>Monday</h3>
                                <p>23 Mar 2026</p>
                            </div>
                            <div class="session-list">
                                <div class="session blocked">
                                    <strong>CSC211 Practical</strong>
                                    <span>Lab 1 • C4 Building</span>
                                    <span>08:00 - 10:00</span>
                                    <em>Blocked</em>
                                </div>
                                <div class="session">
                                    <strong>ICT221 Tutorial</strong>
                                    <span>Lab 3 • B1 Building</span>
                                    <span>11:00 - 13:00</span>
                                    <em>Upcoming</em>
                                </div>
                            </div>
                        </div>

                        <div class="day-card">
                            <div class="day-header">
                                <h3>Tuesday</h3>
                                <p>24 Mar 2026</p>
                            </div>
                            <div class="session-list">
                                <div class="session">
                                    <strong>BIT121 Session</strong>
                                    <span>Lab 5 • Library</span>
                                    <span>10:00 - 12:00</span>
                                    <em>Upcoming</em>
                                </div>
                            </div>
                        </div>

                        <div class="day-card">
                            <div class="day-header">
                                <h3>Wednesday</h3>
                                <p>25 Mar 2026</p>
                            </div>
                            <div class="session-list">
                                <div class="session pending">
                                    <strong>CSC315 Practical</strong>
                                    <span>Lab 2 • C4 Building</span>
                                    <span>09:00 - 11:00</span>
                                    <em>Pending</em>
                                </div>
                                <div class="session">
                                    <strong>ICT123 Lab Session</strong>
                                    <span>Lab 4 • B1 Building</span>
                                    <span>13:00 - 15:00</span>
                                    <em>Upcoming</em>
                                </div>
                            </div>
                        </div>

                        <div class="day-card">
                            <div class="day-header">
                                <h3>Thursday</h3>
                                <p>26 Mar 2026</p>
                            </div>
                            <div class="session-list">
                                <div class="session">
                                    <strong>Database Test Setup</strong>
                                    <span>Lab 1 • C4 Building</span>
                                    <span>12:00 - 14:00</span>
                                    <em>Upcoming</em>
                                </div>
                            </div>
                        </div>

                        <div class="day-card">
                            <div class="day-header">
                                <h3>Friday</h3>
                                <p>27 Mar 2026</p>
                            </div>
                            <div class="session-list">
                                <div class="session">
                                    <strong>Make-up Practical</strong>
                                    <span>Lab 3 • B1 Building</span>
                                    <span>09:00 - 11:00</span>
                                    <em>Upcoming</em>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="panel-header section-gap">
                    <div>
                        <h2>Upcoming Blocks</h2>
                        <p class="calendar-subtext">Detailed lecturer reservations</p>
                    </div>
                </div>

                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Module</th>
                                <th>Building</th>
                                <th>Lab</th>
                                <th>Date</th>
                                <th>Time</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="upcomingBlocksTable">
                            <tr>
                                <td>CSC211 Practical</td>
                                <td>C4</td>
                                <td>Lab 1</td>
                                <td>23 Mar 2026</td>
                                <td>08:00 - 10:00</td>
                                <td><span class="badge danger">Blocked</span></td>
                            </tr>
                            <tr>
                                <td>ICT221 Tutorial</td>
                                <td>B1</td>
                                <td>Lab 3</td>
                                <td>23 Mar 2026</td>
                                <td>11:00 - 13:00</td>
                                <td><span class="badge success">Upcoming</span></td>
                            </tr>
                            <tr>
                                <td>CSC315 Practical</td>
                                <td>C4</td>
                                <td>Lab 2</td>
                                <td>25 Mar 2026</td>
                                <td>09:00 - 11:00</td>
                                <td><span class="badge warning">Pending</span></td>
                            </tr>
                            <tr>
                                <td>Database Test Setup</td>
                                <td>C4</td>
                                <td>Lab 1</td>
                                <td>26 Mar 2026</td>
                                <td>12:00 - 14:00</td>
                                <td><span class="badge success">Upcoming</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="side-stack">
                <div class="panel">
                    <div class="panel-header">
                        <h2>Quick Actions</h2>
                    </div>
                    <div class="quick-actions">
                        <a href="${pageContext.request.contextPath}/lecturer/block-lab.jsp" class="action-btn lecturer-action-link">Create Full Lab Block</a>
                        <a href="${pageContext.request.contextPath}/lecturer/view-bookings.jsp" class="action-btn lecturer-action-link">Check Reservations</a>
                        <a href="${pageContext.request.contextPath}/lecturer/view-bookings.jsp" class="action-btn lecturer-action-link">Review Pending Blocks</a>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-header">
                        <h2>Lecturer Notes</h2>
                    </div>
                    <div class="status-list">
                        <div class="status-item">
                            <span>Reserved labs today</span>
                            <span class="badge success">2</span>
                        </div>
                        <div class="status-item">
                            <span>Pending requests</span>
                            <span class="badge warning">1</span>
                        </div>
                        <div class="status-item">
                            <span>Conflicts detected</span>
                            <span class="badge danger">0</span>
                        </div>
                    </div>
                </div>
            </div>

        </section>

    </main>

                    <script src="${pageContext.request.contextPath}/js/lecturer.js"></script>
</body>
</html>