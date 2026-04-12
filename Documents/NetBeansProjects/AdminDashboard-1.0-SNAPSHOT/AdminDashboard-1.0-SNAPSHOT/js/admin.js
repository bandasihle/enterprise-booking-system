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
  const currentPage = window.location.pathname.split("/").pop() || "index.html";
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
      window.location.href = "index.html";
    } else if (value.includes("user") || value.includes("student") || value.includes("admin")) {
      window.location.href = "users.html";
    } else if (value.includes("booking") || value.includes("seat")) {
      window.location.href = "bookings.html";
    } else if (value.includes("resource") || value.includes("lab") || value.includes("pc")) {
      window.location.href = "resources.html";
    } else if (value.includes("complaint") || value.includes("issue")) {
      window.location.href = "complaints.html";
    } else {
      alert("No matching page found. Try: dashboard, users, bookings, resources, or complaints.");
    }
  });
}

/* ------------------------------
   DASHBOARD PAGE
------------------------------ */
function setupDashboardButtons() {
  const pageTitle = document.querySelector(".hero-section h1, .page-header h1");
  if (!pageTitle || !pageTitle.textContent.toLowerCase().includes("admin dashboard")) return;

  document.querySelectorAll(".panel-btn").forEach((btn) => {
    if (btn.textContent.trim().toLowerCase() === "view all") {
      btn.addEventListener("click", function () {
        window.location.href = "bookings.html";
      });
    }
  });

  document.querySelectorAll(".action-btn").forEach((btn) => {
    const label = btn.textContent.trim().toLowerCase();

    btn.addEventListener("click", function () {
      if (label.includes("add user")) {
        window.location.href = "users.html";
      } else if (label.includes("manage labs")) {
        window.location.href = "resources.html";
      } else if (label.includes("view complaints")) {
        window.location.href = "complaints.html";
      } else if (label.includes("generate report")) {
        alert("Report generated successfully.");
      }
    });
  });


  /* ==============================
     FETCH ADMIN DASHBOARD DATA
     ============================== */
  fetch("http://localhost:8080/Dashboard_Backend/api/admin/dashboard")
    .then(res => res.json())
    .then(data => {
      
      console.log("Admin Dashboard Data:", data);

      if (document.getElementById("students"))
        document.getElementById("students").innerText = data.activeStudents;

      if (document.getElementById("lecturers"))
        document.getElementById("lecturers").innerText = data.activeLecturers;

      if (document.getElementById("bookings"))
        document.getElementById("bookings").innerText = data.bookingsToday;

      if (document.getElementById("complaints"))
        document.getElementById("complaints").innerText = data.pendingComplaints;

    })
    .catch(err => console.error("Dashboard API Error:", err));
}


