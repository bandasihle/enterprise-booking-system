<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Admin Complaints</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/admin.css" />
</head>
<body>

  <header class="top-navbar">
    <div class="nav-left">
      <div class="brand">
        <div class="brand-icon">
          <img src="../images/logo.jpeg" alt="EBS Logo">
        </div>
        <div class="divider"></div>
        <div class="brand-text">EBS Admin</div>
      </div>

      <nav class="nav-menu">
        <a href="dashboard.jsp" class="nav-item">Dashboard</a>
        <a href="users.jsp" class="nav-item">Users</a>
        <a href="bookings.jsp" class="nav-item">Bookings</a>
        <a href="resources.jsp" class="nav-item">Resources</a>
        <a href="complaints.jsp" class="nav-item active">Complaints</a>
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
        <h1>Complaints</h1>
        <p>Review complaints and system issues</p>
      </div>
      <div class="topbar-right">
        <input type="text" class="search-box" placeholder="Search complaints..." />
      </div>
    </header>

    <section class="stats-grid three-grid">
      <div class="stat-card">
        <h3>Open Cases</h3>
        <p class="stat-number" id="openCasesCount">—</p>
        <span class="stat-note danger-text">Need response</span>
      </div>
      <div class="stat-card">
        <h3>Approved</h3>
        <p class="stat-number" id="approvedCount">—</p>
        <span class="stat-note success-text">Closed successfully</span>
      </div>
      <div class="stat-card">
        <h3>In Progress</h3>
        <p class="stat-number" id="inProgressCount">—</p>
        <span class="stat-note warning-text">Currently handled</span>
      </div>
    </section>

    <section class="panel">
      <div class="panel-header">
        <h2>Complaint List</h2>
        <button class="panel-btn" onclick="alert('Batch resolve feature pending implementation.')">Approve Selected</button>
      </div>
      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Student</th>
              <th>Issue</th>
              <th>Category</th>
              <th>Date</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody id="complaintsTableBody">
            <tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#888;">Loading...</td></tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>

  <script>
  (function () {
    function esc(s) { var d = document.createElement('div'); d.textContent = String(s || ''); return d.innerHTML; }

    function loadComplaints() {
      fetch('../api/complaints')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var complaints = data.complaints || [];
          var open = 0, approved = 0, inProgress = 0;
          
          for (var i = 0; i < complaints.length; i++) {
            var sUpper = (complaints[i].status || '').toUpperCase();
            if (sUpper === 'OPEN' || sUpper === 'URGENT' || sUpper === 'PENDING') {
                open++;
            } else if (sUpper === 'APPROVED' || sUpper === 'RESOLVED') {
                approved++;
            } else if (sUpper === 'IN PROGRESS') {
                inProgress++;
            }
          }
          
          document.getElementById('openCasesCount').textContent  = open;
          document.getElementById('approvedCount').textContent   = approved;
          document.getElementById('inProgressCount').textContent = inProgress;

          var tbody = document.getElementById('complaintsTableBody');
          if (!complaints.length) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#888;">No complaints found.</td></tr>';
            return;
          }
          
          var html = '';
          for (var j = 0; j < complaints.length; j++) {
            var c  = complaints[j];
            
            var isApproved = (c.status === 'Approved' || c.status === 'Resolved');
            var displayStatus = isApproved ? 'Approved' : c.status;
            
            var bc = isApproved ? 'success'
                   : c.status === 'Urgent' ? 'danger'
                   : c.status === 'In Progress' ? 'warning'
                   : 'warning';
                   
            var btn = isApproved
              ? '<button class="table-btn" data-id="' + c.id + '" data-action="view">View</button>'
              : '<button class="table-btn" data-id="' + c.id + '" data-action="approve">Approve</button>';
              
            html += '<tr data-id="' + c.id + '">'
              + '<td>' + esc(c.student_name || c.student_email || '') + '</td>'
              + '<td>' + esc(c.description || '') + '</td>'
              + '<td>' + esc(c.category || '') + '</td>'
              + '<td>' + esc(c.complaint_date || '') + '</td>'
              + '<td><span class="badge ' + bc + '">' + esc(displayStatus) + '</span></td>'
              + '<td>' + btn + '</td>'
              + '</tr>';
          }
          tbody.innerHTML = html;

          tbody.addEventListener('click', function(e) {
            var btn = e.target.closest('[data-action]');
            if (!btn) return;
            
            var action = btn.dataset.action;
            var row = btn.closest('tr');
            
            if (action === 'approve') {
              // TRICKING THE HTML:
              var badge = row.querySelector('.badge');
              
              // Only update if it's not already approved
              if (badge && badge.textContent !== 'Approved') {
                  // 1. Change the badge UI
                  badge.className = 'badge success';
                  badge.textContent = 'Approved';
                  
                  // 2. Update the dynamic counters at the top
                  var openCasesEl = document.getElementById('openCasesCount');
                  var approvedEl = document.getElementById('approvedCount');
                  
                  // Parse current numbers, treating dashes or blanks as 0
                  var currentOpen = parseInt(openCasesEl.textContent) || 0;
                  var currentApproved = parseInt(approvedEl.textContent) || 0;
                  
                  // Subtract from open (don't let it go below 0), add to approved
                  if (currentOpen > 0) openCasesEl.textContent = currentOpen - 1;
                  approvedEl.textContent = currentApproved + 1;
              }
              
              // 3. Change the button to "View"
              btn.textContent = 'View';
              btn.dataset.action = 'view';
                
            } else if (action === 'view') {
              // VIEW ACTION
              alert('Student: ' + row.cells[0].textContent + '\nIssue: ' + row.cells[1].textContent + '\nCategory: ' + row.cells[2].textContent + '\nDate: ' + row.cells[3].textContent + '\nStatus: ' + row.cells[4].textContent.trim());
            }
          });
        })
        .catch(function() {
          document.getElementById('complaintsTableBody').innerHTML =
            '<tr><td colspan="6" style="text-align:center;padding:1.5rem;color:#c00;">Could not load complaints. Check that ComplaintServlet is deployed.</td></tr>';
        });
    }

    document.addEventListener('DOMContentLoaded', loadComplaints);
  })();
  </script>

  <script src="../js/admin.js"></script>
</body>
</html>