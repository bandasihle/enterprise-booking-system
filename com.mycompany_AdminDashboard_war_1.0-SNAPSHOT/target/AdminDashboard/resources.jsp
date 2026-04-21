<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Resources</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/admin.css">

  <style>
    /* ── Modal overlay ── */
    .modal-overlay {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.45);
      z-index: 999;
      align-items: center;
      justify-content: center;
    }
    .modal-overlay.open { display: flex; }

    .modal-box {
      background: #fff;
      border-radius: 12px;
      padding: 2rem;
      width: 100%;
      max-width: 420px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.18);
    }
    .modal-box h2 { margin: 0 0 1.25rem; font-size: 1.2rem; }

    .modal-box label {
      display: block;
      font-size: 0.85rem;
      font-weight: 600;
      margin-bottom: 0.3rem;
      color: #444;
    }
    .modal-box input,
    .modal-box select {
      width: 100%;
      padding: 0.55rem 0.75rem;
      border: 1px solid #ddd;
      border-radius: 7px;
      font-size: 0.95rem;
      margin-bottom: 1rem;
      box-sizing: border-box;
    }
    .modal-box input:focus,
    .modal-box select:focus { outline: 2px solid #2563eb; border-color: transparent; }

    .modal-actions { display: flex; gap: 0.75rem; justify-content: flex-end; margin-top: 0.5rem; }
    .modal-actions .cancel-btn {
      padding: 0.55rem 1.2rem;
      border: 1px solid #ddd;
      border-radius: 7px;
      background: #fff;
      cursor: pointer;
      font-size: 0.9rem;
    }
    .modal-actions .cancel-btn:hover { background: #f5f5f5; }
    .modal-actions .primary-btn { padding: 0.55rem 1.4rem; }

    #modalError {
      color: #c00;
      font-size: 0.85rem;
      margin-bottom: 0.75rem;
      display: none;
    }
  </style>
</head>
<body>

  <header class="top-navbar">
    <div class="nav-left">
      <div class="brand">
        <div class="brand-icon">
          <img src="images/logooo.jpeg" alt="EBS Logo">
        </div>
        <div class="divider"></div>
        <div class="brand-text">EBS Admin</div>
      </div>

      <nav class="nav-menu">
        <a href="dashboard.jsp" class="nav-item">Dashboard</a>
        <a href="users.jsp" class="nav-item">Users</a>
        <a href="bookings.jsp" class="nav-item">Bookings</a>
        <a href="resources.jsp" class="nav-item active">Resources</a>
        <a href="complaints.jsp" class="nav-item">Complaints</a>
      </nav>
    </div>

    <div class="nav-right">
      <a href="#" class="right-link">All EBS</a>
      <div class="search-wrap">
        <input type="text" class="search-box" placeholder="Search" />
      </div>
    </div>
  </header>

  <main class="main-content">
    <header class="topbar">
      <div>
        <h1>Resources</h1>
        <p>Manage labs, seats, and computer availability</p>
      </div>
      <div class="topbar-right">
        <button class="primary-btn" id="openAddLabBtn">+ Add Lab</button>
      </div>
    </header>

    <section class="resource-grid" id="resourceGrid">
      <!-- Populated by JS -->
    </section>

    <section class="panel">
      <div class="panel-header">
        <h2>Lab Resource Table</h2>
        <button class="panel-btn">Update Status</button>
      </div>
      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Lab</th>
              <th>Total PCs</th>
              <th>Available</th>
              <th>Booked</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody id="resourcesTableBody">
            <tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#888;">Loading...</td></tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>

  <!-- ── Add Lab Modal ── -->
  <div class="modal-overlay" id="addLabModal">
    <div class="modal-box">
      <h2>Add New Lab</h2>
      <div id="modalError"></div>

      <label for="labName">Lab Name</label>
      <input type="text" id="labName" placeholder="e.g. Lab A" />

      <label for="labTotalPcs">Total PCs</label>
      <input type="number" id="labTotalPcs" placeholder="e.g. 30" min="1" />

      <label for="labStatus">Status</label>
      <select id="labStatus">
        <option value="Active">Active</option>
        <option value="Maintenance">Maintenance</option>
      </select>

      <div class="modal-actions">
        <button class="cancel-btn" id="closeAddLabBtn">Cancel</button>
        <button class="primary-btn" id="submitAddLabBtn">Add Lab</button>
      </div>
    </div>
  </div>

  <script>
  (function () {
    function esc(s) { var d = document.createElement('div'); d.textContent = String(s || ''); return d.innerHTML; }

    /* ── Load labs from API ── */
    function loadLabs() {
      fetch('api/labs')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var labs = data.labs || [];

          // Resource cards
          var grid = document.getElementById('resourceGrid');
          if (!labs.length) {
            grid.innerHTML = '<p style="color:#888;padding:1rem;">No labs found.</p>';
          } else {
            var cards = '';
            for (var i = 0; i < labs.length; i++) {
              var l  = labs[i];
              var bc = l.status === 'Active' ? 'success' : 'warning';
              cards += '<div class="resource-card">'
                + '<h3>' + esc(l.name) + '</h3>'
                + '<p>' + l.available_pcs + ' PCs available</p>'
                + '<span class="badge ' + bc + '">' + esc(l.status) + '</span>'
                + '</div>';
            }
            grid.innerHTML = cards;
          }

          // Table rows
          var tbody = document.getElementById('resourcesTableBody');
          if (!labs.length) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#888;">No labs found.</td></tr>';
            return;
          }
          var html = '';
          for (var j = 0; j < labs.length; j++) {
            var lab  = labs[j];
            var bc2  = lab.status === 'Active' ? 'success' : 'warning';
            var booked = Math.max((lab.total_pcs || 0) - (lab.available_pcs || 0), 0);
            html += '<tr data-labid="' + lab.id + '">'
              + '<td>' + esc(lab.name) + '</td>'
              + '<td>' + lab.total_pcs + '</td>'
              + '<td>' + lab.available_pcs + '</td>'
              + '<td>' + booked + '</td>'
              + '<td><span class="badge ' + bc2 + '">' + esc(lab.status) + '</span></td>'
              + '<td><button class="table-btn" data-labid="' + lab.id + '" data-action="edit">Edit</button></td>'
              + '</tr>';
          }
          tbody.innerHTML = html;

          // Edit button — toggle Active / Maintenance
          tbody.addEventListener('click', function(e) {
            var btn = e.target.closest('[data-action="edit"]');
            if (!btn) return;
            var labId = btn.dataset.labid;
            var row   = btn.closest('tr');
            var badge = row.querySelector('.badge');
            var newStatus = badge.textContent.trim() === 'Active' ? 'Maintenance' : 'Active';
            fetch('api/labs/update', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: '{"id":"' + labId + '","status":"' + newStatus + '"}'
            }).then(function(r){ return r.json(); })
              .then(function(res){ if (res.success) loadLabs(); else alert(res.message || 'Failed'); })
              .catch(function(){ alert('Server error.'); });
          });
        })
        .catch(function() {
          document.getElementById('resourcesTableBody').innerHTML =
            '<tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#c00;">Could not load labs.</td></tr>';
          document.getElementById('resourceGrid').innerHTML =
            '<p style="color:#c00;padding:1rem;">Could not load lab cards.</p>';
        });
    }

    /* ── Modal open / close ── */
    var modal        = document.getElementById('addLabModal');
    var modalError   = document.getElementById('modalError');

    function openModal() {
      document.getElementById('labName').value     = '';
      document.getElementById('labTotalPcs').value = '';
      document.getElementById('labStatus').value   = 'Active';
      modalError.style.display = 'none';
      modalError.textContent   = '';
      modal.classList.add('open');
      document.getElementById('labName').focus();
    }

    function closeModal() {
      modal.classList.remove('open');
    }

    document.getElementById('openAddLabBtn').addEventListener('click', openModal);
    document.getElementById('closeAddLabBtn').addEventListener('click', closeModal);

    // Close when clicking outside the box
    modal.addEventListener('click', function(e) {
      if (e.target === modal) closeModal();
    });

    /* ── Submit Add Lab ── */
    document.getElementById('submitAddLabBtn').addEventListener('click', function () {
      var name     = document.getElementById('labName').value.trim();
      var totalPcs = document.getElementById('labTotalPcs').value.trim();
      var status   = document.getElementById('labStatus').value;

      // Basic validation
      if (!name) {
        modalError.textContent   = 'Lab name is required.';
        modalError.style.display = 'block';
        document.getElementById('labName').focus();
        return;
      }
      if (!totalPcs || isNaN(totalPcs) || parseInt(totalPcs) < 1) {
        modalError.textContent   = 'Enter a valid number of PCs (minimum 1).';
        modalError.style.display = 'block';
        document.getElementById('labTotalPcs').focus();
        return;
      }

      // Disable button to prevent double submit
      var btn = document.getElementById('submitAddLabBtn');
      btn.disabled    = true;
      btn.textContent = 'Adding...';

      fetch('api/labs/add', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name:      name,
          total_pcs: totalPcs,
          status:    status
        })
      })
      .then(function(r) { return r.json(); })
      .then(function(res) {
        if (res.success) {
          closeModal();
          loadLabs(); // ← refreshes table and cards immediately
        } else {
          modalError.textContent   = res.message || 'Failed to add lab.';
          modalError.style.display = 'block';
        }
      })
      .catch(function() {
        modalError.textContent   = 'Server error. Please try again.';
        modalError.style.display = 'block';
      })
      .finally(function() {
        btn.disabled    = false;
        btn.textContent = 'Add Lab';
      });
    });

   /* ── Init ── */
loadLabs(); // Call it directly since the script is already at the end of the body
  })();
  </script>


</body>
</html>