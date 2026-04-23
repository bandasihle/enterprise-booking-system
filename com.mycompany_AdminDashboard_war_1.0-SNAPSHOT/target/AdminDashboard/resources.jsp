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

    /* ── Action dropdown ── */
    .action-wrap {
      position: relative;
      display: inline-block;
    }
    .action-menu {
      display: none;
      position: absolute;
      right: 0;
      top: 100%;
      background: #fff;
      border: 1px solid #ddd;
      border-radius: 8px;
      box-shadow: 0 4px 16px rgba(0,0,0,0.13);
      min-width: 160px;
      z-index: 200;
      overflow: hidden;
      margin-top: 4px;
    }
    .action-menu.open { display: block; }
    .action-menu-item {
      padding: 0.6rem 1rem;
      cursor: pointer;
      font-size: 0.9rem;
      display: flex;
      align-items: center;
      gap: 8px;
      border: none;
      background: none;
      width: 100%;
      text-align: left;
      font-family: inherit;
    }
    .action-menu-item:hover { background: #f5f5f5; }
    .action-menu-item.green { color: #16a34a; }
    .action-menu-item.green:hover { background: #f0fdf4; }
    .action-menu-item.amber { color: #d97706; }
    .action-menu-item.amber:hover { background: #fffbeb; }
    .action-menu-item.red { color: #dc2626; }
    .action-menu-item.red:hover { background: #fef2f2; }
    .action-menu-divider {
      border: none;
      border-top: 1px solid #eee;
      margin: 0;
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
  function esc(s) {
    var d = document.createElement('div');
    d.textContent = String(s || '');
    return d.innerHTML;
  }

  /* ── Load labs from API ── */
  function loadLabs() {
    fetch('api/labs')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        var labs = data.labs || [];

        /* Resource cards */
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

        /* Table rows */
        var tbody = document.getElementById('resourcesTableBody');
        if (!labs.length) {
          tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#888;">No labs found.</td></tr>';
          return;
        }

        var html = '';
        for (var j = 0; j < labs.length; j++) {
          var lab   = labs[j];
          var bc2   = lab.status === 'Active' ? 'success' : 'warning';
          var booked = Math.max((lab.total_pcs || 0) - (lab.available_pcs || 0), 0);

          html += '<tr data-labid="' + lab.id + '">'
            + '<td>' + esc(lab.name) + '</td>'
            + '<td>' + lab.total_pcs + '</td>'
            + '<td>' + lab.available_pcs + '</td>'
            + '<td>' + booked + '</td>'
            + '<td><span class="badge ' + bc2 + '">' + esc(lab.status) + '</span></td>'
            + '<td style="position:relative;">'
            +   '<button class="table-btn edit-dropdown-btn" data-labid="' + lab.id + '">'
            +     'Edit ▼'
            +   '</button>'
            +   '<div class="edit-dropdown-menu" id="menu-' + lab.id + '" '
            +     'style="display:none;position:absolute;right:0;top:100%;z-index:100;'
            +     'background:#fff;border:1px solid #ddd;border-radius:8px;'
            +     'box-shadow:0 4px 16px rgba(0,0,0,0.13);min-width:160px;overflow:hidden;">'
            +     '<button class="dropdown-item" data-labid="' + lab.id + '" data-action="setActive" '
            +       'style="display:block;width:100%;padding:10px 16px;border:none;'
            +       'background:none;text-align:left;cursor:pointer;font-size:0.9rem;">'
            +       '✓ Set Active'
            +     '</button>'
            +     '<button class="dropdown-item" data-labid="' + lab.id + '" data-action="setMaintenance" '
            +       'style="display:block;width:100%;padding:10px 16px;border:none;'
            +       'background:none;text-align:left;cursor:pointer;font-size:0.9rem;color:#b45309;">'
            +       '⚙ Set Maintenance'
            +     '</button>'
            +     '<button class="dropdown-item" data-labid="' + lab.id + '" data-action="delete" '
            +       'style="display:block;width:100%;padding:10px 16px;border:none;'
            +       'background:none;text-align:left;cursor:pointer;font-size:0.9rem;color:#c00;">'
            +       '🗑 Delete Lab'
            +     '</button>'
            +   '</div>'
            + '</td>'
            + '</tr>';
        }
        tbody.innerHTML = html;
      })
      .catch(function() {
        document.getElementById('resourcesTableBody').innerHTML =
          '<tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#c00;">Could not load labs.</td></tr>';
        document.getElementById('resourceGrid').innerHTML =
          '<p style="color:#c00;padding:1rem;">Could not load lab cards.</p>';
      });
  }

  /* ── Close ALL open dropdowns ── */
  function closeAllDropdowns() {
    document.querySelectorAll('.edit-dropdown-menu').forEach(function(m) {
      m.style.display = 'none';
    });
  }

  /*
   * ── Single delegated click handler on the whole page ──
   * Attached ONCE to document — handles all table button
   * clicks no matter how many times loadLabs() rerenders.
   * This fixes the "only works once" problem.
   */
  document.addEventListener('click', function(e) {

    /* Toggle dropdown open/close */
    var dropBtn = e.target.closest('.edit-dropdown-btn');
    if (dropBtn) {
      e.stopPropagation();
      var labId = dropBtn.dataset.labid;
      var menu  = document.getElementById('menu-' + labId);

      /* Close all others first */
      document.querySelectorAll('.edit-dropdown-menu').forEach(function(m) {
        if (m !== menu) m.style.display = 'none';
      });

      /* Toggle this one */
      menu.style.display = (menu.style.display === 'none' || !menu.style.display)
        ? 'block'
        : 'none';
      return;
    }

    /* Handle dropdown item clicks */
    var item = e.target.closest('.dropdown-item');
    if (item) {
      e.stopPropagation();
      var labId  = item.dataset.labid;
      var action = item.dataset.action;
      closeAllDropdowns();

      if (action === 'setActive') {
        updateLabStatus(labId, 'Active');

      } else if (action === 'setMaintenance') {
        updateLabStatus(labId, 'Maintenance');

      } else if (action === 'delete') {
        if (!confirm('Are you sure you want to delete this lab? This cannot be undone.')) return;
        deleteLab(labId);
      }
      return;
    }

    /* Click anywhere else → close all dropdowns */
    closeAllDropdowns();
  });

  /* ── Update lab status ── */
  function updateLabStatus(labId, newStatus) {
    fetch('api/labs/update', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: labId, status: newStatus })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
      if (res.success) {
        loadLabs(); /* Refresh table and cards */
      } else {
        alert(res.message || 'Failed to update status.');
      }
    })
    .catch(function() {
      alert('Server error. Please try again.');
    });
  }

  /* ── Delete lab ── */
  function deleteLab(labId) {
    fetch('api/labs/delete', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: labId })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
      if (res.success) {
        loadLabs(); /* Refresh table and cards */
      } else {
        alert(res.message || 'Failed to delete lab.');
      }
    })
    .catch(function() {
      alert('Server error. Please try again.');
    });
  }

  /* ── Modal open / close ── */
  var modal      = document.getElementById('addLabModal');
  var modalError = document.getElementById('modalError');

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

  modal.addEventListener('click', function(e) {
    if (e.target === modal) closeModal();
  });

  /* ── Submit Add Lab ── */
  document.getElementById('submitAddLabBtn').addEventListener('click', function() {
    var name     = document.getElementById('labName').value.trim();
    var totalPcs = document.getElementById('labTotalPcs').value.trim();
    var status   = document.getElementById('labStatus').value;

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
        loadLabs();
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
  loadLabs();

})();
  </script>

</body>
</html>