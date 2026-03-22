<%-- 
    Document   : register
    Created on : 16 Mar 2026, 13:44:36
    Author     : ICTS
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Student Register – Enterprise Booking System</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="../../css/styles.css"/>
  <style>
    body { display: flex; flex-direction: column; }

    /* LEFT — deep blue gradient, unique to register */
    .left-panel {
      background: linear-gradient(145deg, #0F4C81 0%, #1e6fb5 50%, #2563EB 100%);
    }

    .left-panel::before {
      content: ''; position: absolute; inset: 0;
      background:
        radial-gradient(ellipse at 80% 10%, rgba(255,255,255,0.1) 0%, transparent 55%),
        radial-gradient(ellipse at 10% 90%, rgba(0,0,0,0.15) 0%, transparent 55%);
    }

    .left-panel .l-tag { background: rgba(255,255,255,0.18); color: white; }
    .left-panel h2  { color: white; }
    .left-panel > p { color: rgba(255,255,255,0.75); }
    .left-panel .feat-list li { color: rgba(255,255,255,0.9); }
    .left-panel .feat-ico { background: rgba(255,255,255,0.15); }
    .left-panel .dc { border: 1px solid rgba(255,255,255,0.1); }

    .right-panel { background: var(--bg); }

    /* Progress */
    .progress { display: flex; align-items: center; margin-bottom: 28px; }
    .ps { display: flex; align-items: center; gap: 6px; }
    .pn {
      width: 28px; height: 28px; border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 12px; font-weight: 800;
      background: var(--border); color: var(--muted);
      transition: all 0.3s; flex-shrink: 0;
    }
    .ps.on   .pn { background: var(--blue);    color: white; box-shadow: 0 0 0 3px var(--blue-light); }
    .ps.done .pn { background: var(--success); color: white; }
    .pl { font-size: 12px; font-weight: 600; color: var(--muted); }
    .ps.on .pl, .ps.done .pl { color: var(--text); }
    .pline { flex:1; height:2px; background:var(--border); margin:0 8px; border-radius:2px; transition:background 0.3s; }
    .pline.done { background: var(--success); }

    /* Role chip — only Student shown, pre-selected */
    .role-display {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 10px 18px; border-radius: 10px;
      border: 1.5px solid var(--blue); background: var(--blue-light);
      color: var(--blue); font-size: 13px; font-weight: 700;
      margin-bottom: 18px;
    }

    /* Password strength */
    .pw-bars { display: flex; gap: 4px; margin-top: 6px; }
    .pb { flex:1; height:4px; background:var(--border); border-radius:2px; transition:background 0.3s; }
    .pb.w { background: var(--error); }
    .pb.m { background: #F59E0B; }
    .pb.s { background: var(--success); }
    .pw-lbl { font-size: 11px; color: var(--muted); margin-top: 4px; }

    /* Checkbox */
    .check-row { display: flex; align-items: flex-start; gap: 10px; margin-bottom: 8px; }
    .check-row input[type=checkbox] { accent-color: var(--blue); margin-top: 2px; width:16px; height:16px; flex-shrink:0; cursor:pointer; }
    .check-row span { font-size: 13px; color: var(--muted); line-height: 1.5; }
    .check-row a { color: var(--blue); font-weight: 700; text-decoration: none; }
    .check-row a:hover { text-decoration: underline; }

    /* OTP */
    .otp-email { font-size: 14px; color: var(--muted); margin-bottom: 22px; }
    .otp-email strong { color: var(--text); }
    .otp-row { display: flex; gap: 8px; margin-bottom: 16px; }
    .ob {
      flex:1; height:58px; border:1.5px solid var(--border); border-radius:12px;
      text-align:center; font-size:24px; font-weight:800;
      font-family:inherit; color:var(--text); background:var(--card); outline:none;
      transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
    }
    .ob:focus  { border-color: var(--blue);    box-shadow: 0 0 0 3px var(--blue-light); }
    .ob.filled { border-color: var(--blue);    background: var(--blue-light); }
    .ob.e      { border-color: var(--error);   background: #FEF2F2; }
    .ob.s      { border-color: var(--success); background: #F0FDF4; }

    .otp-meta { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
    .timer-txt { font-size: 13px; color: var(--muted); }
    .timer-txt b { color: var(--text); }
    .resend { background:none; border:none; font-size:13px; font-weight:700; color:var(--blue); cursor:pointer; display:none; font-family:inherit; }
    .resend.show { display: block; }
    .resend:hover { color: var(--blue-hover); }

    .bottom-link { text-align:center; margin-top:18px; font-size:14px; color:var(--muted); }
    .bottom-link a { color:var(--blue); font-weight:700; text-decoration:none; }
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
    <a href="login.jsp"       class="nav-a">Sign In</a>
    <a href="register.jsp"    class="nav-a active cta">Register</a>
  </div>
</nav>

<div class="split-page">

  <!-- LEFT -->
  <div class="left-panel">
    <div class="dc dc1"></div>
    <div class="dc dc2"></div>
    <div class="dc dc3"></div>
    <span class="l-tag">🎓 Student Registration</span>
    <h2>Create Your<br>Student Account</h2>
    <p>Register with your Student ID, verify your email and start booking immediately.</p>
    <ul class="feat-list">
      <li><div class="feat-ico">🪪</div> Register with Student ID</li>
      <li><div class="feat-ico">🔒</div> Email OTP verification</li>
      <li><div class="feat-ico">⚡</div> Instant access after signup</li>
      <li><div class="feat-ico">📅</div> Start booking immediately</li>
    </ul>
  </div>

  <!-- RIGHT -->
  <div class="right-panel">
    <div class="form-box">

      <div class="progress">
        <div class="ps on" id="ps1"><div class="pn">1</div><span class="pl">Your Details</span></div>
        <div class="pline" id="pl1"></div>
        <div class="ps" id="ps2"><div class="pn">2</div><span class="pl">Verify Email</span></div>
        <div class="pline" id="pl2"></div>
        <div class="ps" id="ps3"><div class="pn">✓</div><span class="pl">Done</span></div>
      </div>

      <!-- STEP 1 -->
      <div id="step1">
        <div class="form-title">Student Registration</div>
        <p class="form-sub">Already registered? <a href="login.jsp">Sign in here</a></p>

        <div id="toast1" class="toast"></div>

        <!-- Role is fixed as Student on this page -->
        <div class="role-display">🎓 Registering as Student</div>

        <div class="field">
          <label for="uid">Student ID</label>
          <div class="iw">
            <span class="ii">🪪</span>
            <input type="text" id="uid" placeholder="e.g. STU2024001"/>
          </div>
          <div class="fmsg" id="uid-err">Student ID is required.</div>
        </div>

        <div class="field">
          <label for="email">Email Address</label>
          <div class="iw">
            <span class="ii">✉️</span>
            <input type="email" id="email" placeholder="you@example.com"/>
          </div>
          <div class="fmsg" id="email-err">Please enter a valid email address.</div>
        </div>

        <div class="field">
          <label for="pw">Password</label>
          <div class="iw">
            <span class="ii">🔑</span>
            <input type="password" id="pw" placeholder="Minimum 8 characters" oninput="strengthCheck(this.value)"/>
            <button class="toggle-pw" type="button" onclick="tpw('pw',this)">Show</button>
          </div>
          <div class="fmsg" id="pw-err">Password must be at least 8 characters.</div>
          <div class="pw-bars">
            <div class="pb" id="b1"></div><div class="pb" id="b2"></div>
            <div class="pb" id="b3"></div><div class="pb" id="b4"></div>
          </div>
          <div class="pw-lbl" id="pwlbl">Enter a password</div>
        </div>

        <div class="field">
          <label for="cpw">Confirm Password</label>
          <div class="iw">
            <span class="ii">🔒</span>
            <input type="password" id="cpw" placeholder="Repeat your password" oninput="matchCheck()"/>
            <button class="toggle-pw" type="button" onclick="tpw('cpw',this)">Show</button>
          </div>
          <div class="fmsg" id="cpw-err">Passwords do not match.</div>
        </div>

        <div class="check-row">
          <input type="checkbox" id="terms"/>
          <span>I agree to the <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a></span>
        </div>
        <div class="fmsg" id="terms-err" style="margin-bottom:10px;">You must accept the terms to continue.</div>

        <button class="btn-main" id="regBtn" onclick="doRegister()">Create Account →</button>
        <div class="bottom-link">Already have an account? <a href="login.jsp">Sign in</a></div>
      </div>

      <!-- STEP 2: OTP -->
      <div id="step2" style="display:none;">
        <div class="form-title">Verify Your Email 📧</div>
        <div class="form-sub">Enter the 6-digit code sent to your email</div>
        <p class="otp-email">Code sent to <strong id="otp-email-show"></strong></p>

        <div id="toast2" class="toast"></div>

        <div class="otp-row">
          <input class="ob" type="text" maxlength="1" id="o0" oninput="om(0)" onkeydown="ob2(event,0)"/>
          <input class="ob" type="text" maxlength="1" id="o1" oninput="om(1)" onkeydown="ob2(event,1)"/>
          <input class="ob" type="text" maxlength="1" id="o2" oninput="om(2)" onkeydown="ob2(event,2)"/>
          <input class="ob" type="text" maxlength="1" id="o3" oninput="om(3)" onkeydown="ob2(event,3)"/>
          <input class="ob" type="text" maxlength="1" id="o4" oninput="om(4)" onkeydown="ob2(event,4)"/>
          <input class="ob" type="text" maxlength="1" id="o5" oninput="om(5)" onkeydown="ob2(event,5)"/>
        </div>

        <div class="otp-meta">
          <span class="timer-txt" id="timerWrap">Resend in <b id="timerVal">30</b>s</span>
          <button class="resend" id="resendBtn" onclick="resend()">Resend Code</button>
        </div>

        <button class="btn-main" id="verifyBtn" onclick="doVerify()">Verify &amp; Continue</button>
        <button class="btn-ghost" onclick="goBack()">← Back</button>
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
  const role = 'student';
  let otp = '', timerInt = null, timerSec = 30;

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

  function showToast(id, msg, type) {
    const t = document.getElementById(id);
    t.textContent = msg; t.className = 'toast ' + type;
  }

  function strengthCheck(pw) {
    let sc = 0;
    if (pw.length >= 8) sc++;
    if (/[A-Z]/.test(pw)) sc++;
    if (/\d/.test(pw)) sc++;
    if (/[^A-Za-z0-9]/.test(pw)) sc++;
    const cls = sc <= 1 ? 'w' : sc <= 2 ? 'm' : 's';
    ['b1','b2','b3','b4'].forEach((b,i) => {
      document.getElementById(b).className = 'pb' + (i < sc ? ' '+cls : '');
    });
    document.getElementById('pwlbl').textContent =
      pw.length ? (['','Weak','Fair','Good','Strong'][sc]||'Weak') : 'Enter a password';
  }

  function matchCheck() {
    const pw  = document.getElementById('pw').value;
    const cpw = document.getElementById('cpw').value;
    if (!cpw) return;
    setErr('cpw','cpw-err', pw !== cpw);
    if (pw === cpw) document.getElementById('cpw').classList.add('s');
  }

  function setStep(n) {
    for (let i = 1; i <= 3; i++) {
      const ps = document.getElementById('ps'+i);
      ps.classList.remove('on','done');
      if (i < n)        ps.classList.add('done');
      else if (i === n) ps.classList.add('on');
    }
    document.getElementById('pl1').classList.toggle('done', n > 1);
    document.getElementById('pl2').classList.toggle('done', n > 2);
  }

  function om(i) {
    const box = document.getElementById('o'+i);
    box.value = box.value.replace(/\D/,'');
    box.classList.toggle('filled', !!box.value);
    if (box.value && i < 5) document.getElementById('o'+(i+1)).focus();
  }

  function ob2(e, i) {
    if (e.key === 'Backspace' && !document.getElementById('o'+i).value && i > 0)
      document.getElementById('o'+(i-1)).focus();
  }

  function startTimer() {
    timerSec = 30; clearInterval(timerInt);
    const tw = document.getElementById('timerWrap');
    const rb = document.getElementById('resendBtn');
    if (tw) tw.style.display = 'block';
    if (rb) rb.classList.remove('show');
    document.getElementById('timerVal').textContent = timerSec;
    timerInt = setInterval(() => {
      timerSec--;
      const tv = document.getElementById('timerVal');
      if (tv) tv.textContent = timerSec;
      if (timerSec <= 0) {
        clearInterval(timerInt);
        if (tw) tw.style.display = 'none';
        if (rb) rb.classList.add('show');
      }
    }, 1000);
  }

  function resend() {
    otp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log('%c[DEMO OTP] ' + otp, 'color:#3B82F6;font-weight:bold;font-size:14px');
    [0,1,2,3,4,5].forEach(i => { const b = document.getElementById('o'+i); b.value=''; b.className='ob'; });
    showToast('toast2','📨 New code sent! (Demo: check browser console)','inf');
    startTimer();
  }

  function doRegister() {
    const uid   = document.getElementById('uid').value.trim();
    const email = document.getElementById('email').value.trim();
    const pw    = document.getElementById('pw').value;
    const cpw   = document.getElementById('cpw').value;
    const terms = document.getElementById('terms').checked;
    let ok = true;

    if (!uid)            { setErr('uid',  'uid-err',   true); ok=false; } else setErr('uid',  'uid-err',   false);
    if (!isEmail(email)) { setErr('email','email-err', true); ok=false; } else setErr('email','email-err', false);
    if (pw.length < 8)   { setErr('pw',  'pw-err',    true); ok=false; } else setErr('pw',  'pw-err',    false);
    if (pw !== cpw)      { setErr('cpw', 'cpw-err',   true); ok=false; } else setErr('cpw', 'cpw-err',   false);
    if (!terms) { document.getElementById('terms-err').classList.add('show');    ok=false; }
    else          document.getElementById('terms-err').classList.remove('show');
    if (!ok) return;

    const btn = document.getElementById('regBtn');
    btn.disabled = true; btn.textContent = 'Sending code…';

    /* ── Replace with fetch('/EnterpriseBookingSystem/RegisterServlet', ...) when backend is ready ── */
    otp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log('%c[DEMO OTP] ' + otp, 'color:#3B82F6;font-weight:bold;font-size:16px');

    setTimeout(() => {
      document.getElementById('step1').style.display = 'none';
      document.getElementById('step2').style.display = 'block';
      document.getElementById('otp-email-show').textContent = email;
      showToast('toast2','📨 Code sent! (Demo: check browser console)','inf');
      setStep(2); startTimer();
      document.getElementById('o0').focus();
      btn.disabled = false; btn.textContent = 'Create Account →';
    }, 700);
    /* ── End demo block ── */
  }

  function doVerify() {
    const entered = [0,1,2,3,4,5].map(i => document.getElementById('o'+i).value).join('');
    if (entered.length < 6) { showToast('toast2','⚠️ Please enter all 6 digits.','err'); return; }

    const btn = document.getElementById('verifyBtn');
    btn.disabled = true; btn.textContent = 'Verifying…';

    setTimeout(() => {
      if (entered === otp) {
        clearInterval(timerInt);
        const users = JSON.parse(localStorage.getItem('ebs_users') || '[]');
        users.push({
          email:    document.getElementById('email').value.trim(),
          password: document.getElementById('pw').value,
          id:       document.getElementById('uid').value.trim(),
          role:     'student'
        });
        localStorage.setItem('ebs_users', JSON.stringify(users));
        [0,1,2,3,4,5].forEach(i => document.getElementById('o'+i).classList.add('s'));
        showToast('toast2','✅ Email verified! Taking you to Sign In…','ok');
        setStep(3);
        setTimeout(() => window.location.href = 'login.jsp', 1500);
      } else {
        [0,1,2,3,4,5].forEach(i => document.getElementById('o'+i).classList.add('e'));
        showToast('toast2','❌ Incorrect code. Please try again.','err');
        btn.disabled = false; btn.textContent = 'Verify & Continue';
      }
    }, 600);
  }

  function goBack() {
    clearInterval(timerInt);
    document.getElementById('step2').style.display = 'none';
    document.getElementById('step1').style.display = 'block';
    setStep(1);
    document.getElementById('toast2').className = 'toast';
  }

  document.addEventListener('keydown', e => {
    if (e.key !== 'Enter') return;
    if (document.getElementById('step2').style.display === 'block') doVerify();
    else doRegister();
  });
</script>
</body>
</html>
