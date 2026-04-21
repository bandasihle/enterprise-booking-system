<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page isELIgnored="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Users</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/admin.css" />
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
      <a href="users.jsp" class="nav-item active">Users</a>
      <a href="bookings.jsp" class="nav-item">Bookings</a>
      <a href="resources.jsp" class="nav-item">Resources</a>
      <a href="complaints.jsp" class="nav-item">Complaints</a>
    </nav>
  </div>

  <div class="nav-right">
    <input type="text" class="search-box" placeholder="Search" />
  </div>
</header>

<main class="main-content">

  <section class="users-page-header">
    <div>
      <h1>Users</h1>
      <p>Manage administrators and students</p>
    </div>

    <div style="display:flex;gap:0.75rem;align-items:center;">
      <input type="text" class="users-search-box" id="userSearchBox" placeholder="Search users..." />
      <button class="primary-btn" id="suspendUserBtn">Suspend Selected (7 days)</button>
      <button class="action-btn" id="unsuspendUserBtn">Resume Selected</button>
    </div>
  </section>

  <section class="panel">
    <div class="panel-header">
      <h2>All Users</h2>
      <span id="userCount" style="font-size:0.85rem;color:#888;"></span>
    </div>

    <div class="table-wrapper">
      <table>
        <thead>
          <tr>
            <th><input type="checkbox" id="selectAll"></th>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th>Status</th>
            <th>Suspended Until</th>
            <th>Last Login</th>
          </tr>
        </thead>

        <tbody id="usersTableBody">
          <tr>
            <td colspan="7" style="text-align:center;padding:1.5rem;color:#888;">
              Loading...
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

</main>

<script>
(function () {

  /* ── helpers ── */
  function esc(s) {
    var d = document.createElement('div');
    d.textContent = String(s || '');
    return d.innerHTML;
  }

  function getSelectedIds() {
    var ids = [];
    document.querySelectorAll('.user-checkbox:checked').forEach(function (cb) {
      ids.push(cb.closest('tr').getAttribute('data-userid'));
    });
    return ids;
  }

  /* ── load & render users ── */
  function loadUsers() {
    fetch('api/users')
      .then(function (r) { return r.json(); })
      .then(function (data) {
        var users = data.users || [];
        var tbody = document.getElementById('usersTableBody');
        document.getElementById('userCount').textContent = users.length + ' user' + (users.length !== 1 ? 's' : '');

        if (!users.length) {
          tbody.innerHTML =
            '<tr><td colspan="7" style="text-align:center;padding:1.5rem;color:#888;">No users found.</td></tr>';
          return;
        }

        var html = '';
        users.forEach(function (u) {
          var statusClass, statusText;

          if (u.is_banned) {
            statusClass = 'danger';
            statusText  = 'Banned';
          } else if (u.is_suspended) {
            statusClass = 'warning';
            statusText  = 'Suspended';
          } else {
            statusClass = 'success';
            statusText  = 'Active';
          }

          var suspendedUntilCell = u.is_suspended && u.suspended_until
            ? '<span style="font-size:0.8rem;color:#b45309;">' + esc(u.suspended_until) + '</span>'
            : '<span style="color:#ccc;">—</span>';

          var name = esc(u.full_name || (u.email ? u.email.split('@')[0] : ''));

          html += '<tr data-userid="' + esc(u.id) + '" data-name="' + name.toLowerCase() + '" data-email="' + esc(u.email).toLowerCase() + '">'
            + '<td><input type="checkbox" class="user-checkbox"></td>'
            + '<td>' + name + '</td>'
            + '<td>' + esc(u.email) + '</td>'
            + '<td>' + esc(u.role) + '</td>'
            + '<td><span class="badge ' + statusClass + '">' + statusText + '</span></td>'
            + '<td>' + suspendedUntilCell + '</td>'
            + '<td>—</td>'
            + '</tr>';
        });

        tbody.innerHTML = html;
        applySearch(document.getElementById('userSearchBox').value);
      })
      .catch(function () {
        document.getElementById('usersTableBody').innerHTML =
          '<tr><td colspan="7" style="text-align:center;color:red;">Error loading users</td></tr>';
      });
  }

  /* ── live search filter ── */
  function applySearch(term) {
    term = (term || '').toLowerCase().trim();
    document.querySelectorAll('#usersTableBody tr[data-userid]').forEach(function (row) {
      var match = !term
        || row.getAttribute('data-name').includes(term)
        || row.getAttribute('data-email').includes(term);
      row.style.display = match ? '' : 'none';
    });
  }

  document.getElementById('userSearchBox').addEventListener('input', function () {
    applySearch(this.value);
  });

  /* ── select all ── */
  document.getElementById('selectAll').addEventListener('change', function () {
    var checked = this.checked;
    document.querySelectorAll('.user-checkbox').forEach(function (cb) {
      cb.checked = checked;
    });
  });

  /* ── suspend for 7 days ── */
  document.getElementById('suspendUserBtn').addEventListener('click', function () {
    var ids = getSelectedIds();
    if (!ids.length) { alert('Select at least one user.'); return; }
    if (!confirm('Suspend ' + ids.length + ' user(s) for 7 days? They will be automatically unsuspended after one week.')) return;

    fetch('api/users/suspend', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userIds: ids })
    })
    .then(function (res) { return res.json(); })
    .then(function () {
      alert('User(s) suspended for 7 days.');
      loadUsers();
    })
    .catch(function () { alert('Error suspending users.'); });
  });

  /* ── manual unsuspend ── */
  document.getElementById('unsuspendUserBtn').addEventListener('click', function () {
    var ids = getSelectedIds();
    if (!ids.length) { alert('Select at least one user.'); return; }
    if (!confirm('Unsuspend ' + ids.length + ' user(s) immediately?')) return;

    fetch('api/users/unsuspend', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userIds: ids })
    })
    .then(function (res) { return res.json(); })
    .then(function () {
      alert('User(s) unsuspended.');
      loadUsers();
    })
    .catch(function () { alert('Error unsuspending users.'); });
  });

  /* ── init ── */
  document.addEventListener('DOMContentLoaded', function () {
    loadUsers();
    document.getElementById('userSearchBox').focus();
  });

})();
</script>

</body>
</html>
