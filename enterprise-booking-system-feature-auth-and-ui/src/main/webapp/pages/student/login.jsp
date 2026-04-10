<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Student Login – Enterprise Booking System</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="../../CSS/styles.css"/>
  <style>
    body { display: flex; flex-direction: column; }
    .left-panel { background: #0F172A; }
    .left-panel::before {
      content: ''; position: absolute; inset: 0;
      background: radial-gradient(ellipse at 80% 10%, rgba(59,130,246,0.15) 0%, transparent 55%),
                  radial-gradient(ellipse at 10% 90%, rgba(0,0,0,0.3) 0%, transparent 55%);
    }
    .left-panel::after {
      content: ''; position: absolute; top: 15%; bottom: 15%; left: 0; width: 4px;
      background: linear-gradient(to bottom, transparent, #3B82F6, transparent);
      border-radius: 0 4px 4px 0;
    }
    .left-panel .l-tag { background: rgba(59,130,246,0.2); color: #93C5FD; border: 1px solid rgba(59,130,246,0.3); }
    .left-panel h2 { color: white; }
    .left-panel > p { color: rgba(255,255,255,0.65); }
    .left-panel .feat-list li { color: rgba(255,255,255,0.85); }
    .left-panel .feat-ico { background: rgba(59,130,246,0.2); }
    .left-panel .dc { border: 1px solid rgba(255,255,255,0.06); }
    .right-panel { background: white; }
    .login-card {
      background: var(--card); border-radius: 20px; padding: 44px 40px;
      width: 100%; max-width: 420px;
      box-shadow: 0 8px 40px rgba(15,23,42,0.08); border: 1px solid var(--border);
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
    .error-banner {
      background: #FEF2F2; border: 1px solid #FECACA; color: #DC2626;
      border-radius: 10px; padding: 12px 16px; margin-bottom: 16px;
      font-size: 14px; font-weight: 500;
    }
  </style>
</head>
<body>

<nav>
  <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
    <div class="logo-img-wrap">
      <img src="${pageContext.request.contextPath}/assets/logo.jpg" alt="Logo"
           onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'"/>
      <div class="logo-fallback" style="display:none;">
        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>
      </div>
    </div>
    <div class="brand-name"><strong>Enterprise</strong><span>Booking System</span></div>
  </a>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/index.jsp" class="nav-a">Home</a>
    <a href="register.jsp" class="nav-a">Register</a>
    <a href="login.jsp" class="nav-a active">Sign In</a>
  </div>
</nav>

<div class="split-page">
  <div class="left-panel">
    <div class="dc dc1"></div><div class="dc dc2"></div><div class="dc dc3"></div>
    <span class="l-tag">🎓 Student Portal</span>
    <h2>Student<br>Sign In</h2>
    <p>Access your dashboard, manage reservations and book ICT lab seats — all in one place.</p>
    <ul class="feat-list">
      <li><div class="feat-ico">📅</div> View all upcoming bookings</li>
      <li><div class="feat-ico">💻</div> Manage ICT lab seat reservations</li>
      <li><div class="feat-ico">🏛️</div> Reserve and edit venue bookings</li>
      <li><div class="feat-ico">🔒</div> Secure, verified account access</li>
    </ul>
  </div>

  <div class="right-panel">
    <div class="login-card">
      <div class="form-title">Welcome back 👋</div>
      <p class="form-sub">Don't have an account? <a href="register.jsp">Register here</a></p>

      <%-- Show error from failed login --%>
      <% if (request.getParameter("error") != null) { %>
        <div class="error-banner">❌ Invalid email or password. Please try again.</div>
      <% } %>

      <%-- POST directly to LoginServlet — sets session on server --%>
      <form method="POST" action="${pageContext.request.contextPath}/login" id="loginForm">

        <div class="field">
          <label for="email">Email Address</label>
          <div class="iw">
            <span class="ii">✉️</span>
            <input type="email" id="email" name="email" placeholder="you@example.com" autocomplete="email"/>
          </div>
          <div class="fmsg" id="email-err">Please enter a valid email address.</div>
        </div>

        <div class="field">
          <label for="pw">Password</label>
          <div class="iw">
            <span class="ii">🔑</span>
            <input type="password" id="pw" name="password" placeholder="Enter your password" autocomplete="current-password"/>
            <button class="toggle-pw" type="button" onclick="tpw('pw',this)">Show</button>
          </div>
          <div class="fmsg" id="pw-err">Password is required.</div>
        </div>

        <div class="forgot-row"><a href="#">Forgot password?</a></div>
        <button class="btn-main" type="submit" id="loginBtn">Sign In</button>
      </form>

      <div class="divider"><span>or</span></div>
      <div class="bottom-link">New here? <a href="register.jsp">Create a free account →</a></div>
    </div>
  </div>
</div>

<footer>
  © 2026 Enterprise Booking System &nbsp;·&nbsp;
  <a href="${pageContext.request.contextPath}/index.jsp">Home</a>
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
  document.getElementById('loginForm').addEventListener('submit', function(e) {
    const email = document.getElementById('email').value.trim();
    const pw    = document.getElementById('pw').value;
    let ok = true;
    if (!isEmail(email)) { setErr('email','email-err',true); ok=false; } else setErr('email','email-err',false);
    if (!pw)             { setErr('pw','pw-err',true); ok=false; }       else setErr('pw','pw-err',false);
    if (!ok) { e.preventDefault(); return; }
    document.getElementById('loginBtn').textContent = 'Signing in…';
    document.getElementById('loginBtn').disabled = true;
  });
</script>
</body>
</html>
