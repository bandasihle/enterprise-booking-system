<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Student Login – Enterprise Booking System</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
<<<<<<< HEAD
  <link rel="stylesheet" href="../../css/styles.css"/>
=======
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"/>
>>>>>>> origin/feature/auth-and-ui
  <style>
  body { display: flex; flex-direction: column; }

  /* LEFT — gradient matching registration */
  .left-panel {
    background: linear-gradient(145deg, #0F4C81 0%, #1e6fb5 50%, #2563EB 100%);
  }

  .left-panel::before {
    content: ''; position: absolute; inset: 0;
    background:
      radial-gradient(ellipse at 80% 10%, rgba(255,255,255,0.1) 0%, transparent 55%),
      radial-gradient(ellipse at 10% 90%, rgba(0,0,0,0.15) 0%, transparent 55%);
  }

  .left-panel::after {
    content: ''; position: absolute;
    top: 15%; bottom: 15%; left: 0; width: 4px;
    background: linear-gradient(to bottom, transparent, #3B82F6, transparent);
    border-radius: 0 4px 4px 0;
  }

  .left-panel .l-tag {
    background: rgba(255,255,255,0.18);
    color: white;
    border: 1px solid rgba(255,255,255,0.2);
  }

  .left-panel h2  { color: white; }
  .left-panel > p { color: rgba(255,255,255,0.75); }
  .left-panel .feat-list li { color: rgba(255,255,255,0.9); }
  .left-panel .feat-ico { background: rgba(255,255,255,0.15); }
  .left-panel .dc { border: 1px solid rgba(255,255,255,0.1); }
  </style>
</head>
<body>

<nav>
  <a href="../../index.jsp" class="nav-brand">
    <div class="logo-img-wrap">
      <img src="../../assets/logo.jpg" alt="Logo"
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
    <a href="../../test-index.jsp" class="nav-a">Home</a>
    <a href="register.jsp"    class="nav-a">Register</a>
    <a href="login.jsp"       class="nav-a active">Sign In</a>
  </div>
</nav>

<div class="split-page">

  <div class="left-panel">
    <div class="dc dc1"></div>
    <div class="dc dc2"></div>
    <div class="dc dc3"></div>
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
      <p class="form-sub">
        Don't have an account? <a href="register.jsp">Register here</a>
      </p>

      <% String errorMsg = (String) request.getAttribute("errorMessage"); %>
      <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
          <div id="toast" class="toast err show"><%= errorMsg %></div>
      <% } else { %>
          <div id="toast" class="toast"></div>
      <% } %>

      <form action="StudentLoginServlet" method="POST" id="loginForm">
          <div class="field">
            <label for="email">Email Address</label>
            <div class="iw">
              <span class="ii">✉️</span>
              <input type="email" id="email" name="email" placeholder="200000000@ump.ac.za" autocomplete="email" required/>
            </div>
            <div class="fmsg" id="email-err">Please enter a valid email address.</div>
          </div>

          <div class="field">
            <label for="pw">Password</label>
            <div class="iw">
              <span class="ii">🔑</span>
              <input type="password" id="pw" name="password" placeholder="Enter your password" autocomplete="current-password" required/>
              <button class="toggle-pw" type="button" onclick="tpw('pw',this)">Show</button>
            </div>
            <div class="fmsg" id="pw-err">Password is required.</div>
          </div>

          <div class="forgot-row"><a href="#">Forgot password?</a></div>

          <button type="submit" class="btn-main" id="loginBtn">Sign In</button>
      </form>

      <div class="divider"><span>or</span></div>

      <div class="bottom-link">
        New here? <a href="register.jsp">Create a free account →</a>
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
  // UI toggles kept intact
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

  // Client-side validation interceptor before Servlet POST
  document.getElementById('loginForm').addEventListener('submit', function(e) {
    const email = document.getElementById('email').value.trim();
    const pw    = document.getElementById('pw').value;
    let ok = true;
    
    if (!isEmail(email)) { setErr('email','email-err',true); ok=false; } else setErr('email','email-err',false);
    if (!pw)             { setErr('pw','pw-err',true);       ok=false; } else setErr('pw','pw-err',false);
    
    if (!ok) {
        e.preventDefault(); // Stop form submission if inputs are invalid
    } else {
        const btn = document.getElementById('loginBtn');
        btn.disabled = true; 
        btn.textContent = 'Signing in…';
    }
  });

  document.getElementById('email').addEventListener('input', function(){ if(isEmail(this.value)) setErr('email','email-err',false); });
  document.getElementById('pw').addEventListener('input',    function(){ if(this.value) setErr('pw','pw-err',false); });
</script>
</body>
</html>