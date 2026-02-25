<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    if (session.getAttribute("userId") != null) { response.sendRedirect("DashboardServlet"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account — SmartSense</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #F0F2F5; min-height: 100vh; overflow: hidden; }
        #networkCanvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none; }
        .page-wrap { position: relative; z-index: 1; display: flex; align-items: stretch; min-height: 100vh; }
        .auth-left { width: 380px; flex-shrink: 0; background: #1A1A1A; display: flex; flex-direction: column; justify-content: space-between; }
        .left-top { padding: 36px 36px 0; }
        .brand-row { display: flex; align-items: center; gap: 12px; margin-bottom: 36px; }
        .brand-icon { width: 42px; height: 42px; background: #8B0000; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; color: white; }
        .brand-text-name { font-family: 'DM Sans', sans-serif; font-size: 1.05rem; font-weight: 700; color: white; }
        .brand-text-sub { font-size: 0.6rem; color: rgba(255,255,255,0.35); letter-spacing: 0.8px; text-transform: uppercase; }
        .left-headline { font-family: 'DM Sans', sans-serif; font-size: 1.6rem; font-weight: 700; color: white; line-height: 1.3; margin-bottom: 10px; }
        .left-headline span { color: #8B0000; }
        .left-sub { font-size: 0.845rem; color: rgba(255,255,255,0.4); line-height: 1.6; margin-bottom: 28px; }
        .steps { display: flex; flex-direction: column; }
        .step-row { display: flex; align-items: flex-start; gap: 13px; padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .step-row:last-child { border-bottom: none; }
        .step-num { width: 24px; height: 24px; border-radius: 50%; background: #8B0000; display: flex; align-items: center; justify-content: center; font-size: 0.68rem; font-weight: 700; color: white; flex-shrink: 0; margin-top: 2px; }
        .step-title { font-size: 0.835rem; font-weight: 600; color: white; margin-bottom: 1px; }
        .step-sub { font-size: 0.765rem; color: rgba(255,255,255,0.38); }
        .left-bottom { padding: 24px 36px; border-top: 1px solid rgba(255,255,255,0.06); }
        .security-strip { display: flex; align-items: center; gap: 9px; }
        .security-strip i { color: #8B0000; }
        .security-strip span { font-size: 0.72rem; color: rgba(255,255,255,0.28); }
        .auth-right { flex: 1; display: flex; align-items: center; justify-content: center; background: rgba(255,255,255,0.88); backdrop-filter: blur(20px); padding: 40px; }
        .form-box { width: 100%; max-width: 410px; }
        .form-box-header { margin-bottom: 24px; }
        .form-box-header h2 { font-family: 'DM Sans', sans-serif; font-size: 1.5rem; font-weight: 700; color: #1A1A1A; margin-bottom: 3px; }
        .form-box-header p { font-size: 0.815rem; color: #8A8A9A; }
        .form-label { font-size: 0.72rem; font-weight: 600; color: #4A4A4A; text-transform: uppercase; letter-spacing: 0.4px; margin-bottom: 6px; display: block; }
        .input-wrap { position: relative; margin-bottom: 14px; }
        .input-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #BBBBBB; font-size: 0.88rem; pointer-events: none; }
        .input-prefix { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #8B0000; font-size: 0.88rem; font-weight: 700; pointer-events: none; }
        .form-control { background: #FAFAFA; border: 1px solid #E2E5EA; border-radius: 8px; color: #1A1A1A; padding: 11px 13px 11px 36px; font-size: 0.865rem; font-family: 'Inter', sans-serif; transition: all 0.2s; width: 100%; }
        .form-control.with-prefix { padding-left: 28px; }
        .form-control::placeholder { color: #C5C5C5; }
        .form-control:focus { border-color: #8B0000; box-shadow: 0 0 0 3px rgba(139,0,0,0.08); outline: none; background: white; }
        .field-hint { font-size: 0.68rem; color: #AAAAAA; margin-top: -8px; margin-bottom: 12px; }
        .btn-register { width: 100%; background: #8B0000; color: white; border: none; border-radius: 8px; padding: 12px; font-size: 0.88rem; font-weight: 700; font-family: 'Inter', sans-serif; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 3px 10px rgba(139,0,0,0.2); margin-top: 4px; }
        .btn-register:hover { background: #6B0000; transform: translateY(-1px); }
        .auth-footer-link { text-align: center; margin-top: 18px; font-size: 0.815rem; color: #8A8A9A; }
        .auth-footer-link a { color: #8B0000; font-weight: 600; text-decoration: none; }
        .alert-bank { border-radius: 8px; padding: 10px 13px; font-size: 0.79rem; font-weight: 500; border: 1px solid; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }
        .alert-bank.danger { background: #FDECEA; border-color: rgba(192,57,43,0.2); color: #C0392B; }
    </style>
</head>
<body>
<canvas id="networkCanvas"></canvas>
<div class="page-wrap">

    <div class="auth-left">
        <div class="left-top">
            <div class="brand-row">
                <div class="brand-icon"><i class="bi bi-graph-up-arrow"></i></div>
                <div><div class="brand-text-name">SmartSense</div><div class="brand-text-sub">Personal Finance</div></div>
            </div>
            <div class="left-headline">Join <span>SmartSense</span><br>Today</div>
            <div class="left-sub">Create your free account and start making smarter financial decisions from day one.</div>
            <div class="steps">
                <div class="step-row"><div class="step-num">1</div><div><div class="step-title">Create Your Account</div><div class="step-sub">Register with username &amp; email</div></div></div>
                <div class="step-row"><div class="step-num">2</div><div><div class="step-title">Set Income &amp; Limit</div><div class="step-sub">Configure your monthly budget</div></div></div>
                <div class="step-row"><div class="step-num">3</div><div><div class="step-title">Log Transactions</div><div class="step-sub">Track across 8 categories</div></div></div>
                <div class="step-row"><div class="step-num">4</div><div><div class="step-title">Get Smart Insights</div><div class="step-sub">Personalised saving suggestions</div></div></div>
            </div>
        </div>
        <div class="left-bottom">
            <div class="security-strip">
                <i class="bi bi-shield-lock-fill"></i>
                <span>256-bit encryption &nbsp;&#183;&nbsp; Always private</span>
            </div>
        </div>
    </div>

    <div class="auth-right">
        <div class="form-box">
            <div class="form-box-header">
                <h2>Create Account</h2>
                <p>Fill in your details to get started — it's free</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-bank danger"><i class="bi bi-exclamation-octagon-fill"></i> <%= request.getAttribute("error") %></div>
            <% } %>

            <form action="RegisterServlet" method="post">
                <label class="form-label">Full Name</label>
                <div class="input-wrap">
                    <i class="bi bi-person input-icon"></i>
                    <input type="text" name="name" class="form-control" placeholder="Deepak JN" required>
                </div>

                <label class="form-label">Username</label>
                <div class="input-wrap">
                    <span class="input-prefix">@</span>
                    <input type="text" name="username" class="form-control with-prefix"
                           placeholder="deepak_jn"
                           pattern="[a-zA-Z0-9_]{3,20}"
                           title="3-20 characters, letters, numbers and underscore only"
                           required>
                </div>
                <div class="field-hint">3-20 characters. Letters, numbers and underscore only. Used to sign in.</div>

                <label class="form-label">Email Address</label>
                <div class="input-wrap">
                    <i class="bi bi-envelope input-icon"></i>
                    <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
                </div>

                <label class="form-label">Password</label>
                <div class="input-wrap">
                    <i class="bi bi-lock input-icon"></i>
                    <input type="password" name="password" class="form-control" placeholder="Min. 6 characters" minlength="6" required>
                </div>

                <button type="submit" class="btn-register">
                    <i class="bi bi-person-check-fill"></i> Create My Account
                </button>
            </form>

            <div class="auth-footer-link">
                Already have an account? <a href="login.jsp">Sign in here</a>
            </div>
        </div>
    </div>
</div>

<script>
    const canvas = document.getElementById('networkCanvas');
    const ctx = canvas.getContext('2d');
    function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
    resize(); window.addEventListener('resize', resize);
    const DOTS = 55, MAX_DIST = 120, C = '139,0,0';
    const dots = Array.from({ length: DOTS }, () => ({
        x: Math.random() * canvas.width, y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.28, vy: (Math.random() - 0.5) * 0.28, r: Math.random() * 1.4 + 0.8
    }));
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        for (let i = 0; i < dots.length; i++) for (let j = i+1; j < dots.length; j++) {
            const dx = dots[i].x-dots[j].x, dy = dots[i].y-dots[j].y, d = Math.sqrt(dx*dx+dy*dy);
            if (d < MAX_DIST) { ctx.beginPath(); ctx.moveTo(dots[i].x, dots[i].y); ctx.lineTo(dots[j].x, dots[j].y); ctx.strokeStyle=`rgba(${C},${(1-d/MAX_DIST)*0.1})`; ctx.lineWidth=0.7; ctx.stroke(); }
        }
        dots.forEach(d => {
            ctx.beginPath(); ctx.arc(d.x, d.y, d.r, 0, Math.PI*2);
            ctx.fillStyle=`rgba(${C},0.18)`; ctx.fill();
            d.x+=d.vx; d.y+=d.vy;
            if(d.x<0||d.x>canvas.width) d.vx*=-1;
            if(d.y<0||d.y>canvas.height) d.vy*=-1;
        });
        requestAnimationFrame(animate);
    }
    animate();
</script>
</body>
</html>
