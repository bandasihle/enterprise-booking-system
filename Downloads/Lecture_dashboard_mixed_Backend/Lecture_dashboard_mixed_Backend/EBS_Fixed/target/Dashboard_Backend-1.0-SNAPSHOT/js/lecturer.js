/* ================================================
   LECTURER DASHBOARD — lecturer.js
   Project: testing.ebs  (deployed as testing.ebs)

   Exact IDs used in the JSP files:
   ─ lecturer-dashboard.jsp
       stat cards : #thisWeekBlocks  #todaySessions
                    #pendingRequests  #availableLabs
       table body : #upcomingBlocksTable

   ─ block-lab.jsp
       form       : form.lecturer-form
       fields     : #building  #lab  #date  #module
                    #startTime  #endTime  #reason
       messages   : #warningBox  #successBox
       table body : #existingBlocksTable

   ─ view-bookings.jsp
       stat cards : #totalBookings  #upcomingCount
                    #pendingCount  #completedCount
       table body : #bookingsTableBody
       search     : #searchInput
       filter     : #statusFilter

   Backend endpoints (all under /api/lecturer/):
       GET  /api/lecturer/dashboard
       GET  /api/lecturer/block
       POST /api/lecturer/block
       GET  /api/lecturer/bookings
   ================================================ */

/*
 * Automatically resolves the base URL from the browser's
 * current path so this file works regardless of what the
 * GlassFish context root is called.
 * e.g. http://localhost:8080/testing.ebs
 */
var BASE_URL = (function () {
    var parts = window.location.pathname.split("/");
    return window.location.origin + "/" + parts[1];
}());

/* ------------------------------------------------
   BOOT — run the right page setup after DOM loads
   ------------------------------------------------ */
document.addEventListener("DOMContentLoaded", function () {
    console.log("lecturer.js loaded | BASE_URL:", BASE_URL);

    var path = window.location.pathname.toLowerCase();

    if (path.indexOf("lecturer-dashboard") !== -1) {
        setupDashboard();
    } else if (path.indexOf("block-lab") !== -1) {
        setupBlockLab();
    } else if (path.indexOf("view-bookings") !== -1) {
        setupViewBookings();
    }
});

/* ================================================
   PAGE 1 — LECTURER DASHBOARD
   Fills the four stat cards and the Upcoming
   Blocks table (#upcomingBlocksTable) from the DB.
   ================================================ */
function setupDashboard() {
    console.log("Setting up Dashboard...");

    /* Stat cards */
    fetch(BASE_URL + "/api/lecturer/dashboard")
        .then(function (r) { return r.json(); })
        .then(function (d) {
            console.log("Dashboard stats:", d);
            setText("thisWeekBlocks",  d.thisWeekBlocks);
            setText("todaySessions",   d.todaySessions);
            setText("pendingRequests", d.pendingRequests);
            setText("availableLabs",   d.availableLabs);
        })
        .catch(function (e) { console.error("Dashboard stats error:", e); });

    /* Upcoming Blocks table — targets #upcomingBlocksTable */
    fetch(BASE_URL + "/api/lecturer/block")
        .then(function (r) { return r.json(); })
        .then(function (blocks) {
            console.log("Upcoming blocks:", blocks.length);
            var tbody = document.getElementById("upcomingBlocksTable");
            if (!tbody) { return; }

            if (blocks.length === 0) {
                tbody.innerHTML = emptyRow(6, "No upcoming blocks found.");
                return;
            }

            tbody.innerHTML = blocks.map(function (b) {
                return "<tr>" +
                    "<td>" + x(b.moduleCode)  + "</td>" +
                    "<td>" + x(b.building)    + "</td>" +
                    "<td>" + x(b.labName)     + "</td>" +
                    "<td>" + x(b.blockDate)   + "</td>" +
                    "<td>" + x(b.startTime)   + " - " + x(b.endTime) + "</td>" +
                    "<td><span class='badge " + badgeClass(b.status) + "'>" +
                        x(b.status) + "</span></td>" +
                    "</tr>";
            }).join("");
        })
        .catch(function (e) { console.error("Upcoming blocks error:", e); });
}

/* ================================================
   PAGE 2 — BLOCK LAB
   Loads #existingBlocksTable on page load.
   Intercepts form and POSTs to backend.
   Reloads table on success.
   ================================================ */
function setupBlockLab() {
    console.log("Setting up Block Lab...");

    loadExistingBlocks();
    hide("warningBox");
    hide("successBox");

    /*
     * The form has: onsubmit="return validateConflict();"
     * We override validateConflict() at the bottom of this file.
     * We also add a direct listener as a backup.
     */
    var form = document.querySelector("form.lecturer-form");
    if (form) {
        form.addEventListener("submit", function (e) {
            e.preventDefault();
            submitBlock();
        });
    }

    var submitBtn = document.querySelector("button[type='submit']");
    if (submitBtn) {
        submitBtn.addEventListener("click", function (e) {
            e.preventDefault();
            submitBlock();
        });
    }
}

