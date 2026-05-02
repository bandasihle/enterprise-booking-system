<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Lecturer Dashboard – EBS</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/lecturer/css/lecturer.css">
  
  <style>
    :root {
        --primary-green: #065f46; /* Deep emerald */
        --hover-white: rgba(255, 255, 255, 0.15);
        --text-secondary: #64748b;
        --card-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
    }

    /* 1. Refined Navbar - Ghost Button Style */
    .top-navbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0.75rem 2rem;
        background-color: var(--primary-green);
    }
    
    .nav-left-section { flex: 1; display: flex; align-items: center; }

    .nav-menu {
        display: flex;
        gap: 8px;
        flex: 2;
        justify-content: center;
    }

    .nav-menu .primary-btn {
        background: transparent;
        border: 1px solid transparent;
        color: rgba(255, 255, 255, 0.85);
        font-weight: 500;
        padding: 8px 16px;
        border-radius: 8px;
        transition: all 0.2s ease;
    }

    .nav-menu .primary-btn:hover {
        background: var(--hover-white);
        color: #fff;
    }

    /* Active State for current page */
    .nav-menu a[href*="dashboard"] {
        background: var(--hover-white);
        color: #fff;
        border-color: rgba(255, 255, 255, 0.2);
    }

    .nav-right {
        flex: 1;
        display: flex;
        justify-content: flex-end;
        align-items: center;
        gap: 15px;
    }

    /* 2. Softer Stat Cards */
    .stat-card {
        background: #fff;
        border: none !important;
        border-radius: 16px;
        padding: 24px;
        box-shadow: var(--card-shadow);
        transition: transform 0.3s ease;
    }

    .stat-card:hover { transform: translateY(-2px); }

    .stat-number { font-size: 2.5rem; font-weight: 800; color: var(--primary-green); }

    .stat-label { 
        color: var(--text-secondary); 
        font-size: 0.9rem; 
        text-transform: uppercase; 
        letter-spacing: 0.5px; 
    }

    /* 3. Interactive Lab Cards */
    .lab-card {
        border: none;
        border-radius: 12px;
        overflow: hidden;
        background: #fff;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .lab-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
    }

    .lab-image {
        filter: grayscale(20%); /* Softens the B&W look */
        transition: filter 0.3s ease;
    }

    .lab-card:hover .lab-image { filter: grayscale(0%); }

    /* 4. Filter Chips - Minimalist Upgrade */
    .chip {
        background: #f1f5f9;
        color: var(--text-secondary);
        border: 1px solid transparent;
        transition: all 0.2s;
    }

    .chip.active {
        background: var(--primary-green);
        color: #fff;
    }

    .chip:not(.active):hover {
        background: #e2e8f0;
        color: #1e293b;
    }

    /* Typography Polish */
    h1, h2 { letter-spacing: -0.5px; }

  </style>
</head>
<body>

<nav class="top-navbar">
  <div class="nav-left-section">
    <a href="${pageContext.request.contextPath}/test-index.html" class="nav-brand" style="text-decoration:none; color:white;">
      <div class="nav-brand-text">
        <strong>EBS</strong><span style="opacity: 0.8;"> Lecturer</span>
      </div>
    </a>
  </div>

  <div class="nav-menu">
    <a href="${pageContext.request.contextPath}/lecturer/dashboard" class="primary-btn">Dashboard</a>
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="primary-btn">Book Lab</a>
    <a href="${pageContext.request.contextPath}/lecturer/bookings" class="primary-btn">My Bookings</a>
  </div>

  <div class="nav-right">
    <span class="user-chip" style="color:white; font-size: 0.9rem;">👨‍🏫 ${sessionScope.userName}</span>
    <a href="${pageContext.request.contextPath}/logout" class="logout-link" style="color: rgba(255,255,255,0.7); text-decoration: none; font-size: 0.9rem;">Logout</a>
  </div>
</nav>

