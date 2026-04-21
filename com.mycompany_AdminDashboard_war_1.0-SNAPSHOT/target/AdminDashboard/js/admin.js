document.addEventListener("DOMContentLoaded", function () {
  setActiveNav();
  setupTopbarSearch();
  setupDashboardButtons();
  setupUsersPage();
  setupBookingsPage();
  setupResourcesPage();
  setupComplaintsPage();
  setupGenericTableButtons();
});

/* ------------------------------
   ACTIVE NAV
------------------------------ */
function setActiveNav() {
  const currentPage = window.location.pathname.split("/").pop() || "dashboard.jsp";
  const navItems = document.querySelectorAll(".nav-item");

  navItems.forEach((item) => {
    const href = item.getAttribute("href");
    item.classList.toggle("active", href === currentPage);
  });
}

/* ------------------------------
   TOP NAVBAR SEARCH
------------------------------ */
function setupTopbarSearch() {
  const topSearch = document.querySelector(".nav-right .search-box");
  if (!topSearch) return;

  topSearch.addEventListener("keydown", function (e) {
    if (e.key !== "Enter") return;

    const value = topSearch.value.trim().toLowerCase();

    if (value.includes("dashboard")) {
      window.location.href = "dashboard.jsp";
    } else if (value.includes("user") || value.includes("student") || value.includes("admin")) {
      window.location.href = "users.jsp";
    } else if (value.includes("booking") || value.includes("seat")) {
      window.location.href = "bookings.jsp";
    } else if (value.includes("resource") || value.includes("lab") || value.includes("pc")) {
      window.location.href = "resources.jsp";
    } else if (value.includes("complaint") || value.includes("issue")) {
      window.location.href = "complaints.jsp";
    } else {
      alert("No matching page found. Try: dashboard, users, bookings, resources, or complaints.");
    }
  });
}

/* ------------------------------
   DASHBOARD PAGE (REAL TIME DATA)
------------------------------ */
function setupDashboardButtons() {
  const pageTitle = document.querySelector(".hero-section h1, .page-header h1");
  if (!pageTitle || !pageTitle.textContent.toLowerCase().includes("admin dashboard")) return;

  /* ==============================
     FETCH REAL TIME DASHBOARD STATS
     ============================== */
  fetch("http://localhost:8080/Dashboard_Backend/api/admin/dashboard")
    .then(res => res.json())
    .then(data => {

      console.log("Admin Dashboard Data:", data);

      if (document.getElementById("totalUsers"))
        document.getElementById("totalUsers").innerText = data.totalUsers || 0;

      if (document.getElementById("totalBookings"))
        document.getElementById("totalBookings").innerText = data.totalBookings || 0;

      if (document.getElementById("availableLabs"))
        document.getElementById("availableLabs").innerText = data.availableLabs || 0;

      if (document.getElementById("totalComplaints"))
        document.getElementById("totalComplaints").innerText = data.totalComplaints || 0;

    })
    .catch(err => console.error("Dashboard API Error:", err));

  /* VIEW ALL BOOKINGS BUTTON */
  document.querySelectorAll(".panel-btn").forEach((btn) => {
    if (btn.textContent.trim().toLowerCase() === "view all") {
      btn.addEventListener("click", function () {
        window.location.href = "bookings.jsp";
      });
    }
  });

  /* QUICK ACTION BUTTONS */
  document.querySelectorAll(".action-btn").forEach((btn) => {
    const label = btn.textContent.trim().toLowerCase();

    btn.addEventListener("click", function () {
      if (label.includes("add user")) {
        window.location.href = "users.jsp";
      } else if (label.includes("manage labs")) {
        window.location.href = "resources.jsp";
      } else if (label.includes("view complaints")) {
        window.location.href = "complaints.jsp";
      } else if (label.includes("generate report")) {
        alert("Report generated successfully.");
      }
    });
  });
}

