<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EBS | ICT Lab Seats</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/seat-map.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* [Keep all existing CSS styles exactly as they were] */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #f8fafc; color: #1e293b; font-family: 'Segoe UI', Arial, sans-serif; min-height: 100vh; }
        .navbar { position: sticky; top: 0; z-index: 1000; background: #ffffff; border-bottom: 1px solid #e2e8f0; box-shadow: 0 1px 8px rgba(0,0,0,0.06); display: flex; align-items: center; justify-content: space-between; padding: 0 28px; height: 60px; }
        .navbar .logo { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .navbar .logo img { width: 32px; height: 32px; border-radius: 8px; object-fit: cover; }
        .navbar .logo span { color: #1e293b; font-weight: 700; font-size: 18px; }
        .navbar .nav-links { display: flex; align-items: center; gap: 4px; }
        .navbar .nav-links a { color: #334155; text-decoration: none; padding: 6px 14px; border-radius: 8px; font-weight: 500; font-size: 14px; transition: background 0.15s, color 0.15s; }
        .navbar .nav-links a:hover { background: #eff6ff; color: #2563eb; }
        .navbar .nav-links a.active { background: #dbeafe; color: #1d4ed8; font-weight: 600; }
        .container { max-width: 1100px; margin: 0 auto; padding: 32px 24px; }
        .page-title { font-size: 26px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
        .page-sub { font-size: 14px; color: #64748b; margin-bottom: 24px; }
        .page-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; margin-bottom: 24px; }
        .btn-back { display: inline-flex; align-items: center; gap: 6px; padding: 9px 16px; border-radius: 9px; border: 1.5px solid #e2e8f0; background: #fff; font-size: 13px; font-weight: 600; color: #475569; text-decoration: none; cursor: pointer; transition: all 0.15s; }
        .btn-back:hover { border-color: #93c5fd; color: #2563eb; background: #eff6ff; }
        .info-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 2px 8px rgba(0,0,0,0.05); padding: 20px 24px; margin-bottom: 20px; }
        .info-card h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0 0 10px; }
        .info-card p { font-size: 13px; color: #64748b; margin: 4px 0; }
        .info-card p i { width: 16px; color: #94a3b8; }
        .seat-shell { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 2px 8px rgba(0,0,0,0.05); padding: 24px; }
        .seat-toolbar { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #f1f5f9; }
        .seat-toolbar h2, #lab-name { font-size: 22px; font-weight: 700; color: #1e293b; margin: 0; }
        .seat-toolbar p { font-size: 13px; color: #64748b; margin: 4px 0 0; }
        .lab-select-wrap { display: flex; flex-direction: column; align-items: flex-start; gap: 4px; }
        .lab-select-wrap label { font-size: 13px; font-weight: 600; color: #64748b; }
        .lab-select-wrap select { background: #ffffff; color: #1e293b; border: 1.5px solid #e2e8f0; border-radius: 10px; padding: 9px 14px; font-size: 14px; cursor: pointer; outline: none; min-width: 200px; box-shadow: 0 1px 4px rgba(0,0,0,0.04); transition: border-color 0.15s, box-shadow 0.15s; }
        .lab-select-wrap select:focus { border-color: #93c5fd; box-shadow: 0 0 0 3px rgba(37,99,235,0.12); }
        .seat-legend { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 20px; }
        .legend-item { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #475569; font-weight: 500; }
        .legend-dot { width: 16px; height: 16px; border-radius: 5px; flex-shrink: 0; }
        .seat-layout-wrapper { overflow-x: auto; padding: 8px 0; }
        .lab-boundary { border: 1px solid #e2e8f0; border-radius: 16px; padding: 20px; position: relative; background: #f8fafc; display: inline-flex; flex-direction: column; gap: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .entrance-label { position: absolute; top: -10px; left: 20px; font-size: 11px; color: #64748b; background: #f8fafc; padding: 0 6px; letter-spacing: 0.05em; font-weight: 600; }
        .lab-inner { display: flex; flex-direction: row; align-items: stretch; gap: 0; }
        .walk-col { width: 36px; background: #f1f5f9; border-radius: 8px; flex-shrink: 0; }
        .center-rows { flex: 1; display: flex; flex-direction: column; justify-content: space-evenly; align-items: center; padding: 0 16px; gap: 24px; }
        .seat-row { display: flex; flex-direction: row; gap: 10px; justify-content: center; }
        .back-to-back { display: flex; flex-direction: column; gap: 0; align-items: center; }
        .wall-col { display: flex; flex-direction: column; justify-content: space-evenly; gap: 10px; border-left: 1px solid #e2e8f0; padding-left: 16px; flex-shrink: 0; }
        .bottom-row { display: flex; flex-direction: row; justify-content: space-between; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 16px; }
        .seat { width: 68px; height: 68px; border-radius: 12px; display: flex; flex-direction: column; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; cursor: pointer; position: relative; user-select: none; flex-shrink: 0; transition: box-shadow 0.18s, background 0.15s, border-color 0.15s, transform 0.15s; }
        .seat.available { background: #dbeafe; border: 1.5px solid #2563eb; color: #1d4ed8; }
        .seat.available:hover { background: #bfdbfe; border-color: #1d4ed8; box-shadow: 0 8px 20px rgba(37,99,235,0.15); transform: translateY(-2px) !important; }
        .seat.in-use { background: #f1f5f9; border: 1.5px solid #94a3b8; color: #64748b; cursor: not-allowed; }
        .seat.in-use:hover { box-shadow: none; transform: none !important; }
        .seat.unavailable { background: #fef3c7; border: 1.5px solid #f59e0b; color: #b45309; cursor: not-allowed; }
        .seat.unavailable:hover { box-shadow: none; transform: none !important; }
        .seat.facing-up { transform: rotate(0deg); }
        .seat.facing-down { transform: rotate(180deg); }
        .seat.facing-left { transform: rotate(270deg); }
        .seat.facing-right { transform: rotate(90deg); }
        .seat.wall-seat { transform: none !important; }
        .monitor { width: 28px; height: 20px; border: 2px solid currentColor; border-radius: 3px; position: relative; margin-bottom: 4px; }
        .monitor::after { content: ''; width: 9px; height: 4px; background: currentColor; position: absolute; bottom: -7px; left: 50%; transform: translateX(-50%); border-radius: 1px; }
        .monitor-stand { width: 16px; height: 3px; background: currentColor; border-radius: 1px; margin-bottom: 4px; }
        .seat-label { font-size: 11px; font-weight: 600; letter-spacing: 0.02em; margin-top: 2px; display: inline-block; }
        .seat-tooltip { display: none; position: absolute; top: -36px; left: 50%; transform: translateX(-50%) rotate(0deg) !important; background: #ffffff; color: #1e293b; font-size: 11px; padding: 6px 10px; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 6px 18px rgba(0,0,0,0.08); white-space: nowrap; z-index: 100; pointer-events: none; }
        .seat:hover .seat-tooltip { display: block; }
        #placeholder-text, .loading-text { color: #94a3b8; font-size: 14px; padding: 40px 0; text-align: center; }
        .error-text { color: #dc2626; font-size: 14px; padding: 40px 0; text-align: center; }
        .seat-gap { width: 68px; height: 68px; visibility: hidden; }
        .seat-grid { display: grid; gap: 10px; }
        .seat-tip { margin-top: 16px; padding-top: 16px; border-top: 1px solid #f1f5f9; font-size: 13px; color: #94a3b8; display: flex; align-items: center; gap: 6px; }
    </style>
</head>
<body>

<!-- NAV -->
<nav class="navbar">
    <div class="logo">
        <img src="${pageContext.request.contextPath}/images/logo.jpeg" class="logo-img" alt="EBS">
        <span>EBS</span>
    </div>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/dashboard.jsp">Dashboard</a>
        <a href="${pageContext.request.contextPath}/student/ict-lab-seats.jsp" class="active">Book PC</a>
        <a href="${pageContext.request.contextPath}/student/mybooking.jsp">My Bookings</a>
    </div>
</nav>

<div class="container">

    <!-- Page header -->
    <div class="page-header">
        <div>
            <h1 class="page-title">ICT Lab Seats</h1>
            <p class="page-sub">View the seat layout and availability for each ICT computer lab.</p>
        </div>
        <a href="${pageContext.request.contextPath}/student/dashboard.jsp" class="btn-back">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <!-- Info card -->
    <div class="info-card">
        <h3><i class="fas fa-circle-info"></i> How it works</h3>
        <p><i class="fas fa-desktop"></i>&nbsp; Select a lab from the dropdown to load its seat map.</p>
        <p><i class="fas fa-hand-pointer"></i>&nbsp; Blue seats are available — click one to book it.</p>
        <p><i class="fas fa-building"></i>&nbsp; Each lab has a unique layout matching the real physical arrangement.</p>
    </div>

    <!-- Seat shell -->
    <div class="seat-shell">

        <!-- Toolbar -->
        <div class="seat-toolbar">
            <div>
                <h2 id="lab-name">Select a Lab</h2>
                <p>Choose an ICT lab below to view its seat allocation.</p>
            </div>
            <div class="lab-select-wrap">
                <label for="labSelect">ICT Lab</label>
                <select id="labSelect" onchange="loadSeats()">
                    <option value="">-- Choose a lab --</option>
                </select>
            </div>
        </div>

        <!-- Legend -->
        <div class="seat-legend">
            <div class="legend-item">
                <span class="legend-dot" style="background:#dbeafe; border:1.5px solid #2563eb;"></span>
                Available
            </div>
            <div class="legend-item">
                <span class="legend-dot" style="background:#f1f5f9; border:1.5px solid #94a3b8;"></span>
                In Use
            </div>
            <div class="legend-item">
                <span class="legend-dot" style="background:#fef3c7; border:1.5px solid #f59e0b;"></span>
                Unavailable/Broken
            </div>
        </div>

        <!-- Seat map renders here -->
        <div class="seat-layout-wrapper">
            <div id="seat-map-container">
                <p id="placeholder-text">
                    <i class="fas fa-desktop" style="display:block;font-size:32px;margin-bottom:10px;color:#cbd5e1;"></i>
                    Select a lab above to view the seat map.
                </p>
            </div>
        </div>

        <!-- Tip -->
        <div class="seat-tip">
            <i class="fas fa-lightbulb" style="color:#f59e0b;"></i>
            Seat statuses update in real time. Refresh the map if a seat appears incorrect.
        </div>

    </div>
</div>

<script>
    // Set global context and user ID from session
    window.EBS_CONTEXT = '${pageContext.request.contextPath}';
    window.EBS_USER_ID = '${sessionScope.userId != null ? sessionScope.userId : ""}';
    window.EBS_USER_NAME = '${sessionScope.userName != null ? sessionScope.userName : ""}';
</script>
<script src="${pageContext.request.contextPath}/js/seat-map.js"></script>

</body>
</html>