/* ------------------------------ */
/* USERS PAGE                     */
/* ------------------------------ */
function setupUsersPage() {
  const title = document.querySelector(".users-header-text h1, .topbar h1");
  if (!title || title.textContent.trim().toLowerCase() !== "users") return;

  const table = document.querySelector("table tbody");
  if (!table) return;

  const searchInput =
    document.querySelector(".users-search-box") ||
    document.querySelector(".topbar-right .search-box");

  const addUserBtn = document.querySelector(".primary-btn");
  const filterButtons = document.querySelectorAll(".filter-btn");

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      const value = searchInput.value.trim().toLowerCase();
      const rows = table.querySelectorAll("tr");

      rows.forEach((row) => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(value) ? "" : "none";
      });
    });
  }

  if (addUserBtn && addUserBtn.textContent.toLowerCase().includes("add user")) {
    addUserBtn.addEventListener("click", function () {

      const name = prompt("Enter user's full name:");
      if (!name) return;

      const email = prompt("Enter user's email:");
      if (!email) return;

      const role = prompt("Enter role: Student or Administrator", "Student");
      if (!role) return;

      /* ============================== */
      /* SEND USER TO BACKEND 🔥        */
      /* ============================== */
     /* ============================== */
/* SEND USER TO BACKEND 🔥        */
/* ============================== */
// 🔥 USE YOUR ACTUAL PROJECT NAME HERE
const BASE_URL = "http://localhost:8080/Dashboard_Backend"; // or AdminDashboard

fetch(`${BASE_URL}/api/admin/users`, {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    name: name,
    email: email,
    role: role
  })
}) 
      .then(async (res) => {
        // 🔥 CRITICAL FIX: Check if response is JSON or HTML error
        const contentType = res.headers.get("content-type");
        
        if (!contentType || !contentType.includes("application/json")) {
          // Server returned HTML (404/500 error page)
          const text = await res.text();
          console.error("❌ Server returned HTML, not JSON:", text.substring(0, 100));
          throw new Error("Backend error - check if server is running and URL is correct");
        }
        
        return res.json();
      })
      .then((data) => {
        console.log("✅ Backend response:", data);
        
        if (data.success) {
          alert("✅ " + data.message);
          
          // 🔥 ONLY add to UI if backend succeeded
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
          
        } else {
          alert("❌ Backend error: " + data.message);
        }
      })
      .catch((err) => {
        console.error("Add User Error:", err);
        alert("❌ " + err.message);
        
        // 🔥 DEBUG: Show what URL was tried
        console.log("Tried URL:", "http://localhost:8080/Dashboard_Backend/api/admin/users");
      });

    });
  }

  filterButtons.forEach((btn) => {
    btn.addEventListener("click", function () {
      filterButtons.forEach((b) => b.classList.remove("active-filter"));
      btn.classList.add("active-filter");

      const filter = btn.textContent.trim().toLowerCase();
      const rows = table.querySelectorAll("tr");

      rows.forEach((row) => {
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
}

/* ------------------------------
   BOOKINGS PAGE
------------------------------ */
function setupBookingsPage() {
  const title = document.querySelector(".topbar h1");
  if (!title || title.textContent.trim().toLowerCase() !== "bookings") return;

  const table = document.querySelector("table tbody");
  if (!table) return;

  const searchInput = document.querySelector(".topbar-right .search-box");
  const exportBtn = document.querySelector(".panel-btn");

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      const value = searchInput.value.trim().toLowerCase();
      const rows = table.querySelectorAll("tr");

      rows.forEach((row) => {
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

    const row = button.closest("tr");
    const statusBadge = row.querySelector(".badge");
    const label = button.textContent.trim().toLowerCase();

    if (label === "approve") {
      statusBadge.className = "badge success";
      statusBadge.textContent = "Approved";
      button.textContent = "View";
      alert("Booking approved.");
    } else if (label === "view") {
      alert("Viewing booking for " + row.children[0].textContent);
    }
  });
}

/* ------------------------------
   RESOURCES PAGE
------------------------------ */
function setupResourcesPage() {
  const title = document.querySelector(".topbar h1");
  if (!title || title.textContent.trim().toLowerCase() !== "resources") return;

  const addLabBtn = document.querySelector(".primary-btn");
  const updateBtn = document.querySelector(".panel-btn");
  const resourceGrid = document.querySelector(".resource-grid");
  const tableBody = document.querySelector("table tbody");

 if (addLabBtn && addLabBtn.textContent.toLowerCase().includes("add lab")) {
  addLabBtn.addEventListener("click", function () {

    const labName = prompt("Enter lab name:", "Lab 5");
    if (!labName) return;

    const totalPcs = prompt("Enter total PCs:", "30");
    if (!totalPcs) return;

    const available = prompt("Enter available PCs:", totalPcs);
    if (!available) return;

    const status = Number(available) > 0 ? "Active" : "Maintenance";
    const badgeClass = Number(available) > 0 ? "success" : "warning";

    /* ==============================
       SEND LAB TO BACKEND (✔ CORRECT PLACE)
       ============================== */
    fetch("http://localhost:8080/Dashboard_Backend/api/admin/resources", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"A
      },
      body: JSON.stringify({
        name: labName,
        totalPcs: Number(totalPcs),
        availablePcs: Number(available)
      })
    })
    .then(res => res.json())
    .then(data => {
      console.log("Lab saved:", data);
    })
    .catch(err => console.error("Add Lab Error:", err));

    // 👉 KEEP YOUR UI CODE (DON’T REMOVE)
    if (resourceGrid) {
      const card = document.createElement("div");
      card.className = "resource-card";
      card.innerHTML = `
        <h3>${escapeHtml(labName)}</h3>
        <p>${escapeHtml(available)} PCs available</p>
        <span class="badge ${badgeClass}">${status}</span>
      `;
      resourceGrid.appendChild(card);
    }

    if (tableBody) {
      const booked = Math.max(Number(totalPcs) - Number(available), 0);
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td>${escapeHtml(labName)}</td>
        <td>${escapeHtml(totalPcs)}</td>
        <td>${escapeHtml(available)}</td>
        <td>${booked}</td>
        <td><span class="badge ${badgeClass}">${status}</span></td>
        <td><button class="table-btn">Edit</button></td>
      `;
      tableBody.appendChild(tr);
    }

    attachTableButtonEvents();
    alert("Lab added successfully.");

  });
}
  
}

/* ------------------------------
   COMPLAINTS PAGE
------------------------------ */
function setupComplaintsPage() {
  const title = document.querySelector(".topbar h1");
  if (!title || title.textContent.trim().toLowerCase() !== "complaints") return;

  const table = document.querySelector("table tbody");
  if (!table) return;

  const searchInput = document.querySelector(".topbar-right .search-box");
  const resolveBtn = document.querySelector(".panel-btn");

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      const value = searchInput.value.trim().toLowerCase();
      const rows = table.querySelectorAll("tr");

      rows.forEach((row) => {
        row.style.display = row.textContent.toLowerCase().includes(value) ? "" : "none";
      });
    });
  }

  if (resolveBtn && resolveBtn.textContent.trim().toLowerCase() === "resolve selected") {
    resolveBtn.addEventListener("click", function () {
      const rows = table.querySelectorAll("tr");

      rows.forEach((row) => {
        const badge = row.querySelector(".badge");
        if (!badge) return;

        const text = badge.textContent.trim().toLowerCase();
        if (text === "open" || text === "urgent" || text === "in progress") {
          badge.className = "badge success";
          badge.textContent = "Resolved";
          const actionBtn = row.querySelector(".table-btn");
          if (actionBtn) actionBtn.textContent = "View";
        }
      });

      alert("Complaints resolved.");
    });
  }

  table.addEventListener("click", function (e) {
    const button = e.target.closest(".table-btn");
    if (!button) return;

    const row = button.closest("tr");
    const badge = row.querySelector(".badge");
    const label = button.textContent.trim().toLowerCase();

    if (label === "review") {
      badge.className = "badge success";
      badge.textContent = "Resolved";
      button.textContent = "View";
      alert("Complaint reviewed and marked resolved.");
    } else {
      alert("Viewing complaint from " + row.children[0].textContent);
    }
  });

 /* ==============================
     FETCH COMPLAINTS FROM BACKEND
     ============================== */
  fetch("http://localhost:8080/Dashboard_Backend/api/admin/complaints")
    .then(res => res.json())
    .then(data => {

      console.log("Complaints Data:", data);

    })
    .catch(err => console.error("Complaints API Error:", err));

  table.addEventListener("click", function (e) {
    const button = e.target.closest(".table-btn");
    if (!button) return;

    const row = button.closest("tr");
    const label = button.textContent.trim().toLowerCase();

    if (label === "review") {

      const complaintId = row.dataset.id;

      fetch("http://localhost:8080/Dashboard_Backend/api/admin/complaints/" + complaintId, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          status: "RESOLVED"
        })
      })
      .then(res => res.json())
      .then(data => {
        console.log("Updated:", data);
      })
      .catch(err => console.error("Update Complaint Error:", err));
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

        const row = btn.closest("tr");
        const userId = row.dataset.userid;

        fetch("http://localhost:8080/Dashboard_Backend/api/admin/users/" + userId + "/ban", {
          method: "PUT"
        })
        .then(res => res.json())
        .then(data => {
          alert(data.message || "User banned successfully");
        })
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
  const csv = rows
    .map((row) =>
      Array.from(row.querySelectorAll("th, td"))
        .map((cell) => `"${cell.textContent.trim().replace(/"/g, '""')}"`)
        .join(",")
    )
    .join("\n");

  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const link = document.createElement("a");
  const url = URL.createObjectURL(blob);

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


/* =========================================================
   LECTURER DASHBOARD (TO BE IMPLEMENTED)

   Backend endpoints ready:

   POST /api/lecturer/block
   GET  /api/lecturer/my-blocks

   Example usage:

   fetch("http://localhost:8080/Dashboard_Backend/api/lecturer/block", {
     method: "POST",
     headers: { "Content-Type": "application/json" },
     body: JSON.stringify({
       labId: 3,
       moduleCode: "PROG3A",
       moduleName: "Programming"
     })
   })
   .then(res => res.json())
   .then(data => console.log(data));

   NOTE:
   - UI must collect labId, moduleCode, moduleName
   - Then call this endpoint
   - Response will confirm block

========================================================= */

