<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EBS | Student Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* ── Sticky navbar ───────────────────────────────── */
        .navbar {
            position: sticky; top: 0; z-index: 1000;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            box-shadow: 0 1px 8px rgba(0,0,0,0.06);
        }
        .navbar .nav-links a {
            color: #334155; text-decoration: none;
            padding: 6px 14px; border-radius: 8px;
            font-weight: 500; font-size: 14px;
            transition: background 0.15s, color 0.15s;
        }
        .navbar .nav-links a:hover { background: #eff6ff; color: #2563eb; }
        .navbar .nav-links a.active { background: #dbeafe; color: #1d4ed8; font-weight: 600; }
        .navbar .logo span { color: #1e293b; font-weight: 700; font-size: 18px; }

        /* ── Page ────────────────────────────────────────── */
        body { background: #f8fafc; margin: 0; font-family: 'Segoe UI', sans-serif; }
        .container { max-width: 1100px; margin: 0 auto; padding: 32px 24px; }
        .page-title { font-size: 26px; font-weight: 700; color: #1e293b; margin-bottom: 24px; }

        /* ── Toolbar ─────────────────────────────────────── */
        .toolbar { display: flex; gap: 12px; flex-wrap: wrap; align-items: center; margin-bottom: 28px; }
        .search-wrap {
            display: flex; align-items: center;
            background: #fff; border: 1px solid #e2e8f0;
            border-radius: 10px; padding: 0 14px;
            flex: 1; min-width: 200px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .search-wrap i { color: #94a3b8; margin-right: 8px; font-size: 14px; }
        .search-wrap input {
            border: none; outline: none; background: transparent;
            font-size: 14px; color: #1e293b; padding: 10px 0; width: 100%;
        }

        /* ── Filter pills ────────────────────────────────── */
        .filter-pills { display: flex; gap: 8px; flex-wrap: wrap; }
        .pill {
            padding: 8px 16px; border-radius: 20px;
            border: 1.5px solid #e2e8f0; background: #fff;
            font-size: 13px; font-weight: 500; color: #475569;
            cursor: pointer; transition: all 0.15s;
        }
        .pill:hover { border-color: #93c5fd; color: #2563eb; background: #eff6ff; }
        .pill.active { background: #2563eb; color: #fff; border-color: #2563eb; }

        /* ── Venue grid: 2 columns ───────────────────────── */
        .venue-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; }

        /* ── Venue card ──────────────────────────────────── */
        .venue-card {
            background: #fff; border-radius: 16px;
            border: 1px solid #e2e8f0; overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            transition: transform 0.18s, box-shadow 0.18s;
            display: flex; flex-direction: column;
        }
        .venue-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.10); }
        .venue-image { width: 100%; height: 190px; object-fit: cover; display: block; }
        .venue-body { padding: 18px 20px; flex: 1; display: flex; flex-direction: column; }
        .venue-name { font-size: 17px; font-weight: 700; color: #1e293b; margin: 0 0 6px; }

        /* ── Category badge ──────────────────────────────── */
        .cat-badge {
            display: inline-block; font-size: 11px; font-weight: 600;
            padding: 3px 10px; border-radius: 20px; margin-bottom: 10px;
            text-transform: uppercase; letter-spacing: 0.04em;
        }
        .cat-computer { background: #dbeafe; color: #1d4ed8; }
        .cat-seminar  { background: #dcfce7; color: #15803d; }
        .cat-study    { background: #fef9c3; color: #854d0e; }

        .venue-meta { font-size: 13px; color: #64748b; margin: 4px 0; }
        .venue-meta i { width: 16px; color: #94a3b8; }
        .avail-count { color: #10b981; font-weight: 700; }

        /* ── Buttons ─────────────────────────────────────── */
        .btn-book {
            display: inline-flex; align-items: center; gap: 6px;
            margin-top: 14px; padding: 9px 18px;
            background: #2563eb; color: #fff;
            border: none; border-radius: 9px;
            font-size: 13px; font-weight: 600;
            text-decoration: none; cursor: pointer;
            transition: background 0.15s;
        }
        .btn-book:hover { background: #1d4ed8; }
        .btn-book.green { background: #059669; }
        .btn-book.green:hover { background: #047857; }

        .btn-slots {
            display: inline-flex; align-items: center; gap: 6px;
            margin-top: 8px; padding: 7px 14px;
            background: transparent; color: #2563eb;
            border: 1.5px solid #2563eb; border-radius: 9px;
            font-size: 12px; font-weight: 600;
            cursor: pointer; transition: all 0.15s;
        }
        .btn-slots:hover { background: #eff6ff; }

        .btn-row { display: flex; gap: 8px; flex-wrap: wrap; margin-top: auto; padding-top: 12px; }

        /* ── Modal overlay ───────────────────────────────── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(15,23,42,0.5);
            z-index: 2000; align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: #fff; border-radius: 16px;
            padding: 28px; width: 90%; max-width: 480px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            position: relative;
        }
        .modal-title { font-size: 18px; font-weight: 700; color: #1e293b; margin-bottom: 4px; }
        .modal-sub   { font-size: 13px; color: #64748b; margin-bottom: 20px; }
        .modal-close {
            position: absolute; top: 16px; right: 16px;
            background: none; border: none; font-size: 20px;
            color: #94a3b8; cursor: pointer;
        }
        .modal-close:hover { color: #1e293b; }

        /* ── Time slot grid ──────────────────────────────── */
        .slot-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-bottom: 20px; }
        .slot {
            padding: 10px 6px; border-radius: 9px; text-align: center;
            font-size: 12px; font-weight: 600; cursor: pointer;
            border: 1.5px solid transparent; transition: all 0.15s;
        }
        .slot.available {
            background: #f0fdf4; color: #15803d;
            border-color: #86efac;
        }
        .slot.available:hover { background: #dcfce7; border-color: #4ade80; }
        .slot.available.selected { background: #2563eb; color: #fff; border-color: #2563eb; }
        .slot.booked {
            background: #fef2f2; color: #b91c1c;
            border-color: #fca5a5; cursor: not-allowed;
        }
        .slot-time { font-size: 11px; display: block; }
        .slot-label { font-size: 10px; margin-top: 2px; display: block; opacity: 0.8; }

        /* ── Modal confirm button ────────────────────────── */
        .btn-confirm {
            width: 100%; padding: 12px;
            background: #2563eb; color: #fff;
            border: none; border-radius: 10px;
            font-size: 14px; font-weight: 600;
            cursor: pointer; transition: background 0.15s;
        }
        .btn-confirm:hover { background: #1d4ed8; }
        .btn-confirm:disabled { background: #94a3b8; cursor: not-allowed; }

        /* ── Empty state ─────────────────────────────────── */
        .empty-state {
            text-align: center; padding: 60px 20px;
            color: #94a3b8; font-size: 15px; grid-column: 1 / -1;
        }
        .empty-state i { font-size: 40px; display: block; margin-bottom: 12px; }

        @media (max-width: 640px) { .venue-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<!-- NAV -->

<nav class="navbar">
<a href="${pageContext.request.contextPath}/test-index.html" style="text-decoration: none; color: inherit;">
    <div class="logo">
        <img src="${pageContext.request.contextPath}/images/logo.jpeg" class="logo-img" alt="EBS">
        <span>EBS</span>
    </div>
</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/dashboard" class="active">Dashboard</a>
        <a href="${pageContext.request.contextPath}/student/mybookings">My Bookings</a>
        <a href="${pageContext.request.contextPath}/StudentLogoutServlet">Logout</a>
    </div>
</nav>

<div class="container">

    <h1 class="page-title">Student Dashboard</h1>

    <c:if test="${not empty flash}">
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${flash}</div>
    </c:if>

    <!-- Toolbar -->
    <div class="toolbar">
        <div class="search-wrap">
            <i class="fas fa-search"></i>
            <input type="text" id="searchInput" placeholder="Search venues by name..."/>
        </div>
        <div class="filter-pills">
            <button class="pill active" onclick="filterVenues('all', this)">All</button>
            <button class="pill" onclick="filterVenues('computer', this)">
                <i class="fas fa-desktop" style="margin-right:4px"></i>Computer Labs
            </button>
            <button class="pill" onclick="filterVenues('seminar', this)">
                <i class="fas fa-chalkboard" style="margin-right:4px"></i>Seminar Rooms
            </button>
            <button class="pill" onclick="filterVenues('study', this)">
                <i class="fas fa-book" style="margin-right:4px"></i>Study Rooms
            </button>
        </div>
    </div>

    <h2 style="margin-bottom:16px;font-size:16px;font-weight:600;color:#475569;">
        Available Venues <span id="venueCount" style="color:#94a3b8;font-weight:400;">(6)</span>
    </h2>

    <!-- Venue Grid -->
    <div class="venue-grid" id="venueGrid">

        <!-- Lab 1 — Computer Lab (LG02) -->
        <div class="venue-card" data-category="computer" data-name="lab 1 ict computer lab lg02">
            <img src="${pageContext.request.contextPath}/assets/venueImages/image1.jpg"
                 onerror="this.src='${pageContext.request.contextPath}/images/lab.jpg'"
                 class="venue-image" alt="Lab 1"/>
            <div class="venue-body">
                <span class="cat-badge cat-computer"><i class="fas fa-desktop"></i> Computer Lab</span>
                <h3 class="venue-name">Lab 1 — LG02</h3>
                <p class="venue-meta"><i class="fas fa-building"></i> ICT Block, Ground Floor</p>
                <p class="venue-meta">
                    <i class="fas fa-desktop"></i>
                    36 PCs &nbsp;|&nbsp; <span class="avail-count">28</span> available
                </p>
                <div class="btn-row">
                    <a href="${pageContext.request.contextPath}/student/ict-lab-seats.jsp" class="btn-book">
                        <i class="fas fa-desktop"></i> Book PC
                    </a>
                    <button class="btn-slots" onclick="openSlots('Lab 1 — LG02', 'computer', 1)">
                        <i class="fas fa-clock"></i> View Slots
                    </button>
                </div>
            </div>
        </div>

        <!-- Lab 2 — Computer Lab -->
        <div class="venue-card" data-category="computer" data-name="lab 2 ict computer lab">
            <img src="${pageContext.request.contextPath}/assets/venueImages/image2.jpg"
                 onerror="this.src='${pageContext.request.contextPath}/images/lab.jpg'"
                 class="venue-image" alt="Lab 2"/>
            <div class="venue-body">
                <span class="cat-badge cat-computer"><i class="fas fa-desktop"></i> Computer Lab</span>
                <h3 class="venue-name">Lab 2 — ICT Computer Lab</h3>
                <p class="venue-meta"><i class="fas fa-building"></i> ICT Block, First Floor</p>
                <p class="venue-meta">
                    <i class="fas fa-desktop"></i>
                    30 PCs &nbsp;|&nbsp; <span class="avail-count">22</span> available
                </p>
                <div class="btn-row">
                    <a href="${pageContext.request.contextPath}/student/booking?labId=2" class="btn-book">
                        <i class="fas fa-desktop"></i> Book PC
                    </a>
                    <button class="btn-slots" onclick="openSlots('Lab 2 — ICT Computer Lab', 'computer', 2)">
                        <i class="fas fa-clock"></i> View Slots
                    </button>
                </div>
            </div>
        </div>

        <!-- Lab 3 — Computer Lab -->
        <div class="venue-card" data-category="computer" data-name="lab 3 ict computer lab">
            <img src="${pageContext.request.contextPath}/assets/venueImages/image3.jpg"
                 onerror="this.src='${pageContext.request.contextPath}/images/lab.jpg'"
                 class="venue-image" alt="Lab 3"/>
            <div class="venue-body">
                <span class="cat-badge cat-computer"><i class="fas fa-desktop"></i> Computer Lab</span>
                <h3 class="venue-name">Lab 3 — ICT Computer Lab</h3>
                <p class="venue-meta"><i class="fas fa-building"></i> ICT Block, Second Floor</p>
                <p class="venue-meta">
                    <i class="fas fa-desktop"></i>
                    40 PCs &nbsp;|&nbsp; <span class="avail-count">35</span> available
                </p>
                <div class="btn-row">
                    <a href="${pageContext.request.contextPath}/student/booking?labId=3" class="btn-book">
                        <i class="fas fa-desktop"></i> Book PC
                    </a>
                    <button class="btn-slots" onclick="openSlots('Lab 3 — ICT Computer Lab', 'computer', 3)">
                        <i class="fas fa-clock"></i> View Slots
                    </button>
                </div>
            </div>
        </div>

        <!-- Lab 4 — Seminar Room -->
        <div class="venue-card" data-category="seminar" data-name="lab 4 seminar room a">
            <img src="${pageContext.request.contextPath}/assets/venueImages/image4.jpg"
                 onerror="this.src='${pageContext.request.contextPath}/images/LectureHall.jpg'"
                 class="venue-image" alt="Lab 4"/>
            <div class="venue-body">
                <span class="cat-badge cat-seminar"><i class="fas fa-chalkboard"></i> Seminar Room</span>
                <h3 class="venue-name">Lab 4 — Seminar Room A</h3>
                <p class="venue-meta"><i class="fas fa-building"></i> Main Block, Ground Floor</p>
                <p class="venue-meta">
                    <i class="fas fa-chair"></i>
                    50 seats &nbsp;|&nbsp; <span class="avail-count">Venue available</span>
                </p>
                <div class="btn-row">
                    <button class="btn-book green" onclick="openSlots('Lab 4 — Seminar Room A', 'venue', 4)">
                        <i class="fas fa-calendar-check"></i> Book Venue
                    </button>
                    <button class="btn-slots" onclick="openSlots('Lab 4 — Seminar Room A', 'venue', 4)">
                        <i class="fas fa-clock"></i> View Slots
                    </button>
                </div>
            </div>
        </div>

        <!-- Lab 5 — Seminar Room -->
        <div class="venue-card" data-category="seminar" data-name="lab 5 seminar room b">
            <img src="${pageContext.request.contextPath}/assets/venueImages/image5.jpg"
                 onerror="this.src='${pageContext.request.contextPath}/images/Auditorium.jpg'"
                 class="venue-image" alt="Lab 5"/>
            <div class="venue-body">
                <span class="cat-badge cat-seminar"><i class="fas fa-chalkboard"></i> Seminar Room</span>
                <h3 class="venue-name">Lab 5 — Seminar Room B</h3>
                <p class="venue-meta"><i class="fas fa-building"></i> Main Block, First Floor</p>
                <p class="venue-meta">
                    <i class="fas fa-chair"></i>
                    45 seats &nbsp;|&nbsp; <span class="avail-count">Venue available</span>
                </p>
                <div class="btn-row">
                    <button class="btn-book green" onclick="openSlots('Lab 5 — Seminar Room B', 'venue', 5)">
                        <i class="fas fa-calendar-check"></i> Book Venue
                    </button>
                    <button class="btn-slots" onclick="openSlots('Lab 5 — Seminar Room B', 'venue', 5)">
                        <i class="fas fa-clock"></i> View Slots
                    </button>
                </div>
            </div>
        </div>

        <!-- Lab 6 — Study Room -->
        <div class="venue-card" data-category="study" data-name="lab 6 study room library">
            <img src="${pageContext.request.contextPath}/assets/venueImages/image6.jpg"
                 onerror="this.src='${pageContext.request.contextPath}/images/lab.jpg'"
                 class="venue-image" alt="Lab 6"/>
            <div class="venue-body">
                <span class="cat-badge cat-study"><i class="fas fa-book"></i> Study Room</span>
                <h3 class="venue-name">Lab 6 — Study Room</h3>
                <p class="venue-meta"><i class="fas fa-building"></i> Library Block, Ground Floor</p>
                <p class="venue-meta">
                    <i class="fas fa-book"></i>
                    20 seats &nbsp;|&nbsp; <span class="avail-count">Venue available</span>
                </p>
                <div class="btn-row">
                    <button class="btn-book green" onclick="openSlots('Lab 6 — Study Room', 'venue', 6)">
                        <i class="fas fa-calendar-check"></i> Book Venue
                    </button>
                    <button class="btn-slots" onclick="openSlots('Lab 6 — Study Room', 'venue', 6)">
                        <i class="fas fa-clock"></i> View Slots
                    </button>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- ── Time Slot Modal ─────────────────────────────────────── -->
<div class="modal-overlay" id="modalOverlay" onclick="closeModal(event)">
    <div class="modal">
        <button class="modal-close" onclick="closeSlots()"><i class="fas fa-times"></i></button>
        <div class="modal-title" id="modalTitle">Lab Slots</div>
        <div class="modal-sub" id="modalSub">Select an available time slot to book</div>

        <div class="slot-grid" id="slotGrid"></div>

        <button class="btn-confirm" id="confirmSlotBtn" disabled onclick="confirmBooking()">
            Confirm Booking
        </button>
    </div>
</div>

<script>
    /* ── Dummy booked slots per lab (replace with real API later) ── */
    const bookedSlots = {
        1: [{ start: 8 }, { start: 10 }, { start: 14 }],
        2: [{ start: 10 }, { start: 16 }],
        3: [{ start: 8 }, { start: 12 }],
        4: [{ start: 9 }, { start: 13 }, { start: 15 }],
        5: [{ start: 11 }],
        6: [{ start: 8 }, { start: 14 }, { start: 16 }]
    };

    const hours = [8,9,10,11,12,13,14,15,16,17,18];
    let selectedSlot = null;
    let currentLabId = null;
    let currentType  = null;

    function fmt(h) { return (h < 10 ? '0' : '') + h + ':00'; }

    function openSlots(name, type, labId) {
        currentLabId = labId;
        currentType  = type;
        selectedSlot = null;

        document.getElementById('modalTitle').textContent = name;
        document.getElementById('modalSub').textContent =
            type === 'computer'
            ? 'Select a time slot — then choose your PC on the next screen'
            : 'Select a time slot to book the entire venue';

        const booked = (bookedSlots[labId] || []).map(s => s.start);
        const grid   = document.getElementById('slotGrid');
        grid.innerHTML = '';

        hours.forEach(h => {
            const isBooked = booked.includes(h);
            const div = document.createElement('div');
            div.className = 'slot ' + (isBooked ? 'booked' : 'available');
            div.innerHTML =
                '<span class="slot-time">' + fmt(h) + ' – ' + fmt(h + 2) + '</span>' +
                '<span class="slot-label">' + (isBooked ? 'Booked' : 'Available') + '</span>';

            if (!isBooked) {
                div.onclick = () => selectSlot(div, h);
            }
            grid.appendChild(div);
        });

        document.getElementById('confirmSlotBtn').disabled = true;
        document.getElementById('modalOverlay').classList.add('open');
    }

    function selectSlot(el, hour) {
        document.querySelectorAll('.slot.available').forEach(s => s.classList.remove('selected'));
        el.classList.add('selected');
        selectedSlot = hour;
        document.getElementById('confirmSlotBtn').disabled = false;
    }

    function closeSlots() {
        document.getElementById('modalOverlay').classList.remove('open');
    }

    function closeModal(e) {
        if (e.target === document.getElementById('modalOverlay')) closeSlots();
    }

    function confirmBooking() {
        if (!selectedSlot) return;
        const ctx = '${pageContext.request.contextPath}';

        if (currentType === 'computer') {
            /* Redirect to seat map with labId + slot pre-selected */
            window.location.href = ctx + '/student/ict-lab-seats.jsp?labId=' + currentLabId + '&slot=' + selectedSlot;
        } else {
            /* Redirect to venue booking page */
            window.location.href = ctx + '/student/booking?labId=' + currentLabId + '&slot=' + selectedSlot;
        }
    }

    /* ── Filter + search ───────────────────────────────────── */
    let currentFilter = 'all';

    function filterVenues(category, btn) {
        currentFilter = category;
        document.querySelectorAll('.pill').forEach(p => p.classList.remove('active'));
        btn.classList.add('active');
        applyFilters();
    }

    document.getElementById('searchInput').addEventListener('input', applyFilters);

    function applyFilters() {
        const q = document.getElementById('searchInput').value.toLowerCase().trim();
        const cards = document.querySelectorAll('#venueGrid .venue-card');
        let visible = 0;
        cards.forEach(card => {
            const matchCat  = currentFilter === 'all' || card.dataset.category === currentFilter;
            const matchName = !q || card.dataset.name.includes(q);
            const show = matchCat && matchName;
            card.style.display = show ? '' : 'none';
            if (show) visible++;
        });
        document.getElementById('venueCount').textContent = '(' + visible + ')';
    }
</script>

</body>
</html>
