<%-- 
    Document   : login
    Created on : 16 Mar 2026, 13:44:48
    Author     : ICTS
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Lecturer Login – Enterprise Booking System</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/styles.css"/>
  <style>
    body { display: flex; flex-direction: column; }

    /* LEFT — teal/green unique to lecturer */
    .left-panel {
      background: linear-gradient(145deg, #064E3B 0%, #065F46 50%, #047857 100%);
    }

    .left-panel::before {
      content: ''; position: absolute; inset: 0;
      background:
        radial-gradient(ellipse at 80% 10%, rgba(255,255,255,0.08) 0%, transparent 55%),
        radial-gradient(ellipse at 10% 90%, rgba(0,0,0,0.2) 0%, transparent 55%);
    }

    .left-panel .l-tag { background: rgba(255,255,255,0.15); color: white; }
    .left-panel h2  { color: white; }
    .left-panel > p { color: rgba(255,255,255,0.7); }
    .left-panel .feat-list li { color: rgba(255,255,255,0.88); }
    .left-panel .feat-ico { background: rgba(255,255,255,0.15); }
    .left-panel .dc { border: 1px solid rgba(255,255,255,0.08); }

    .right-panel { background: white; }

    .login-card {
      background: var(--card); border-radius: 20px; padding: 44px 40px;
      width: 100%; max-width: 420px;
      box-shadow: 0 8px 40px rgba(6,78,59,0.1);
      border: 1px solid var(--border);
    }

    .forgot-row { display: flex; justify-content: flex-end; margin-bottom: 16px; margin-top: -6px; }
    .forgot-row a { font-size: 13px; color: var(--blue); text-decoration: none; font-weight: 600; }
    .forgot-row a:hover { text-decoration: underline; }

    .divider { display: flex; align-items: center; gap: 12px; margin: 20px 0; }
    .divider::before, .divider::after { content:''; flex:1; height:1px; background:var(--border); }
    .divider span { font-size: 13px; color: var(--muted); }

    .bottom-link { text-align: center; margin-top: 18px; font-size: 14px; color: var(--muted); }
    .bottom-link a { color: var(--blue); font-weight: 700; text-decoration: none; }
    .bottom-link a:hover { text-decoration: underline; }
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
    <a href="../../index.jsp" class="nav-a">Home</a>
    <a href="register.jsp"    class="nav-a">Register</a>
    <a href="login.jsp"       class="nav-a active">Sign In</a>
  </div>
</nav>

<div class="split-page">

  <!-- LEFT -->
  <div class="left-panel">
    <div class="dc dc1"></div>
    <div class="dc dc2"></div>
    <div class="dc dc3"></div>
    <span class="l-tag">👨‍🏫 Lecturer Portal</span>
    <h2>Lecturer<br>Sign In</h2>
    <p>Access your lecturer dashboard, manage venue bookings and ICT lab reservations for your classes.</p>
    <ul class="feat-list">
      <li><div class="feat-ico">📅</div> Book venues for lectures</li>
      <li><div class="feat-ico">💻</div> Reserve ICT labs for classes</li>
      <li><div class="feat-ico">👥</div> Manage class bookings</li>
      <li><div class="feat-ico">🔒</div> Secure staff access</li>
    </ul>
  </div>

  <!-- RIGHT -->
  <div class="right-panel">
    <div class="login-card">
      <div class="form-title">Lecturer Sign In 👨‍🏫</div>
      <p class="form-sub">
        Don't have an account? <a href="register.jsp">Register here</a>
      </p>

      <div id="toast" class="toast"></div>

      <div class="field">
        <label for="email">Email Address</label>
        <div class="iw">
          <span class="ii">✉️</span>
          <input type="email" id="email" placeholder="staff@example.com" autocomplete="email"/>
        </div>
        <div class="fmsg" id="email-err">Please enter a valid email address.</div>
      </div>

      <div class="field">
        <label for="pw">Password</label>
        <div class="iw">
          <span class="ii">🔑</span>
          <input type="password" id="pw" placeholder="Enter your password" autocomplete="current-password"/>
          <button class="toggle-pw" type="button" onclick="tpw('pw',this)">Show</button>
        </div>
        <div class="fmsg" id="pw-err">Password is required.</div>
      </div>

      <div class="forgot-row"><a href="#">Forgot password?</a></div>

      <button class="btn-main" id="loginBtn" onclick="doLogin()">Sign In</button>

      <div class="divider"><span>or</span></div>

      <div class="bottom-link">
        New staff member? <a href="register.jsp">Create an account →</a>
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

  document.getElementById('email').addEventListener('input', function(){ if(isEmail(this.value)) setErr('email','email-err',false); });
  document.getElementById('pw').addEventListener('input',    function(){ if(this.value) setErr('pw','pw-err',false); });

  function doLogin() {
    const email = document.getElementById('email').value.trim();
    const pw    = document.getElementById('pw').value;
    let ok = true;
    if (!isEmail(email)) { setErr('email','email-err',true); ok=false; } else setErr('email','email-err',false);
    if (!pw)             { setErr('pw','pw-err',true);       ok=false; } else setErr('pw','pw-err',false);
    if (!ok) return;

    const btn = document.getElementById('loginBtn');
    btn.disabled = true; btn.textContent = 'Signing in…';

    /* ── Replace with fetch('/EnterpriseBookingSystem/LoginServlet', ...) when backend is ready ── */
    setTimeout(() => {
      const users = JSON.parse(localStorage.getItem('ebs_users') || '[]');
      const match = users.find(u => u.email === email && u.password === pw && u.role === 'lecturer');
      if (match) {
        showToast('✅ Login successful! Redirecting…', 'ok');
        setTimeout(() => window.location.href = '../../index.jsp', 1200);
      } else {
        showToast('❌ Incorrect email or password.', 'err');
        btn.disabled = false; btn.textContent = 'Sign In';
      }
    }, 700);
    /* ── End demo block ── */
  }

  document.addEventListener('keydown', e => { if(e.key === 'Enter') doLogin(); });
</script>
</body>
</html>
