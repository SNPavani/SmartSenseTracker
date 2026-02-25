<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    // Prevent cached login page
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") != null) { response.sendRedirect("DashboardServlet"); return; }
    String reason = request.getParameter("reason");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In — SmartSense</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #F0F2F5; min-height: 100vh; overflow: hidden; }
        #networkCanvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none; }
        .page-wrap { position: relative; z-index: 1; display: flex; align-items: stretch; min-height: 100vh; }

        /* Left */
        .auth-left { width: 420px; flex-shrink: 0; background: #1A1A1A; display: flex; flex-direction: column; justify-content: space-between; }
        .left-top { padding: 40px 40px 0; }
        .brand-row { display: flex; align-items: center; gap: 12px; margin-bottom: 44px; }
        .brand-icon { width: 42px; height: 42px; background: #8B0000; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; color: white; }
        .brand-text-name { font-family: 'DM Sans', sans-serif; font-size: 1.05rem; font-weight: 700; color: white; line-height: 1.2; }
        .brand-text-sub { font-size: 0.6rem; color: rgba(255,255,255,0.35); letter-spacing: 0.8px; text-transform: uppercase; }
        .left-headline { font-family: 'DM Sans', sans-serif; font-size: 1.85rem; font-weight: 700; color: white; line-height: 1.25; margin-bottom: 12px; }
        .left-headline span { color: #8B0000; }
        .left-sub { font-size: 0.865rem; color: rgba(255,255,255,0.45); line-height: 1.65; margin-bottom: 36px; }
        .feature-list { display: flex; flex-direction: column; gap: 13px; }
        .feature-row { display: flex; align-items: center; gap: 11px; }
        .feature-dot { width: 7px; height: 7px; border-radius: 50%; background: #8B0000; flex-shrink: 0; }
        .feature-text { font-size: 0.815rem; color: rgba(255,255,255,0.55); }
        .left-bottom { padding: 28px 40px; border-top: 1px solid rgba(255,255,255,0.06); }
        .security-strip { display: flex; align-items: center; gap: 9px; }
        .security-strip i { color: #8B0000; font-size: 0.85rem; }
        .security-strip span { font-size: 0.72rem; color: rgba(255,255,255,0.3); }

        /* Right */
        .auth-right { flex: 1; display: flex; align-items: center; justify-content: center; background: rgba(255,255,255,0.88); backdrop-filter: blur(20px); padding: 48px; }
        .form-box { width: 100%; max-width: 400px; }
        .form-box-header { margin-bottom: 28px; }
        .form-box-header h2 { font-family: 'DM Sans', sans-serif; font-size: 1.55rem; font-weight: 700; color: #1A1A1A; margin-bottom: 4px; }
        .form-box-header p { font-size: 0.815rem; color: #8A8A9A; }

        .secure-strip { background: #8B0000; border-radius: 8px; padding: 9px 14px; margin-bottom: 26px; display: flex; align-items: center; gap: 9px; }
        .secure-strip i { color: white; font-size: 0.8rem; }
        .secure-strip span { font-size: 0.76rem; color: rgba(255,255,255,0.85); font-weight: 500; }

        .form-label { font-size: 0.72rem; font-weight: 600; color: #4A4A4A; text-transform: uppercase; letter-spacing: 0.4px; margin-bottom: 7px; display: block; }
        .input-wrap { position: relative; margin-bottom: 16px; }
        .input-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #BBBBBB; font-size: 0.88rem; pointer-events: none; }
        .form-control { background: #FAFAFA; border: 1px solid #E2E5EA; border-radius: 8px; color: #1A1A1A; padding: 11px 13px 11px 36px; font-size: 0.865rem; font-family: 'Inter', sans-serif; transition: all 0.2s; width: 100%; }
        .form-control::placeholder { color: #C5C5C5; }
        .form-control:focus { border-color: #8B0000; box-shadow: 0 0 0 3px rgba(139,0,0,0.08); outline: none; background: white; }

        .login-hint { font-size: 0.7rem; color: #AAAAAA; margin-top: -10px; margin-bottom: 14px; padding-left: 2px; }

        .btn-signin { width: 100%; background: #8B0000; color: white; border: none; border-radius: 8px; padding: 12px; font-size: 0.88rem; font-weight: 700; font-family: 'Inter', sans-serif; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 3px 10px rgba(139,0,0,0.2); margin-top: 4px; }
        .btn-signin:hover { background: #6B0000; transform: translateY(-1px); box-shadow: 0 5px 16px rgba(139,0,0,0.3); }

        .auth-footer-link { text-align: center; margin-top: 20px; font-size: 0.815rem; color: #8A8A9A; }
        .auth-footer-link a { color: #8B0000; font-weight: 600; text-decoration: none; }

        .alert-bank { border-radius: 8px; padding: 10px 13px; font-size: 0.79rem; font-weight: 500; border: 1px solid; display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }
        .alert-bank.danger  { background: #FDECEA; border-color: rgba(192,57,43,0.2); color: #C0392B; }
        .alert-bank.success { background: #E8F5EE; border-color: rgba(26,127,75,0.2);  color: #1A7F4B; }
        .alert-bank.warning { background: #FEF9EE; border-color: rgba(183,119,13,0.2); color: #B7770D; }
    </style>
</head>
<body>
<canvas id="networkCanvas"></canvas>
<div class="page-wrap">

    <!-- Left -->
    <div class="auth-left">
        <div class="left-top">
            <div class="brand-row">
                <div class="brand-icon"><i class="bi bi-graph-up-arrow"></i></div>
                <div>
                    <div class="brand-text-name">SmartSense</div>
                    <div class="brand-text-sub">Personal Finance</div>
                </div>
            </div>
            <div class="left-headline">Track. Control.<br>Save <span>Smarter.</span></div>
            <div class="left-sub">Your personal finance platform to manage every rupee with intelligence and clarity.</div>
            <div class="feature-list">
                <div class="feature-row"><div class="feature-dot"></div><div class="feature-text">Real-time expense tracking across 8 categories</div></div>
                <div class="feature-row"><div class="feature-dot"></div><div class="feature-text">Monthly income vs expense dashboard</div></div>
                <div class="feature-row"><div class="feature-dot"></div><div class="feature-text">Smart budget limits with instant alerts</div></div>
                <div class="feature-row"><div class="feature-dot"></div><div class="feature-text">Next month saving suggestions</div></div>
                <div class="feature-row"><div class="feature-dot"></div><div class="feature-text">Auto session timeout for account security</div></div>
            </div>
        </div>
        <div class="left-bottom">
            <div class="security-strip">
                <i class="bi bi-shield-lock-fill"></i>
                <span>256-bit encryption &nbsp;&#183;&nbsp; Your data is always private</span>
            </div>
        </div>
    </div>

    <!-- Right -->
    <div class="auth-right">
        <div class="form-box">

            <div class="secure-strip">
                <i class="bi bi-lock-fill"></i>
                <span>Secure Sign In &nbsp;&#183;&nbsp; Verified &amp; Encrypted Connection</span>
            </div>

            <div class="form-box-header">
                <h2>Welcome Back</h2>
                <p>Sign in with your username or email address</p>
            </div>

            <% if ("timeout".equals(reason)) { %>
                <div class="alert-bank warning"><i class="bi bi-clock-history"></i> Your session expired due to inactivity. Please sign in again.</div>
            <% } else if (request.getParameter("error") != null) { %>
                <div class="alert-bank danger"><i class="bi bi-exclamation-octagon-fill"></i> Invalid credentials. Please try again.</div>
            <% } %>
            <% if (request.getParameter("registered") != null) { %>
                <div class="alert-bank success"><i class="bi bi-check-circle-fill"></i> Account created successfully. Please sign in.</div>
            <% } %>

            <form action="LoginServlet" method="post">
                <label class="form-label">Username or Email</label>
                <div class="input-wrap">
                    <i class="bi bi-person input-icon"></i>
                    <input type="text" name="identifier" class="form-control"
                           placeholder="@username or email@example.com" required autocomplete="username">
                </div>
                <div class="login-hint">You can sign in with either your username or email address</div>

                <label class="form-label">Password</label>
                <div class="input-wrap">
                    <i class="bi bi-lock input-icon"></i>
                    <input type="password" name="password" class="form-control"
                           placeholder="••••••••" required autocomplete="current-password">
                </div>

                <button type="submit" class="btn-signin">
                    <i class="bi bi-box-arrow-in-right"></i> Sign In Securely
                </button>
            </form>

            <div class="auth-footer-link">
                New to SmartSense? <a href="register.jsp">Create an account</a>
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