/*
 * Reads every form field using its exact ID from block-lab.jsp,
 * validates, then POSTs JSON to /api/lecturer/block.
 */
function submitBlock() {
    var building     = fieldVal("building");
    var labName      = fieldVal("lab");
    var moduleCode   = fieldVal("module");
    var blockDate    = fieldVal("date");
    var startTime    = fieldVal("startTime");
    var endTime      = fieldVal("endTime");
    var reason       = fieldVal("reason");
    var lecturerName = "Dr. Nkosi";

    console.log("Submitting:", building, labName, moduleCode, blockDate, startTime, endTime);

    if (!building || !labName || !moduleCode || !blockDate || !startTime || !endTime) {
        showWarning("Please fill in all required fields before submitting.");
        return;
    }

    var btn = document.querySelector("button[type='submit']");
    if (btn) { btn.disabled = true; btn.textContent = "Submitting..."; }

    fetch(BASE_URL + "/api/lecturer/block", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            building:     building,
            labName:      labName,
            moduleCode:   moduleCode,
            blockDate:    blockDate,
            startTime:    startTime,
            endTime:      endTime,
            reason:       reason,
            lecturerName: lecturerName
        })
    })
    .then(function (r) { return r.json(); })
    .then(function (data) {
        console.log("Submit response:", data);
        if (btn) { btn.disabled = false; btn.textContent = "Submit Block"; }

        if (data.success) {
            showSuccess("Lab block submitted successfully!");
            var form = document.querySelector("form.lecturer-form");
            if (form) form.reset();
            loadExistingBlocks();
        } else {
            showWarning(data.message || "Submission failed. Please try again.");
        }
    })
    .catch(function (err) {
        console.error("Submit error:", err);
        if (btn) { btn.disabled = false; btn.textContent = "Submit Block"; }
        showWarning("Cannot reach the server. Make sure GlassFish is running.");
    });
}

/*
 * Fetches all blocks and populates #existingBlocksTable.
 * Called on page load AND after a successful submission.
 */
function loadExistingBlocks() {
    fetch(BASE_URL + "/api/lecturer/block")
        .then(function (r) { return r.json(); })
        .then(function (blocks) {
            console.log("Existing blocks:", blocks.length);
            var tbody = document.getElementById("existingBlocksTable");
            if (!tbody) { return; }

            if (blocks.length === 0) {
                tbody.innerHTML = emptyRow(6, "No existing lab blocks found.");
                return;
            }

            tbody.innerHTML = blocks.map(function (b) {
                return "<tr>" +
                    "<td>" + x(b.building)    + "</td>" +
                    "<td>" + x(b.labName)     + "</td>" +
                    "<td>" + x(b.moduleCode)  + "</td>" +
                    "<td>" + x(b.blockDate)   + "</td>" +
                    "<td>" + x(b.startTime)   + " - " + x(b.endTime) + "</td>" +
                    "<td><span class='badge " + badgeClass(b.status) + "'>" +
                        x(b.status) + "</span></td>" +
                    "</tr>";
            }).join("");
        })
        .catch(function (e) { console.error("Load existing blocks error:", e); });
}

/* ================================================
   PAGE 3 — VIEW BOOKINGS
   Fills four stat cards and #bookingsTableBody.
   Wires #searchInput, #statusFilter, View buttons.
   ================================================ */
function setupViewBookings() {
    console.log("Setting up View Bookings...");

    fetch(BASE_URL + "/api/lecturer/bookings")
        .then(function (r) { return r.json(); })
        .then(function (data) {
            console.log("Bookings data:", data);

            setText("totalBookings",  data.totalBookings);
            setText("upcomingCount",  data.upcoming);
            setText("pendingCount",   data.pending);
            setText("completedCount", data.completed);

            var tbody = document.getElementById("bookingsTableBody");
            if (!tbody) { return; }

            var bookings = data.bookings || [];

            if (bookings.length === 0) {
                tbody.innerHTML = emptyRow(9, "No bookings found.");
                return;
            }

            tbody.innerHTML = bookings.map(function (b) {
                return "<tr data-status='" + x(b.status) + "'>" +
                    "<td>" + x(b.bookingId)    + "</td>" +
                    "<td>" + x(b.moduleCode)   + "</td>" +
                    "<td>" + x(b.building)     + "</td>" +
                    "<td>" + x(b.labName)      + "</td>" +
                    "<td>" + x(b.blockDate)    + "</td>" +
                    "<td>" + x(b.startTime)    + " - " + x(b.endTime) + "</td>" +
                    "<td><span class='badge " + badgeClass(b.status) + "'>" +
                        x(b.status) + "</span></td>" +
                    "<td>" + x(b.lecturerName) + "</td>" +
                    "<td><button class='table-btn view-btn'" +
                        " data-id='"       + x(b.bookingId)    + "'" +
                        " data-module='"   + x(b.moduleCode)   + "'" +
                        " data-building='" + x(b.building)     + "'" +
                        " data-lab='"      + x(b.labName)      + "'" +
                        " data-date='"     + x(b.blockDate)    + "'" +
                        " data-time='"     + x(b.startTime)    + " - " + x(b.endTime) + "'" +
                        " data-status='"   + x(b.status)       + "'" +
                        " data-lecturer='" + x(b.lecturerName) + "'" +
                        ">View</button></td>" +
                    "</tr>";
            }).join("");

            wireViewButtons();
        })
        .catch(function (e) { console.error("View bookings error:", e); });

    /*
     * Also wire the hardcoded static rows so View works
     * even before the backend data loads.
     */
    wireViewButtons();

    /* Search — uses exact ID #searchInput from view-bookings.jsp */
    var search = document.getElementById("searchInput");
    if (search) {
        search.addEventListener("input", function () { filterBookings(); });
    }

    /* Status filter — uses exact ID #statusFilter from view-bookings.jsp */
    var filter = document.getElementById("statusFilter");
    if (filter) {
        filter.addEventListener("change", function () { filterBookings(); });
    }
}

