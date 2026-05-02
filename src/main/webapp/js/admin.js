document.addEventListener("DOMContentLoaded", function () {
  setActiveNav();
  setupTopbarSearch();
  setupDashboardRouting();
});

/* ------------------------------
   ACTIVE NAV HIGHLIGHTING
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
   TOP NAVBAR SEARCH ROUTING
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
   DASHBOARD QUICK BUTTON ROUTING
------------------------------ */
function setupDashboardRouting() {
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