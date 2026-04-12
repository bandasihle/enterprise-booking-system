<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Block Lab</title>
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
                <h1>Block Lab</h1>
                <p>Reserve a full lab for a practical, tutorial, or test session</p>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/lecturer/view-bookings.jsp" class="primary-btn">View Bookings</a>
            </div>
        </section>

        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Lab Reservation Form</h2>
                    <p class="calendar-subtext">Complete the details below to reserve the full lab.</p>
                </div>
            </div>

            <form onsubmit="return validateConflict();" class="lecturer-form">
                <div class="form-grid-two">

                    <div class="form-group">
                        <label for="building">Building</label>
                        <select id="building" name="building" required>
                            <option value="">Select Building</option>
                            <option value="B1">Building B1</option>
                            <option value="C4">Building C4</option>
                            <option value="Library">Library Building</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="lab">Lab</label>
                        <select id="lab" name="lab" required>
                            <option value="">Select Lab</option>
                            <option value="Lab 1">Lab 1</option>
                            <option value="Lab 2">Lab 2</option>
                            <option value="Lab 3">Lab 3</option>
                            <option value="Lab 4">Lab 4</option>
                            <option value="Lab 5">Lab 5</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="date">Date</label>
                        <input type="date" id="date" name="date" required>
                    </div>

                    <div class="form-group">
                        <label for="module">Module Code</label>
                        <input type="text" id="module" name="module" placeholder="e.g. CSC211" required>
                    </div>

                    <div class="form-group">
                        <label for="startTime">Start Time</label>
                        <input type="time" id="startTime" name="startTime" required>
                    </div>

                    <div class="form-group">
                        <label for="endTime">End Time</label>
                        <input type="time" id="endTime" name="endTime" required>
                    </div>

                    <div class="form-group full-width">
                        <label for="reason">Reason / Session Notes</label>
                        <textarea id="reason" name="reason" placeholder="Enter class group, session reason, or any important note..."></textarea>
                    </div>

                    <div class="form-group full-width">

                        <div id="warningBox" class="message-box warning-box" style="display:none;">
                            Conflict warning: the selected lab is already booked during that date and time range.
                        </div>

                        <div id="successBox" class="message-box success-box" style="display:none;">
                            Reservation details look valid and ready to submit.
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="primary-btn">Submit Block</button>
                            <button type="button" class="action-btn" onclick="resetMessages()">Clear Form</button>
                        </div>
                    </div>

                </div>
            </form>
        </section>

        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Existing Lab Blocks</h2>
                    <p class="calendar-subtext">Use these current reservations to avoid clashes.</p>
                </div>
            </div>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Building</th>
                            <th>Lab</th>
                            <th>Module</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="existingBlocksTable">
                        <tr>
                            <td>C4</td>
                            <td>Lab 1</td>
                            <td>CSC211 Practical</td>
                            <td>2026-03-24</td>
                            <td>08:00 - 10:00</td>
                            <td><span class="badge danger">Blocked</span></td>
                        </tr>
                        <tr>
                            <td>B1</td>
                            <td>Lab 3</td>
                            <td>ICT221 Tutorial</td>
                            <td>2026-03-24</td>
                            <td>11:00 - 13:00</td>
                            <td><span class="badge success">Upcoming</span></td>
                        </tr>
                        <tr>
                            <td>C4</td>
                            <td>Lab 2</td>
                            <td>CSC315 Practical</td>
                            <td>2026-03-25</td>
                            <td>09:00 - 11:00</td>
                            <td><span class="badge warning">Pending</span></td>
                        </tr>
                        <tr>
                            <td>Library</td>
                            <td>Lab 5</td>
                            <td>BIT121 Session</td>
                            <td>2026-03-26</td>
                            <td>10:00 - 12:00</td>
                            <td><span class="badge success">Upcoming</span></td>
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