/*
 * Hides rows that do not match the search query or selected status.
 */
function filterBookings() {
    var query  = fieldVal("searchInput").toLowerCase();
    var status = fieldVal("statusFilter").toLowerCase();

    var tbody = document.getElementById("bookingsTableBody");
    if (!tbody) return;

    var rows = tbody.querySelectorAll("tr");
    rows.forEach(function (row) {
        var matchText   = row.textContent.toLowerCase().indexOf(query) !== -1;
        var rowStatus   = (row.getAttribute("data-status") || "").toLowerCase();
        var matchStatus = (!status || status === "all" || rowStatus === status);
        row.style.display = (matchText && matchStatus) ? "" : "none";
    });
}

/*
 * Attaches a click handler to every .view-btn.
 * Clones each button first to remove any old listeners.
 */
function wireViewButtons() {
    /* Clone to remove duplicate listeners */
    document.querySelectorAll(".view-btn").forEach(function (btn) {
        var clone = btn.cloneNode(true);
        btn.parentNode.replaceChild(clone, btn);
    });

    document.querySelectorAll(".view-btn").forEach(function (btn) {
        btn.addEventListener("click", function () {
            alert(
                "BOOKING DETAILS\n" +
                "───────────────────────────\n" +
                "Booking ID : " + (btn.dataset.id       || "-") + "\n" +
                "Module     : " + (btn.dataset.module   || "-") + "\n" +
                "Building   : " + (btn.dataset.building || "-") + "\n" +
                "Lab        : " + (btn.dataset.lab      || "-") + "\n" +
                "Date       : " + (btn.dataset.date     || "-") + "\n" +
                "Time       : " + (btn.dataset.time     || "-") + "\n" +
                "Status     : " + (btn.dataset.status   || "-") + "\n" +
                "Lecturer   : " + (btn.dataset.lecturer || "-")
            );
        });
    });
}

/* ================================================
   UTILITY FUNCTIONS
   ================================================ */

function setText(id, value) {
    var el = document.getElementById(id);
    if (el) el.textContent = (value !== null && value !== undefined) ? value : "0";
}

function fieldVal(id) {
    var el = document.getElementById(id);
    return el ? el.value.trim() : "";
}

function hide(id) {
    var el = document.getElementById(id);
    if (el) el.style.display = "none";
}

function showWarning(msg) {
    hide("successBox");
    var el = document.getElementById("warningBox");
    if (el) { el.style.display = "block"; el.textContent = msg; }
    else    { alert(msg); }
}

function showSuccess(msg) {
    hide("warningBox");
    var el = document.getElementById("successBox");
    if (el) { el.style.display = "block"; el.textContent = msg; }
    else    { alert(msg); }
}

function emptyRow(cols, msg) {
    return "<tr><td colspan='" + cols +
        "' style='text-align:center;padding:24px;color:#888;'>" +
        msg + "</td></tr>";
}

function x(str) {
    if (str === null || str === undefined) return "";
    return String(str)
        .replace(/&/g, "&amp;").replace(/</g, "&lt;")
        .replace(/>/g, "&gt;").replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

function badgeClass(status) {
    if (!status) return "success";
    switch (status.toLowerCase()) {
        case "blocked":   return "danger";
        case "upcoming":  return "success";
        case "pending":   return "warning";
        case "completed": return "primary";
        default:          return "success";
    }
}

/* ================================================
   OVERRIDES FOR INLINE JSP HANDLERS
   ================================================ */

/*
 * block-lab.jsp calls: onsubmit="return validateConflict();"
 * This intercepts it so our fetch runs instead of a page reload.
 */
function validateConflict() {
    submitBlock();
    return false;
}

/*
 * block-lab.jsp Clear Form button calls: onclick="resetMessages()"
 */
function resetMessages() {
    hide("warningBox");
    hide("successBox");
    var form = document.querySelector("form.lecturer-form");
    if (form) form.reset();
}