/* ------------------------------
   USERS PAGE
   FIXED: .users-header-text h1 matches your users.jsp
   FIXED: .users-header-actions .primary-btn targets + Add User
------------------------------ */
function setupUsersPage() {

  /*
   * Your users.jsp structure:
   * <section class="users-page-header">
   *   <div class="users-header-text">
   *     <h1>Users</h1>           ← this is what we target
   *   </div>
   *   <div class="users-header-actions">
   *     <button class="primary-btn">+ Add User</button>  ← and this
   *   </div>
   * </section>
   */
  const title = document.querySelector(".users-header-text h1");
  if (!title || title.textContent.trim().toLowerCase() !== "users") return;

  const table = document.querySelector("table tbody");
  if (!table) return;

  const searchInput  = document.querySelector(".users-search-box");
  const addUserBtn   = document.querySelector(".users-header-actions .primary-btn");
  const filterButtons = document.querySelectorAll(".filter-btn");

  /* SEARCH */
  if (searchInput) {
    searchInput.addEventListener("input", function () {
      const value = searchInput.value.trim().toLowerCase();
      table.querySelectorAll("tr").forEach((row) => {
        row.style.display = row.textContent.toLowerCase().includes(value) ? "" : "none";
      });
    });
  }

  /* + ADD USER BUTTON */
  if (addUserBtn) {
    addUserBtn.addEventListener("click", function () {
      const name = prompt("Enter user's full name:");
      if (!name) return;

      const email = prompt("Enter user's email:");
      if (!email) return;

      const role = prompt("Enter role: Student or Administrator", "Student");
      if (!role) return;

      /* Send to backend */
      fetch("http://localhost:8080/Dashboard_Backend/api/admin/users", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullName: name,
          email:    email,
          password: "temp1234",
          role:     role
        })
      })
      .then(res => res.json())
      .then(data => console.log("User saved:", data))
      .catch(err => console.error("Add User Error:", err));

      /* Update UI immediately */
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td>${escapeHtml(name)}</td>
        <td>${escapeHtml(email)}</td>
        <td>${escapeHtml(role)}</td>
        <td><span class="badge success">Active</span></td>
        <td>Just now</td>
        <td><button class="table-btn">Edit</button></td>
      `;
      table.prepend(tr);
      attachTableButtonEvents();
      alert("User added successfully.");
    });
  }

  /* FILTER BUTTONS — All / Students / Admins */
  filterButtons.forEach((btn) => {
    btn.addEventListener("click", function () {
      filterButtons.forEach((b) => b.classList.remove("active-filter"));
      btn.classList.add("active-filter");

      const filter = btn.textContent.trim().toLowerCase();
      table.querySelectorAll("tr").forEach((row) => {
        const roleCell = row.children[2]?.textContent.toLowerCase() || "";
        if (filter === "all") {
          row.style.display = "";
        } else if (filter === "students") {
          row.style.display = roleCell.includes("student") ? "" : "none";
        } else if (filter === "admins") {
          row.style.display = roleCell.includes("administrator") ? "" : "none";
        }
      });
    });
  });

  /* BAN USER */
  table.addEventListener("click", function (e) {
    const button = e.target.closest(".table-btn");
    if (!button) return;

    const label = button.textContent.trim().toLowerCase();
    const row   = button.closest("tr");

    if (label === "ban") {
      const userId = row.dataset.userid;
      fetch("http://localhost:8080/Dashboard_Backend/api/admin/users/" + userId + "/ban", {
        method: "PUT"
      })
      .then(res => res.json())
      .then(data => alert(data.message || "User banned successfully"))
      .catch(err => console.error("Ban API Error:", err));
    }
  });
}

/* ------------------------------
   BOOKINGS PAGE
------------------------------ */
function setupBookingsPage() {
  const title = document.querySelector(".topbar h1");
  if (!title || title.textContent.trim().toLowerCase() !== "bookings") return;

  const table      = document.querySelector("table tbody");
  const searchInput = document.querySelector(".topbar-right .search-box");
  const exportBtn  = document.querySelector(".panel-btn");

  if (!table) return;

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      const value = searchInput.value.trim().toLowerCase();
      table.querySelectorAll("tr").forEach((row) => {
        row.style.display = row.textContent.toLowerCase().includes(value) ? "" : "none";
      });
    });
  }

  if (exportBtn && exportBtn.textContent.trim().toLowerCase() === "export") {
    exportBtn.addEventListener("click", function () {
      exportTableToCSV("booking-records.csv");
    });
  }

  table.addEventListener("click", function (e) {
    const button = e.target.closest(".table-btn");
    if (!button) return;

    const row         = button.closest("tr");
    const statusBadge = row.querySelector(".badge");
    const label       = button.textContent.trim().toLowerCase();

    if (label === "approve") {
      statusBadge.className   = "badge success";
      statusBadge.textContent = "Approved";
      button.textContent      = "View";
      alert("Booking approved.");
    } else if (label === "view") {
      alert("Viewing booking for " + row.children[0].textContent);
    }
  });
}

/* ------------------------------
   RESOURCES PAGE
   FIXED: .topbar h1 matches your resources.jsp
   FIXED: .topbar-right .primary-btn targets + Add Lab
------------------------------ */
function setupResourcesPage() {

  /*
   * Your resources.jsp structure:
   * <header class="topbar">
   *   <div>
   *     <h1>Resources</h1>       ← this is what we target
   *   </div>
   *   <div class="topbar-right">
   *     <button class="primary-btn">+ Add Lab</button>  ← and this
   *   </div>
   * </header>
   */
  const title = document.querySelector(".topbar h1");
  if (!title || title.textContent.trim().toLowerCase() !== "resources") return;

  
}

/* ------------------------------
   COMPLAINTS PAGE (CONNECTED)
------------------------------ */
function setupComplaintsPage() {
  const title = document.querySelector(".topbar h1");
  if (!title || title.textContent.trim().toLowerCase() !== "complaints") return;

  const table      = document.querySelector("table tbody");
  const searchInput = document.querySelector(".topbar-right .search-box");
  const resolveBtn = document.querySelector(".panel-btn");

  if (!table) return;

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      const value = searchInput.value.trim().toLowerCase();
      table.querySelectorAll("tr").forEach((row) => {
        row.style.display = row.textContent.toLowerCase().includes(value) ? "" : "none";
      });
    });
  }

  if (resolveBtn && resolveBtn.textContent.trim().toLowerCase() === "resolve selected") {
    resolveBtn.addEventListener("click", function () {
      table.querySelectorAll("tr").forEach((row) => {
        const badge = row.querySelector(".badge");
        if (!badge) return;
        const text = badge.textContent.trim().toLowerCase();
        if (text === "open" || text === "urgent" || text === "in progress") {
          badge.className     = "badge success";
          badge.textContent   = "Resolved";
          const actionBtn = row.querySelector(".table-btn");
          if (actionBtn) actionBtn.textContent = "View";
        }
      });
      alert("Complaints resolved.");
    });
  }

  /* FETCH COMPLAINTS FROM BACKEND */
  fetch("http://localhost:8080/Dashboard_Backend/api/admin/complaints")
    .then(res => res.json())
    .then(data => console.log("Complaints Data:", data))
    .catch(err => console.error("Complaints API Error:", err));

  /* REVIEW / VIEW BUTTONS */
  table.addEventListener("click", function (e) {
    const button = e.target.closest(".table-btn");
    if (!button) return;

    const row   = button.closest("tr");
    const badge = row.querySelector(".badge");
    const label = button.textContent.trim().toLowerCase();

    if (label === "review") {
      badge.className     = "badge success";
      badge.textContent   = "Resolved";
      button.textContent  = "View";
      alert("Complaint reviewed and marked resolved.");

      const complaintId = row.dataset.id;
      fetch("http://localhost:8080/Dashboard_Backend/api/admin/complaints/" + complaintId, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: "RESOLVED" })
      })
      .then(res => res.json())
      .then(data => console.log("Updated:", data))
      .catch(err => console.error("Update Complaint Error:", err));

    } else {
      alert("Viewing complaint from " + row.children[0].textContent);
    }
  });
}

/* ------------------------------
   GENERIC TABLE BUTTONS
------------------------------ */
function setupGenericTableButtons() {
  attachTableButtonEvents();
}

function attachTableButtonEvents() {
  document.querySelectorAll(".table-btn").forEach((btn) => {
    if (btn.dataset.bound === "true") return;
    btn.dataset.bound = "true";

    btn.addEventListener("click", function () {
      const label = btn.textContent.trim().toLowerCase();

      if (label === "edit") {
        alert("Edit action opened.");
      }

      if (label === "ban") {
        const row    = btn.closest("tr");
        const userId = row.dataset.userid;
        fetch("http://localhost:8080/Dashboard_Backend/api/admin/users/" + userId + "/ban", {
          method: "PUT"
        })
        .then(res => res.json())
        .then(data => alert(data.message || "User banned successfully"))
        .catch(err => console.error("Ban API Error:", err));
      }
    });
  });
}

/* ------------------------------
   EXPORT TABLE TO CSV
------------------------------ */
function exportTableToCSV(filename) {
  const table = document.querySelector("table");
  if (!table) return;

  const rows = Array.from(table.querySelectorAll("tr"));
  const csv  = rows
    .map((row) =>
      Array.from(row.querySelectorAll("th, td"))
        .map((cell) => `"${cell.textContent.trim().replace(/"/g, '""')}"`)
        .join(",")
    )
    .join("\n");

  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const link = document.createElement("a");
  const url  = URL.createObjectURL(blob);

  link.setAttribute("href", url);
  link.setAttribute("download", filename);
  link.style.display = "none";
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

/* ------------------------------
   ESCAPE HTML
------------------------------ */
function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}


/*
 * Call this before any booking action.
 * If user is suspended or banned, shows a message and blocks the booking.
 *
 * Usage: checkUserSuspension(userId, function() {
 *   // proceed with booking only if this callback runs
 * });
 */
function checkUserSuspension(userId, onAllowed) {

    fetch("http://localhost:8080/Dashboard_Backend/api/users/check-suspension?userId=" + userId)
        .then(res => res.json())
        .then(data => {

            if (data.allowed) {
                // User is active — proceed with booking
                onAllowed();
            } else if (data.reason === "suspended") {
                alert("❌ Your account is suspended until " + data.suspendedUntil +
                      ".\n\nYou cannot make lab bookings during this period.");
            } else if (data.reason === "banned") {
                alert("❌ Your account has been banned.\n\nYou cannot make lab bookings.");
            } else {
                alert("❌ " + (data.message || "Account access denied."));
            }

        })
        .catch(err => {
            console.error("Suspension check error:", err);
        });
}
