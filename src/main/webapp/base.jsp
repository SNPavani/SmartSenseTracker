<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // ── SECURITY: Prevent browser caching of protected pages ──
    // Without this, browser back button shows cached pages after logout
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String contentPage = (String) request.getAttribute("contentPage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- ── SECURITY: HTTP-level no-cache meta tags as second layer ── -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>SmartSense — Personal Finance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --maroon:      #8B0000;
            --maroon-dark: #6B0000;
            --maroon-glow: rgba(139,0,0,0.08);
            --black:       #1A1A1A;
            --dark:        #2D2D2D;
            --white:       #FFFFFF;
            --offwhite:    #F8F9FA;
            --light-gray:  #F0F2F5;
            --border:      #E2E5EA;
            --text-dark:   #1A1A1A;
            --text-mid:    #4A4A4A;
            --text-muted:  #8A8A9A;
            --green:       #1A7F4B;
            --green-bg:    #E8F5EE;
            --red:         #C0392B;
            --red-bg:      #FDECEA;
            --blue:        #1A5276;
            --blue-bg:     #EAF2FB;
            --amber:       #B7770D;
            --amber-bg:    #FEF9EE;
            --sidebar-w:   260px;
        }

        * { box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--light-gray);
            color: var(--text-dark);
            min-height: 100vh;
        }

        /* ── DARK MODE ── */
        body.dark-mode {
            --white:      #1A1A1A;
            --offwhite:   #222222;
            --light-gray: #111111;
            --border:     #2A2A2A;
            --text-dark:  #F0F0F0;
            --text-mid:   #BBBBBB;
            --text-muted: #777777;
            background: #111111;
            color: #F0F0F0;
        }
        body.dark-mode .topbar        { background: #1A1A1A; border-color: #2A2A2A; }
        body.dark-mode .bank-card     { background: #1A1A1A; border-color: #2A2A2A; }
        body.dark-mode .stat-card     { background: #1A1A1A; border-color: #2A2A2A; }
        body.dark-mode .bank-card-header { border-color: #2A2A2A; }
        body.dark-mode .progress-bar-wrap { background: #2A2A2A; }
        body.dark-mode .stat-label,
        body.dark-mode .stat-sub,
        body.dark-mode .txn-id,
        body.dark-mode .topbar-sub    { color: #777; }
        body.dark-mode .stat-value,
        body.dark-mode .txn-title,
        body.dark-mode .bank-card-title,
        body.dark-mode .topbar-title,
        body.dark-mode h1             { color: #F0F0F0; }
        body.dark-mode .suggestion-card { background: #222; border-color: #2A2A2A; }
        body.dark-mode .suggestion-title { color: #F0F0F0; }
        body.dark-mode .suggestion-text  { color: #777; }
        body.dark-mode .topbar-btn    { background: #222; border-color: #333; color: #888; }
        body.dark-mode .topbar-btn:hover { background: var(--maroon-glow); color: var(--maroon); }
        body.dark-mode .session-timer { background: #222; border-color: #333; color: #888; }
        body.dark-mode .settings-dropdown { background: #1A1A1A; border-color: #2A2A2A; }
        body.dark-mode .drop-item     { color: #BBB; }
        body.dark-mode .drop-item:hover { background: #222; color: #F0F0F0; }
        body.dark-mode #donutTotal    { color: #F0F0F0 !important; }
        body.dark-mode .donut-legend-label { color: #E0E0E0 !important; }
        body.dark-mode .donut-legend-amt   { color: #F0F0F0 !important; }
        body.dark-mode .greeting-text { color: #F0F0F0 !important; }
        body.dark-mode .sc-toggle { background: #222 !important; border-color: #333 !important; color: #888 !important; }
        body.dark-mode .sc-toggle.active { background: #8B0000 !important; color: #fff !important; }
        body.dark-mode .empty-state-title { color: #F0F0F0; }

        /* SIDEBAR */
        .sidebar {
            position: fixed; top: 0; left: 0;
            width: var(--sidebar-w); height: 100vh;
            background: var(--black);
            display: flex; flex-direction: column;
            z-index: 200;
        }
        .sidebar-brand {
            background: var(--maroon);
            padding: 18px 22px;
            display: flex; align-items: center; gap: 12px;
        }
        .brand-shield {
            width: 36px; height: 36px;
            background: rgba(255,255,255,0.15);
            border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; color: white; flex-shrink: 0;
        }
        .brand-name    { font-family: 'DM Sans', sans-serif; font-weight: 700; font-size: 1rem; color: white; line-height: 1.1; }
        .brand-tagline { font-size: 0.6rem; color: rgba(255,255,255,0.55); letter-spacing: 0.8px; text-transform: uppercase; margin-top: 1px; }
        .sidebar-user  { padding: 14px 18px; border-bottom: 1px solid rgba(255,255,255,0.07); display: flex; align-items: center; gap: 11px; }
        .user-avatar   { width: 36px; height: 36px; border-radius: 50%; background: var(--maroon); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.85rem; color: white; flex-shrink: 0; }
        .user-name     { font-size: 0.835rem; font-weight: 600; color: white; }
        .user-handle   { font-size: 0.68rem; color: rgba(255,255,255,0.4); }
        .user-status   { font-size: 0.65rem; color: #4ade80; font-weight: 500; margin-top: 1px; }
        .nav-section   { font-size: 0.58rem; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: rgba(255,255,255,0.25); padding: 14px 22px 5px; }
        .sidebar-nav   { padding: 4px 10px; flex: 1; }
        .nav-item      { display: flex; align-items: center; gap: 11px; padding: 10px 13px; border-radius: 8px; color: rgba(255,255,255,0.5); text-decoration: none; font-size: 0.845rem; font-weight: 500; transition: all 0.18s; margin-bottom: 2px; }
        .nav-item i    { font-size: 0.95rem; width: 16px; text-align: center; }
        .nav-item:hover  { background: rgba(255,255,255,0.07); color: white; }
        .nav-item.active { background: var(--maroon); color: white; }
        .nav-item.logout { color: #f87171; }
        .nav-item.logout:hover { background: rgba(239,68,68,0.1); color: #ef4444; }
        .sidebar-bottom { padding: 10px; border-top: 1px solid rgba(255,255,255,0.07); }

        /* TOPBAR */
        .main-wrap { margin-left: var(--sidebar-w); min-height: 100vh; display: flex; flex-direction: column; }
        .topbar    { background: var(--white); border-bottom: 1px solid var(--border); padding: 0 28px; display: flex; align-items: center; justify-content: space-between; height: 56px; position: sticky; top: 0; z-index: 100; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        .topbar-left  { display: flex; align-items: center; gap: 14px; }
        .topbar-accent { width: 3px; height: 24px; background: var(--maroon); border-radius: 2px; }
        .topbar-title { font-family: 'DM Sans', sans-serif; font-size: 0.95rem; font-weight: 700; color: var(--text-dark); }
        .topbar-sub   { font-size: 0.7rem; color: var(--text-muted); }
        .topbar-right { display: flex; align-items: center; gap: 8px; position: relative; }

        .secure-badge { display: flex; align-items: center; gap: 6px; background: var(--green-bg); border: 1px solid rgba(26,127,75,0.2); border-radius: 20px; padding: 4px 11px; font-size: 0.7rem; color: var(--green); font-weight: 600; }
        .secure-badge .dot { width: 5px; height: 5px; background: var(--green); border-radius: 50%; animation: pulse 2s infinite; }
        @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.4} }

        .session-timer { display: flex; align-items: center; gap: 5px; background: var(--light-gray); border: 1px solid var(--border); border-radius: 20px; padding: 4px 11px; font-size: 0.7rem; color: var(--text-muted); font-weight: 600; cursor: default; }
        .session-timer.warning { background: var(--amber-bg); border-color: rgba(183,119,13,0.2); color: var(--amber); }
        .session-timer.danger  { background: var(--red-bg); border-color: rgba(192,57,43,0.2); color: var(--red); animation: blink 1s infinite; }
        @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.5} }

        /* ── Dark Mode Toggle in Topbar ── */
        .dark-mode-btn {
            display: flex; align-items: center; justify-content: center;
            width: 34px; height: 34px;
            background: var(--light-gray); border: 1px solid var(--border);
            border-radius: 7px; color: var(--text-muted);
            cursor: pointer; transition: all 0.2s; font-size: 0.9rem;
            flex-shrink: 0;
        }
        .dark-mode-btn:hover { background: var(--maroon-glow); color: var(--maroon); border-color: rgba(139,0,0,0.2); }
        body.dark-mode .dark-mode-btn { background: #222; border-color: #333; color: #FFD700; }
        body.dark-mode .dark-mode-btn:hover { background: var(--maroon-glow); border-color: rgba(139,0,0,0.2); }

        .topbar-btn { width: 34px; height: 34px; display: flex; align-items: center; justify-content: center; background: var(--light-gray); border: 1px solid var(--border); border-radius: 7px; color: var(--text-muted); cursor: pointer; transition: all 0.2s; font-size: 0.9rem; text-decoration: none; }
        .topbar-btn:hover { background: var(--maroon-glow); color: var(--maroon); border-color: rgba(139,0,0,0.2); }

        .settings-dropdown { display: none; position: absolute; top: 48px; right: 0; background: var(--white); border: 1px solid var(--border); border-radius: 12px; padding: 8px; min-width: 200px; z-index: 999; box-shadow: 0 8px 24px rgba(0,0,0,0.1); }
        .settings-dropdown.open { display: block; }
        .drop-label { font-size: 0.6rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; font-weight: 600; padding: 5px 11px 3px; }
        .drop-item  { display: flex; align-items: center; gap: 9px; padding: 9px 11px; border-radius: 7px; color: var(--text-mid); text-decoration: none; font-size: 0.815rem; font-weight: 500; transition: all 0.15s; }
        .drop-item:hover { background: var(--light-gray); color: var(--text-dark); }
        .drop-item i { color: var(--maroon); font-size: 0.85rem; }
        .drop-item.danger { color: var(--red); }
        .drop-item.danger i { color: var(--red); }
        .drop-item.danger:hover { background: var(--red-bg); }
        .drop-divider { border-color: var(--border); margin: 5px 0; }

        /* PAGE */
        .page-body { padding: 26px 28px; flex: 1; }

        /* CARDS */
        .bank-card { background: var(--white); border: 1px solid var(--border); border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 18px; overflow: hidden; }
        .bank-card-header { padding: 15px 20px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
        .bank-card-title  { font-family: 'DM Sans', sans-serif; font-size: 0.9rem; font-weight: 700; color: var(--text-dark); display: flex; align-items: center; gap: 8px; }
        .bank-card-title i { color: var(--maroon); }
        .bank-card-body   { padding: 20px; }

        /* STAT CARDS */
        .stat-card { background: var(--white); border: 1px solid var(--border); border-radius: 12px; padding: 18px; position: relative; overflow: hidden; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
        .stat-card:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0,0,0,0.08); }
        .stat-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; }
        .stat-card.maroon::before { background: var(--maroon); }
        .stat-card.green::before  { background: var(--green); }
        .stat-card.blue::before   { background: var(--blue); }
        .stat-card.amber::before  { background: var(--amber); }
        .stat-card.red::before    { background: var(--red); }
        .stat-icon { width: 38px; height: 38px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: 1rem; margin-bottom: 12px; }
        .stat-icon.maroon { background: var(--maroon-glow); color: var(--maroon); }
        .stat-icon.green  { background: var(--green-bg);    color: var(--green); }
        .stat-icon.blue   { background: var(--blue-bg);     color: var(--blue); }
        .stat-icon.amber  { background: var(--amber-bg);    color: var(--amber); }
        .stat-icon.red    { background: var(--red-bg);      color: var(--red); }
        .stat-label { font-size: 0.68rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 5px; }
        .stat-value { font-family: 'DM Sans', sans-serif; font-size: 1.4rem; font-weight: 700; color: var(--text-dark); line-height: 1; }
        .stat-sub   { font-size: 0.7rem; color: var(--text-muted); margin-top: 5px; }
        .progress-bar-wrap { background: var(--light-gray); border-radius: 4px; height: 5px; overflow: hidden; margin-top: 8px; }
        .progress-bar-fill { height: 100%; border-radius: 4px; transition: width 0.6s ease; }

        /* TABLE */
        .txn-table { width: 100%; border-collapse: collapse; }
        .txn-table thead th { font-size: 0.66rem; font-weight: 700; letter-spacing: 0.8px; text-transform: uppercase; color: var(--text-muted); padding: 9px 14px; background: var(--offwhite); border-bottom: 1px solid var(--border); white-space: nowrap; }
        .txn-table tbody tr { border-bottom: 1px solid #F5F5F5; transition: background 0.12s; }
        .txn-table tbody tr:hover { background: var(--offwhite); }
        .txn-table tbody tr:last-child { border-bottom: none; }
        .txn-table tbody td { padding: 13px 14px; font-size: 0.845rem; color: var(--text-dark); vertical-align: middle; }
        .txn-table tfoot td { padding: 13px 14px; font-size: 0.855rem; font-weight: 700; color: var(--maroon); border-top: 2px solid var(--border); background: #FFF9F9; }
        .txn-icon  { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: 0.875rem; flex-shrink: 0; background: var(--maroon-glow); color: var(--maroon); }
        .txn-title { font-weight: 600; font-size: 0.845rem; color: var(--text-dark); }
        .txn-id    { font-size: 0.68rem; color: var(--text-muted); }
        .amount-debit  { font-weight: 700; color: var(--red); }
        .amount-credit { font-weight: 700; color: var(--green); }

        /* CATEGORY BADGES */
        .cat-badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 20px; font-size: 0.68rem; font-weight: 600; border: 1px solid; }
        .cat-badge.housing       { background: #EEF2FF; color: #4338CA; border-color: #C7D2FE; }
        .cat-badge.food          { background: #FFFBEB; color: #D97706; border-color: #FDE68A; }
        .cat-badge.transport     { background: #EFF6FF; color: #1D4ED8; border-color: #BFDBFE; }
        .cat-badge.shopping      { background: #FDF2F8; color: #BE185D; border-color: #FBCFE8; }
        .cat-badge.entertainment { background: #F5F3FF; color: #7C3AED; border-color: #DDD6FE; }
        .cat-badge.health        { background: #F0FDF4; color: #15803D; border-color: #BBF7D0; }
        .cat-badge.investments   { background: #FFFBEB; color: #B45309; border-color: #FDE68A; }
        .cat-badge.default       { background: #F8FAFC; color: #64748B; border-color: #E2E8F0; }

        /* BUTTONS */
        .btn-maroon { background: var(--maroon); color: white; border: none; border-radius: 8px; padding: 9px 18px; font-size: 0.855rem; font-weight: 600; font-family: 'Inter', sans-serif; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px; text-decoration: none; box-shadow: 0 2px 8px rgba(139,0,0,0.18); }
        .btn-maroon:hover { background: var(--maroon-dark); color: white; transform: translateY(-1px); box-shadow: 0 4px 14px rgba(139,0,0,0.28); }
        .btn-outline { background: transparent; color: var(--text-mid); border: 1px solid var(--border); border-radius: 8px; padding: 9px 18px; font-size: 0.855rem; font-weight: 600; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px; text-decoration: none; }
        .btn-outline:hover { background: var(--light-gray); color: var(--text-dark); }
        .btn-danger-soft { background: var(--red-bg); color: var(--red); border: 1px solid rgba(192,57,43,0.2); border-radius: 7px; padding: 5px 11px; font-size: 0.765rem; font-weight: 600; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 5px; text-decoration: none; }
        .btn-danger-soft:hover { background: #FBDBD9; color: var(--red); }
        .btn-edit-soft { background: var(--maroon-glow); color: var(--maroon); border: 1px solid rgba(139,0,0,0.12); border-radius: 7px; padding: 5px 11px; font-size: 0.765rem; font-weight: 600; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 5px; text-decoration: none; }
        .btn-edit-soft:hover { background: rgba(139,0,0,0.12); color: var(--maroon-dark); }

        /* FORMS */
        .form-label { font-size: 0.76rem; font-weight: 600; color: var(--text-mid); text-transform: uppercase; letter-spacing: 0.4px; margin-bottom: 6px; }
        .form-control, .form-select { background: var(--white); border: 1px solid var(--border); border-radius: 8px; color: var(--text-dark); padding: 10px 13px; font-size: 0.865rem; font-family: 'Inter', sans-serif; transition: all 0.2s; }
        .form-control:focus, .form-select:focus { border-color: var(--maroon); box-shadow: 0 0 0 3px rgba(139,0,0,0.07); outline: none; }

        /* ALERTS */
        .alert-bank { border-radius: 8px; padding: 11px 15px; font-size: 0.815rem; font-weight: 500; border: 1px solid; display: flex; align-items: center; gap: 9px; margin-bottom: 18px; }
        .alert-bank.success { background: var(--green-bg); border-color: rgba(26,127,75,0.2); color: var(--green); }
        .alert-bank.danger  { background: var(--red-bg);   border-color: rgba(192,57,43,0.2);  color: var(--red); }
        .alert-bank.warning { background: var(--amber-bg); border-color: rgba(183,119,13,0.2);  color: var(--amber); }

        /* SUGGESTION CARDS */
        .suggestion-card { background: var(--white); border: 1px solid var(--border); border-radius: 9px; padding: 13px 15px; display: flex; align-items: flex-start; gap: 11px; margin-bottom: 9px; transition: box-shadow 0.2s; }
        .suggestion-card:hover { box-shadow: 0 3px 10px rgba(0,0,0,0.06); }
        .suggestion-icon  { width: 32px; height: 32px; border-radius: 8px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 0.875rem; }
        .suggestion-title { font-size: 0.835rem; font-weight: 600; color: var(--text-dark); margin-bottom: 2px; }
        .suggestion-text  { font-size: 0.765rem; color: var(--text-muted); line-height: 1.5; }

        /* EMPTY STATE */
        .empty-state { text-align: center; padding: 36px 20px; }
        .empty-state-icon  { width: 52px; height: 52px; background: var(--maroon-glow); border: 1px solid rgba(139,0,0,0.12); border-radius: 13px; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; color: var(--maroon); margin: 0 auto 13px; }
        .empty-state-title { font-size: 0.925rem; font-weight: 700; color: var(--text-dark); margin-bottom: 5px; }
        .empty-state-sub   { font-size: 0.8rem; color: var(--text-muted); margin-bottom: 16px; }

        /* DONUT legend */
        .donut-legend-label { font-size: 0.8rem; font-weight: 500; color: var(--text-dark); }
        .donut-legend-pct   { font-size: 0.7rem; color: var(--text-muted); }
        .donut-legend-amt   { font-size: 0.8rem; font-weight: 700; color: var(--text-dark); }

        /* Greeting */
        .greeting-text { font-family: 'DM Sans', sans-serif; font-size: 1.3rem; font-weight: 700; color: var(--text-dark); margin-bottom: 2px; }

        /* SESSION TIMEOUT MODAL */
        .timeout-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); z-index: 9999; align-items: center; justify-content: center; }
        .timeout-overlay.show { display: flex; }
        .timeout-modal { background: white; border-radius: 14px; padding: 32px; max-width: 400px; width: 90%; text-align: center; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
        .timeout-icon  { width: 56px; height: 56px; background: var(--amber-bg); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; color: var(--amber); margin: 0 auto 16px; }
        .timeout-title { font-family: 'DM Sans',sans-serif; font-size: 1.1rem; font-weight: 700; color: var(--text-dark); margin-bottom: 8px; }
        .timeout-sub   { font-size: 0.845rem; color: var(--text-muted); margin-bottom: 8px; }
        .timeout-count { font-size: 2rem; font-weight: 700; color: var(--red); margin: 12px 0; font-family: 'DM Sans',sans-serif; }
        .timeout-btns  { display: flex; gap: 10px; justify-content: center; margin-top: 18px; }

        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: var(--light-gray); }
        ::-webkit-scrollbar-thumb { background: #CCC; border-radius: 3px; }
    </style>
</head>
<body>

<!-- Session Timeout Warning Modal -->
<div class="timeout-overlay" id="timeoutOverlay">
    <div class="timeout-modal">
        <div class="timeout-icon"><i class="bi bi-clock-history"></i></div>
        <div class="timeout-title">Session Expiring Soon</div>
        <div class="timeout-sub">You have been inactive. Your session will expire in:</div>
        <div class="timeout-count" id="countdownDisplay">60</div>
        <div class="timeout-sub" style="font-size:0.75rem;">seconds</div>
        <div class="timeout-btns">
            <button onclick="extendSession()" class="btn-maroon" style="flex:1;">
                <i class="bi bi-arrow-clockwise"></i> Stay Signed In
            </button>
            <a href="LogoutServlet" class="btn-outline" style="flex:1;justify-content:center;">
                <i class="bi bi-box-arrow-right"></i> Sign Out
            </a>
        </div>
    </div>
</div>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-shield"><i class="bi bi-graph-up-arrow"></i></div>
        <div>
            <div class="brand-name">SmartSense</div>
            <div class="brand-tagline">Personal Finance</div>
        </div>
    </div>
    <div class="sidebar-user">
        <div class="user-avatar">
            <%= session.getAttribute("userName") != null ?
                String.valueOf(session.getAttribute("userName")).substring(0,1).toUpperCase() : "U" %>
        </div>
        <div style="overflow:hidden;">
            <div class="user-name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "User" %></div>
            <% if (session.getAttribute("userHandle") != null) { %>
            <div class="user-handle">@<%= session.getAttribute("userHandle") %></div>
            <% } %>
            <div class="user-status">&#9679; Active</div>
        </div>
    </div>
    <div class="nav-section">Menu</div>
    <div class="sidebar-nav">
        <a href="DashboardServlet"    class="nav-item"><i class="bi bi-grid-1x2-fill"></i>    Dashboard</a>
        <a href="AddExpenseServlet"   class="nav-item"><i class="bi bi-plus-circle-fill"></i>  Add Transaction</a>
        <a href="ViewExpensesServlet" class="nav-item"><i class="bi bi-clock-history"></i>     Transaction History</a>
        <a href="SettingsServlet"     class="nav-item"><i class="bi bi-sliders"></i>           Account Settings</a>
    </div>
    <div class="sidebar-bottom">
        <a href="LogoutServlet" class="nav-item logout"><i class="bi bi-box-arrow-right"></i> Sign Out</a>
    </div>
</div>

<!-- Main -->
<div class="main-wrap">
    <div class="topbar">
        <div class="topbar-left">
            <div class="topbar-accent"></div>
            <div>
                <div class="topbar-title">SmartSense Personal Finance</div>
                <div class="topbar-sub">
                    Signed in as
                    <% if (session.getAttribute("userHandle") != null) { %>
                        @<%= session.getAttribute("userHandle") %>
                    <% } else { %>
                        <%= session.getAttribute("userName") %>
                    <% } %>
                </div>
            </div>
        </div>
        <div class="topbar-right">
            <div class="secure-badge"><div class="dot"></div> Secure</div>
            <div class="session-timer" id="sessionTimerBadge" title="Time remaining in session">
                <i class="bi bi-clock"></i> <span id="sessionTimerText">30:00</span>
            </div>
            <div class="dark-mode-btn" id="darkModeBtn" onclick="toggleDarkMode()" title="Toggle Dark Mode">
                <i class="bi bi-moon-fill" id="darkModeIcon"></i>
            </div>
            <a href="DashboardServlet" class="topbar-btn" title="Home"><i class="bi bi-house-fill"></i></a>
            <div class="topbar-btn" title="Settings" onclick="toggleSettings()">
                <i class="bi bi-gear-fill"></i>
            </div>
            <div class="settings-dropdown" id="settingsDropdown">
                <div class="drop-label">Quick Access</div>
                <a href="DashboardServlet"    class="drop-item"><i class="bi bi-grid-1x2-fill"></i>    Dashboard</a>
                <a href="ViewExpensesServlet" class="drop-item"><i class="bi bi-clock-history"></i>    Transactions</a>
                <a href="AddExpenseServlet"   class="drop-item"><i class="bi bi-plus-circle-fill"></i> Add Transaction</a>
                <a href="SettingsServlet"     class="drop-item"><i class="bi bi-sliders"></i>          Account Settings</a>
                <hr class="drop-divider">
                <a href="LogoutServlet" class="drop-item danger"><i class="bi bi-box-arrow-right"></i> Sign Out</a>
            </div>
        </div>
    </div>

    <div class="page-body">
        <% if (contentPage != null) { %>
            <jsp:include page="<%= contentPage %>" flush="true" />
        <% } else { %>
            <div class="alert-bank danger"><i class="bi bi-exclamation-triangle"></i> No content specified.</div>
        <% } %>
    </div>
</div>

<script>
    /* ── SECURITY: Disable browser back/forward cache (bfcache) ── */
    /* This ensures the page is always re-fetched from server, never from cache */
    window.addEventListener('pageshow', function(e) {
        if (e.persisted) {
            // Page was loaded from bfcache — force a full reload from server
            window.location.reload();
        }
    });

    /* ── SETTINGS DROPDOWN ── */
    function toggleSettings() {
        document.getElementById('settingsDropdown').classList.toggle('open');
    }
    document.addEventListener('click', function(e) {
        if (!e.target.closest('[onclick="toggleSettings()"]') && !e.target.closest('#settingsDropdown')) {
            document.getElementById('settingsDropdown').classList.remove('open');
        }
    });

    /* ── DARK MODE ── */
    function toggleDarkMode() {
        const isDark = document.body.classList.toggle('dark-mode');
        localStorage.setItem('darkMode', isDark ? '1' : '0');
        document.getElementById('darkModeIcon').className = isDark ? 'bi bi-sun-fill' : 'bi bi-moon-fill';
        const dt = document.getElementById('donutTotal');
        if (dt) dt.style.color = isDark ? '#F0F0F0' : '#1A1A1A';
    }
    (function() {
        if (localStorage.getItem('darkMode') === '1') {
            document.body.classList.add('dark-mode');
            const icon = document.getElementById('darkModeIcon');
            if (icon) icon.className = 'bi bi-sun-fill';
        }
    })();

    /* ── SESSION TIMEOUT ── */
    const SESSION_MINUTES = 30;
    const WARN_AT_SECONDS = 60;
    let totalSeconds  = SESSION_MINUTES * 60;
    let countdownSecs = WARN_AT_SECONDS;
    let warningShown  = false;
    let logoutTimer   = null;
    const timerText    = document.getElementById('sessionTimerText');
    const timerBadge   = document.getElementById('sessionTimerBadge');
    const overlay      = document.getElementById('timeoutOverlay');
    const countDisplay = document.getElementById('countdownDisplay');
    function formatTime(s) { const m = Math.floor(s/60), sec = s%60; return String(m).padStart(2,'0')+':'+String(sec).padStart(2,'0'); }
    const sessionInterval = setInterval(() => {
        totalSeconds--;
        timerText.textContent = formatTime(totalSeconds);
        if (totalSeconds <= 300 && totalSeconds > WARN_AT_SECONDS) { timerBadge.classList.add('warning'); timerBadge.classList.remove('danger'); }
        if (totalSeconds <= WARN_AT_SECONDS && !warningShown) { warningShown = true; timerBadge.classList.add('danger'); overlay.classList.add('show'); startCountdown(); }
        if (totalSeconds <= 0) { clearInterval(sessionInterval); window.location.href = 'LogoutServlet?reason=timeout'; }
    }, 1000);
    function startCountdown() {
        countdownSecs = WARN_AT_SECONDS;
        logoutTimer = setInterval(() => {
            countdownSecs--;
            countDisplay.textContent = countdownSecs;
            if (countdownSecs <= 0) { clearInterval(logoutTimer); window.location.href = 'LogoutServlet?reason=timeout'; }
        }, 1000);
    }
    function resetSession() { if (!warningShown) { totalSeconds = SESSION_MINUTES * 60; timerBadge.classList.remove('warning','danger'); } }
    ['click','keydown','mousemove','scroll','touchstart'].forEach(evt => { document.addEventListener(evt, resetSession, { passive: true }); });
    function extendSession() {
        warningShown = false; totalSeconds = SESSION_MINUTES * 60; countdownSecs = WARN_AT_SECONDS;
        clearInterval(logoutTimer); overlay.classList.remove('show'); timerBadge.classList.remove('warning','danger');
        fetch('DashboardServlet', { method: 'HEAD' }).catch(() => {});
    }
</script>
</body>
</html>