<div class="main-content">

  <c:if test="${not empty flashMsg}">
    <div class="flash ${flashType}">${flashMsg}</div>
  </c:if>

  <div class="page-header">
    <div>
      <h1 style="color: #1e293b;">Lecturer Dashboard</h1>
      <p style="color: var(--text-secondary);">Manage lab reservations and view upcoming blocks</p>
    </div>
    <a href="${pageContext.request.contextPath}/lecturer/book-lab" class="primary-btn" style="background: var(--primary-green); border-radius: 10px; padding: 12px 24px;">
      + New Reservation
    </a>
  </div>

  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-label">Upcoming Blocks</div>
      <div class="stat-number">${empty blocks ? 0 : fn:length(blocks)}</div>
      <div class="stat-label" style="text-transform: none;">Confirmed reservations</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Available Labs</div>
      <div class="stat-number">${empty labs ? 0 : fn:length(labs)}</div>
      <div class="stat-label" style="text-transform: none;">Ready to reserve</div>
    </div>
  </div>

  <div class="section-title" style="margin-top: 40px; font-weight: 700; color: #334155;">Available Venues</div>
  
  <div class="toolbar" style="background: #fff; padding: 15px; border-radius: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
    <input type="text" class="search-box" id="labSearch" placeholder="Search by name or building…" style="border: 1px solid #e2e8f0; border-radius: 8px;">
    <div class="filter-chips">
      <button class="chip active" data-filter="all">All</button>
      <button class="chip" data-filter="computer">Computer Labs</button>
      <button class="chip" data-filter="seminar">Seminar Rooms</button>
    </div>
  </div>

  <div class="lab-grid" id="labGrid" style="margin-top: 25px;">
    <c:choose>
      <c:when test="${empty labs}">
        <div class="empty-state">
          <div class="empty-icon">🏫</div>
          <h3>No labs available</h3>
          <p>Contact your administrator to add venues.</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="lab" items="${labs}">
          <c:set var="isComputer" value="${fn:containsIgnoreCase(lab.labName,'Lab') or fn:containsIgnoreCase(lab.labName,'LG')}"/>
          <c:set var="cardType"   value="${isComputer ? 'computer' : 'seminar'}"/>

          <div class="lab-card" data-category="${cardType}"
               data-search="${fn:toLowerCase(lab.labName)} ${fn:toLowerCase(lab.building)}">
            
            <%--
              Real campus photos — computer labs cycle through 4 shots,
              seminar/other venues cycle through 2, keyed on lab.id so
              each venue always gets the same photo.
            --%>
            <c:choose>
              <c:when test="${isComputer}">
                <c:set var="imgFile" value="${['lab-wide.jpeg','lab-color.jpeg','lab-evening.jpeg','lab-dark.jpeg'][lab.id % 4]}"/>
              </c:when>
              <c:otherwise>
                <c:set var="imgFile" value="${['seminar.jpeg','lecture-hall.jpeg'][lab.id % 2]}"/>
              </c:otherwise>
            </c:choose>
            <img src="../images/${imgFile}"
                 alt="${lab.labName}" class="lab-image"
                 onerror="this.src='../images/logooo.jpeg'"/>

            <div class="lab-body" style="padding: 20px;">
              <span class="lab-tag ${isComputer ? 'tag-blue' : 'tag-green'}" style="font-size: 0.7rem; font-weight: 700;">
                ${isComputer ? '💻 COMPUTER LAB' : '🏛️ SEMINAR ROOM'}
              </span>
              <div class="lab-title" style="font-size: 1.2rem; margin: 10px 0 5px 0;">${lab.labName}</div>
              <div class="lab-meta" style="color: var(--text-secondary); font-size: 0.85rem;">${lab.building} &bull; Capacity: ${lab.capacity}</div>

              <div class="card-actions" style="margin-top: 20px; display: flex; gap: 10px;">
                <a href="${pageContext.request.contextPath}/lecturer/book-lab?labId=${lab.id}" 
                   class="primary-btn" style="background: var(--primary-green); flex: 1; text-align: center; font-size: 0.9rem;">
                  ${isComputer ? 'Book Lab' : 'Block Venue'}
                </a>
                <a href="${pageContext.request.contextPath}/lecturer/bookings" 
                   class="outline-btn" style="flex: 1; text-align: center; font-size: 0.9rem; border-radius: 8px;">
                  View
                </a>
              </div>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<script>
  // Lab search logic
  document.getElementById('labSearch').addEventListener('input', function () {
    const term = this.value.toLowerCase();
    filterCards(term, document.querySelector('.chip.active').dataset.filter);
  });

  // Filter chips logic
  document.querySelectorAll('.chip').forEach(function (chip) {
    chip.addEventListener('click', function () {
      document.querySelectorAll('.chip').forEach(function (c) { c.classList.remove('active'); });
      this.classList.add('active');
      filterCards(document.getElementById('labSearch').value.toLowerCase(), this.dataset.filter);
    });
  });

  function filterCards(term, category) {
    document.querySelectorAll('.lab-card').forEach(function (card) {
      const matchSearch   = !term || card.dataset.search.includes(term);
      const matchCategory = category === 'all' || card.dataset.category === category;
      card.style.display = (matchSearch && matchCategory) ? '' : 'none';
    });
  }
</script>

</body>
</html>