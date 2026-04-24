<%-- 
    Document   : login
    Created on : 16 Mar 2026, 13:45:08
    Author     : ICTS
--%>


<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Admin Login – Enterprise Booking System</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"/>
  <style>
    body { display: flex; flex-direction: column; }

    /* LEFT — dark charcoal, unique to admin */
    .left-panel {
      background: linear-gradient(145deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
    }

    .left-panel::before {
      content: ''; position: absolute; inset: 0;
      background:
        radial-gradient(ellipse at 80% 10%, rgba(239,68,68,0.1) 0%, transparent 55%),
        radial-gradient(ellipse at 10% 90%, rgba(0,0,0,0.3)     0%, transparent 55%);
    }

    /* Red accent top bar */
    .admin-accent { position: absolute; top:0; left:0; right:0; height:4px; background: linear-gradient(to right, #EF4444, #F97316, #EF4444); }

    .left-panel .l-tag {
      background: rgba(239,68,68,0.2); color: #FCA5A5;
      border: 1px solid rgba(239,68,68,0.3);
    }

    .left-panel h2  { color: white; }
    .left-panel > p { color: rgba(255,255,255,0.65); }
    .left-panel .feat-list li { color: rgba(255,255,255,0.85); }
    .left-panel .feat-ico { background: rgba(255,255,255,0.08); }
    .left-panel .dc { border: 1px solid rgba(255,255,255,0.05); }

    .shield-wrap {
      width: 64px; height: 64px;
      background: rgba(239,68,68,0.15);
      border: 2px solid rgba(239,68,68,0.3);
      border-radius: 16px;
      display: flex; align-items: center; justify-content: center;
      font-size: 28px; margin-bottom: 24px;
    }

    /* RIGHT — very dark background */
    .right-panel { background: #0f172a; }

    .admin-card {
      background: #1e293b; border-radius: 20px; padding: 44px 40px;
      width: 100%; max-width: 420px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.4);
      border: 1px solid #334155;
      position: relative; overflow: hidden;
    }

    /* Red top line on card */
    .admin-card::before {
      content: ''; position: absolute; top:0; left:0; right:0; height:3px;
      background: linear-gradient(to right, #EF4444, #F97316);
    }

    .admin-card .form-title { color: white; }
    .admin-card .form-sub   { color: #94A3B8; }
    .admin-card .form-sub a { color: #60A5FA; }
    .admin-card label { color: #CBD5E1; }

    .admin-card input[type=email],
    .admin-card input[type=password],
    .admin-card input[type=text] {
      background: #0f172a; border-color: #334155; color: white;
    }

    .admin-card input::placeholder { color: #475569; }

    .admin-card input:focus {
      border-color: #EF4444;
      box-shadow: 0 0 0 3px rgba(239,68,68,0.15);
    }

    .admin-card .toggle-pw { color: #475569; }
    .admin-card .toggle-pw:hover { color: #EF4444; }
    .admin-card .fmsg { color: #FCA5A5; }

    .admin-card .toast.err {
      background: rgba(239,68,68,0.1); color: #FCA5A5; border-color: rgba(239,68,68,0.3);
    }
    .admin-card .toast.ok {
      background: rgba(22,163,74,0.1); color: #86EFAC; border-color: rgba(22,163,74,0.3);
    }

    /* Warning box */
    .admin-warning {
      background: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.2);
      border-radius: 10px; padding: 12px 14px; margin-bottom: 20px;
      display: flex; align-items: flex-start; gap: 10px;
    }
    .admin-warning p { font-size: 12px; color: #FCA5A5; line-height: 1.5; margin: 0; }

    /* Red submit button */
    .btn-admin {
      width: 100%; padding: 14px; border: none; border-radius: 10px;
      background: linear-gradient(135deg, #EF4444, #DC2626);
      color: white; font-size: 15px; font-weight: 700;
      font-family: inherit; cursor: pointer;
      box-shadow: 0 4px 14px rgba(239,68,68,0.35);
      transition: all 0.2s; margin-top: 8px;
      display: flex; align-items: center; justify-content: center; gap: 8px;
    }

    .btn-admin:hover {
      background: linear-gradient(135deg, #DC2626, #B91C1C);
      transform: translateY(-1px);
      box-shadow: 0 6px 20px rgba(239,68,68,0.4);
    }

    .btn-admin:disabled {
      background: #374151; box-shadow: none;
      cursor: not-allowed; transform: none; color: #6B7280;
    }

    .forgot-row { display: flex; justify-content: flex-end; margin-bottom: 16px; margin-top: -6px; }
    .forgot-row a { font-size: 13px; color: #60A5FA; text-decoration: none; font-weight: 600; }
    .forgot-row a:hover { text-decoration: underline; }

    .admin-divider { display: flex; align-items: center; gap: 12px; margin: 20px 0; }
    .admin-divider::before, .admin-divider::after { content:''; flex:1; height:1px; background:#334155; }
    .admin-divider span { font-size: 12px; color: #475569; }

    .bottom-link { text-align: center; margin-top: 18px; font-size: 13px; color: #475569; }
    .bottom-link a { color: #60A5FA; font-weight: 600; text-decoration: none; }
    .bottom-link a:hover { text-decoration: underline; }

    /* Admin nav tag */
    .admin-nav-tag {
      background: rgba(239,68,68,0.1); color: #EF4444;
      border: 1px solid rgba(239,68,68,0.2);
      font-size: 11px; font-weight: 700;
      padding: 3px 10px; border-radius: 6px;
      letter-spacing: 0.06em; text-transform: uppercase;
    }
  </style>
</head>
<body>

<!-- NAV -->
<nav>
  <a href="../../index.jsp" class="nav-brand">
    <div class="logo-img-wrap">
      <img src="../../assets/logo.png" alt="Logo"
           onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'"/>
      <div class="logo-fallback" style="display:none;">
        <svg viewBox="0 0 24 24">
          <rect x="3" y="4" width="18" height="18" rx="2"/>
          <path d="M16 2v4M8 2v4M3 10h18"/>
        </svg>
      </div>
    </div>
    <div class="brand-name">
      <strong>Enterprise</strong>
      <span>Booking System</span>
    </div>
  </a>
  <div class="nav-links">
    <span class="admin-nav-tag">🛡️ Admin Portal</span>
    <a href="../../index.jsp" class="nav-a">Home</a>
  </div>
</nav>

<div class="split-page">

  <!-- LEFT -->
  <div class="left-panel">
    <div class="admin-accent"></div>
    <div class="dc dc1"></div>
    <div class="dc dc2"></div>
    <div class="dc dc3"></div>
    <div class="shield-wrap">🛡️</div>
    <span class="l-tag">🔐 Restricted Access</span>
    <h2>Admin Control<br>Panel</h2>
    <p>Authorised administrators only. Full system management access for the Enterprise Booking System.</p>
    <ul class="feat-list">
      <li><div class="feat-ico">👥</div> Manage all user accounts</li>
      <li><div class="feat-ico">📊</div> View booking analytics</li>
      <li><div class="feat-ico">🏛️</div> Configure venues &amp; labs</li>
      <li><div class="feat-ico">⚙️</div> System settings &amp; controls</li>
      <li><div class="feat-ico">📋</div> Approve or cancel bookings</li>
    </ul>
  </div>

  <!-- RIGHT -->
  <div class="right-panel" style="display:flex;align-items:center;justify-content:center;padding:48px 32px;">
    <div class="admin-card">

      <div class="form-title">Admin Sign In</div>
      <p class="form-sub">
        Not an admin? <a href="../../index.jsp">Go to home →</a>
      </p>

      <div class="admin-warning">
        <span style="font-size:16px;flex-shrink:0;">⚠️</span>
        <p>This area is restricted to authorised administrators only. Unauthorised access attempts are logged.</p>
      </div>

      <div id="toast" class="toast"></div>

      <div class="field">
        <label for="adminId">Admin ID</label>
        <div class="iw">
          <span class="ii">🪪</span>
          <input type="text" id="adminId" placeholder="e.g. ADMIN001" autocomplete="username"/>
        </div>
        <div class="fmsg" id="adminId-err">Admin ID is required.</div>
      </div>

      <div class="field">
        <label for="email">Email Address</label>
        <div class="iw">
          <span class="ii">✉️</span>
          <input type="email" id="email" placeholder="admin@example.com" autocomplete="email"/>
        </div>
        <div class="fmsg" id="email-err">Please enter a valid email address.</div>
      </div>

      <div class="field">
        <label for="pw">Password</label>
        <div class="iw">
          <span class="ii">🔑</span>
          <input type="password" id="pw" placeholder="Enter admin password" autocomplete="current-password"/>
          <button class="toggle-pw" type="button" onclick="tpw('pw',this)">Show</button>
        </div>
        <div class="fmsg" id="pw-err">Password is required.</div>
      </div>

      <div class="forgot-row"><a href="#">Forgot admin password?</a></div>

      <button class="btn-admin" id="adminBtn" onclick="doAdminLogin()">
        <span>🛡️</span> Sign In as Admin
      </button>

      <div class="admin-divider"><span>secure connection</span></div>

      <div class="bottom-link">
        Regular user? <a href="../../index.jsp">Go to home</a>
      </div>

    </div>
  </div>

</div>

<footer>
  © 2026 Enterprise Booking System &nbsp;·&nbsp;
  <a href="../../index.jsp">Home</a>
  <a href="#">Privacy Policy</a>
  <a href="#">Support</a>
</footer>

<script>
  function tpw(id, btn) {
    const el = document.getElementById(id);
    el.type = el.type === 'password' ? 'text' : 'password';
    btn.textContent = el.type === 'password' ? 'Show' : 'Hide';
  }

  const isEmail = v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);

  function setErr(iid, mid, on) {
    document.getElementById(iid).classList.toggle('e', on);
    document.getElementById(mid).classList.toggle('show', on);
  }

  function showToast(msg, type) {
    const t = document.getElementById('toast');
    t.textContent = msg; t.className = 'toast ' + type;
  }

  document.getElementById('adminId').addEventListener('input', function(){ if(this.value.trim()) setErr('adminId','adminId-err',false); });
  document.getElementById('email').addEventListener('input',   function(){ if(isEmail(this.value)) setErr('email','email-err',false); });
  document.getElementById('pw').addEventListener('input',      function(){ if(this.value) setErr('pw','pw-err',false); });

  function doAdminLogin() {
    const adminId = document.getElementById('adminId').value.trim();
    const email   = document.getElementById('email').value.trim();
    const pw      = document.getElementById('pw').value;
    let ok = true;

    if (!adminId)        { setErr('adminId','adminId-err',true); ok=false; } else setErr('adminId','adminId-err',false);
    if (!isEmail(email)) { setErr('email','email-err',true);     ok=false; } else setErr('email','email-err',false);
    if (!pw)             { setErr('pw','pw-err',true);           ok=false; } else setErr('pw','pw-err',false);
    if (!ok) return;

    const btn = document.getElementById('adminBtn');
    btn.disabled = true; btn.innerHTML = '<span>⏳</span> Verifying…';

    /* ── Replace with fetch('/EnterpriseBookingSystem/AdminLoginServlet', ...) when backend is ready ── */
    setTimeout(() => {
      const admins = JSON.parse(localStorage.getItem('ebs_admins') || '[]');
      const match  = admins.find(a => a.adminId === adminId && a.email === email && a.password === pw);
      if (match) {
        showToast('✅ Admin login successful! Redirecting…', 'ok');
        setTimeout(() => window.location.href = '../../index.jsp', 1400);
      } else {
        showToast('❌ Invalid credentials. Access denied.', 'err');
        btn.disabled = false; btn.innerHTML = '<span>🛡️</span> Sign In as Admin';
      }
    }, 900);
    /* ── End demo block ── */
  }

  document.addEventListener('keydown', e => { if(e.key === 'Enter') doAdminLogin(); });
</script>
</body>
</html>
