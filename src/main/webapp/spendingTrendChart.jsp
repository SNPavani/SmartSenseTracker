<%@ page contentType="text/html; charset=UTF-8" %>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<style>
.chart-nav-btn {
    display:inline-flex; align-items:center; gap:5px;
    padding:5px 12px; border-radius:6px; font-size:0.72rem; font-weight:600;
    border:1px solid #EBEBEB; background:#F5F5F5; color:#4A4A4A;
    cursor:pointer; transition:all 0.18s; font-family:'Inter',sans-serif;
}
.chart-nav-btn:hover  { background:#FEF0F0; color:#8B0000; border-color:#FADADA; }
.chart-nav-btn.active { background:#8B0000; color:#fff; border-color:#8B0000; }
.back-btn { background:#F0F0F0 !important; color:#555 !important; border-color:#DDD !important; }
.back-btn:hover { background:#E0E0E0 !important; color:#222 !important; }

.year-pill {
    display:inline-flex; align-items:center; justify-content:center;
    padding:6px 16px; border-radius:8px; font-size:0.78rem; font-weight:700;
    border:2px solid #E2E5EA; background:#FAFAFA; color:#4A4A4A;
    cursor:pointer; transition:all 0.2s; font-family:'DM Sans',sans-serif; min-width:68px;
}
.year-pill:hover  { border-color:#8B0000; color:#8B0000; background:#FEF0F0; }
.year-pill.active { border-color:#8B0000; background:#8B0000; color:#fff; }

.month-pill {
    display:inline-flex; align-items:center; justify-content:center;
    padding:5px 11px; border-radius:6px; font-size:0.71rem; font-weight:600;
    border:1px solid #E2E5EA; background:#FAFAFA; color:#4A4A4A;
    cursor:pointer; transition:all 0.18s; font-family:'Inter',sans-serif;
}
.month-pill:hover  { border-color:#8B0000; color:#8B0000; background:#FEF0F0; }
.month-pill.active { border-color:#8B0000; background:#8B0000; color:#fff; }

.tl-dot { width:10px; height:10px; border-radius:3px; flex-shrink:0; }
.tl-row { display:flex; align-items:center; gap:6px; font-size:0.7rem; color:#4A4A4A; }
body.dark-mode .tl-row { color:#BBB; }
body.dark-mode .year-pill  { background:#222; border-color:#333; color:#BBB; }
body.dark-mode .month-pill { background:#222; border-color:#333; color:#BBB; }
body.dark-mode .chart-nav-btn { background:#222; border-color:#333; color:#BBB; }
</style>

<div class="bank-card" style="margin-bottom:18px;">

    <!-- Header -->
    <div class="bank-card-header" style="flex-wrap:wrap;gap:8px;">
        <div class="bank-card-title">
            <i class="bi bi-bar-chart-steps"></i>
            <span id="chartTitle">Spending Overview — All Years</span>
        </div>
        <div style="display:flex;align-items:center;gap:6px;">
            <button class="chart-nav-btn back-btn" id="backBtn" style="display:none;" onclick="chartGoBack()">
                <i class="bi bi-arrow-left"></i> Back
            </button>
            <button class="chart-nav-btn active" id="btnCat"   onclick="setChartMode('category')">By Category</button>
            <button class="chart-nav-btn"        id="btnTotal" onclick="setChartMode('total')">Total Only</button>
        </div>
    </div>

    <!-- Summary -->
    <div style="padding:10px 20px 0;display:flex;align-items:baseline;gap:10px;flex-wrap:wrap;">
        <span id="chartGrandTotal" style="font-family:'DM Sans',sans-serif;font-size:1.6rem;font-weight:800;color:#1A1A1A;">&#8377;0</span>
        <span id="chartSubLabel"   style="font-size:0.72rem;color:#8A8A9A;font-weight:500;"></span>
        <span id="chartTopTag"     style="font-size:0.72rem;font-weight:600;color:#8B0000;margin-left:auto;"></span>
    </div>

    <!-- Year pills -->
    <div style="padding:10px 20px 4px;">
        <div style="font-size:0.6rem;font-weight:700;color:#BBBBBB;letter-spacing:1px;text-transform:uppercase;margin-bottom:6px;">
            CLICK YEAR TO DRILL DOWN
        </div>
        <div id="yearPills" style="display:flex;flex-wrap:wrap;gap:7px;"></div>
    </div>

    <!-- Month pills (hidden until year clicked) -->
    <div id="monthPillsSection" style="padding:2px 20px 4px;display:none;">
        <div style="font-size:0.6rem;font-weight:700;color:#BBBBBB;letter-spacing:1px;text-transform:uppercase;margin-bottom:6px;">
            CLICK MONTH FOR CATEGORY DETAIL
        </div>
        <div id="monthPills" style="display:flex;flex-wrap:wrap;gap:5px;"></div>
    </div>

    <!-- Traffic light legend -->
    <div style="padding:4px 20px 2px;display:flex;gap:14px;flex-wrap:wrap;">
        <div class="tl-row"><div class="tl-dot" style="background:#27AE60;"></div> Low spend</div>
        <div class="tl-row"><div class="tl-dot" style="background:#F39C12;"></div> Medium spend</div>
        <div class="tl-row"><div class="tl-dot" style="background:#C0392B;"></div> High spend</div>
        <div class="tl-row" id="catLegendHint" style="margin-left:auto;font-style:italic;color:#BBBBBB;">
            Switch to "By Category" for stacked breakdown
        </div>
    </div>

    <!-- Chart canvas -->
    <div style="padding:8px 14px 6px;position:relative;height:240px;">
        <div id="chartEmpty" style="display:none;position:absolute;inset:0;align-items:center;
             justify-content:center;flex-direction:column;gap:8px;">
            <i class="bi bi-bar-chart-line" style="font-size:2rem;color:#DDD;"></i>
            <span style="font-size:0.78rem;color:#AAAAAA;">No spending data for this period</span>
        </div>
        <canvas id="mainSpendChart"></canvas>
    </div>

    <div style="padding:0 20px 14px;display:flex;justify-content:space-between;align-items:center;">
        <span id="chartHint" style="font-size:0.68rem;color:#BBBBBB;">Showing all-time yearly totals</span>
        <a href="ViewExpensesServlet" style="font-size:0.72rem;color:#8B0000;text-decoration:none;font-weight:600;">
            All transactions <i class="bi bi-arrow-right"></i>
        </a>
    </div>
</div>

<script>
(function(){
    let inst      = null;
    let allYears  = [];
    let yearData  = {};   // cache fetched year data
    let mode      = 'category';
    let curYear   = null;
    let curMonth  = null;

    const MN  = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const MNF = ['January','February','March','April','May','June','July','August','September','October','November','December'];

    const CC = {
        Housing:'#8B0000',Food:'#C0392B',Transportation:'#E74C3C',
        Shopping:'#E67E22',Entertainment:'#D35400',Health:'#27AE60',
        Investments:'#2980B9',Education:'#8E44AD',Family:'#F39C12',Others:'#95A5A6'
    };
    const cc = n => CC[n] || '#888888';

    function tl(v, max) {
        if (!max) return '#27AE60';
        const r = v / max;
        if (r < 0.4)  return '#27AE60';
        if (r < 0.75) return '#F39C12';
        return '#C0392B';
    }

    function fmt(n){ return '₹' + Number(n).toLocaleString('en-IN',{maximumFractionDigits:0}); }

    /* ── INIT ── */
    function init(){
        fetch('CategoryChartServlet?summary=all')
            .then(r=>r.json())
            .then(d=>{
                allYears = d.years || [];
                buildYearPills();
                showOverall(d);
            }).catch(showEmpty);
    }

    /* ── MODE ── */
    window.setChartMode = function(m){
        mode = m;
        document.getElementById('btnCat').classList.toggle('active',   m==='category');
        document.getElementById('btnTotal').classList.toggle('active',  m==='total');
        document.getElementById('catLegendHint').style.display = m==='category' ? 'none' : '';
        redraw();
    };

    /* ── BACK ── */
    window.chartGoBack = function(){
        if (curMonth !== null){
            curMonth = null;
            document.querySelectorAll('.month-pill').forEach(p=>p.classList.remove('active'));
            drawYear(curYear);
        } else {
            curYear  = null;
            curMonth = null;
            document.getElementById('monthPillsSection').style.display = 'none';
            document.getElementById('backBtn').style.display = 'none';
            document.querySelectorAll('.year-pill').forEach(p=>p.classList.remove('active'));
            fetch('CategoryChartServlet?summary=all')
                .then(r=>r.json()).then(showOverall).catch(showEmpty);
        }
    };

    function redraw(){
        if      (curMonth !== null) drawMonth(curYear, curMonth);
        else if (curYear  !== null) drawYear(curYear);
        else fetch('CategoryChartServlet?summary=all').then(r=>r.json()).then(showOverall).catch(showEmpty);
    }

    /* ── YEAR PILLS ── */
    function buildYearPills(){
        const wrap = document.getElementById('yearPills');
        wrap.innerHTML = '';
        if (!allYears.length){
            wrap.innerHTML = '<span style="font-size:0.75rem;color:#AAA;">No data yet</span>';
            return;
        }
        allYears.forEach(y=>{
            const b = document.createElement('button');
            b.className   = 'year-pill';
            b.textContent = y;
            b.onclick     = ()=>selectYear(y, b);
            wrap.appendChild(b);
        });
    }

    function selectYear(y, btn){
        curYear  = y;
        curMonth = null;
        document.querySelectorAll('.year-pill').forEach(p=>p.classList.remove('active'));
        btn.classList.add('active');
        document.getElementById('backBtn').style.display = 'inline-flex';
        buildMonthPills();
        if (yearData[y]){
            drawYear(y);
        } else {
            fetch('CategoryChartServlet?year='+y)
                .then(r=>r.json())
                .then(d=>{ yearData[y]=d; drawYear(y); })
                .catch(showEmpty);
        }
    }

    /* ── MONTH PILLS ── */
    function buildMonthPills(){
        const wrap = document.getElementById('monthPills');
        wrap.innerHTML = '';
        document.getElementById('monthPillsSection').style.display = 'block';
        MN.forEach((m,i)=>{
            const b = document.createElement('button');
            b.className   = 'month-pill';
            b.textContent = m;
            b.onclick     = ()=>selectMonth(i+1, b);
            wrap.appendChild(b);
        });
    }

    function selectMonth(m, btn){
        curMonth = m;
        document.querySelectorAll('.month-pill').forEach(p=>p.classList.remove('active'));
        btn.classList.add('active');
        drawMonth(curYear, m);
    }

    /* ══════════════════════════════
       DRAW 1 — ALL YEARS OVERVIEW
    ══════════════════════════════ */
    function showOverall(d){
        document.getElementById('chartTitle').textContent    = 'Spending Overview — All Years';
        document.getElementById('chartHint').textContent     = 'Click a year pill above to drill into monthly detail';
        document.getElementById('chartSubLabel').textContent = 'all time';

        const years  = d.years     || [];
        const totals = d.yearTotals|| [];
        if (!years.length){ showEmpty(); return; }

        const grand = totals.reduce((a,b)=>a+Number(b),0);
        const max   = Math.max(...totals.map(Number));
        document.getElementById('chartGrandTotal').textContent = fmt(grand);
        document.getElementById('chartTopTag').textContent =
            '📅 '+years.length+' year(s) · '+fmt(grand)+' total';

        hideEmpty();
        const colors = totals.map(v=>tl(Number(v),max));
        drawBars(years.map(String), [{
            label:'Total Spend', data:totals.map(Number),
            backgroundColor:colors, borderRadius:6
        }], false);
    }

    /* ══════════════════════════════
       DRAW 2 — YEAR → 12 MONTHS
    ══════════════════════════════ */
    function drawYear(y){
        document.getElementById('chartTitle').textContent    = 'Monthly Spending — '+y;
        document.getElementById('chartHint').textContent     = 'Click a month pill above for category breakdown';
        document.getElementById('chartSubLabel').textContent = 'full year '+y;

        const d = yearData[y];
        if (!d || !d.datasets){ showEmpty(); return; }

        const monthTotals = new Array(12).fill(0);
        d.datasets.forEach(ds=>{ ds.data.forEach((v,i)=>{ monthTotals[i]+=Number(v); }); });

        const grand = monthTotals.reduce((a,b)=>a+b,0);
        const max   = Math.max(...monthTotals);
        const topI  = monthTotals.indexOf(max);

        document.getElementById('chartGrandTotal').textContent = fmt(grand);
        document.getElementById('chartTopTag').textContent =
            max>0 ? '📈 Highest: '+MN[topI]+' '+fmt(max) : '';

        hideEmpty();

        if (mode==='total'){
            drawBars(MN, [{
                label:'Total', data:monthTotals,
                backgroundColor:monthTotals.map(v=>tl(v,max)), borderRadius:5
            }], false);
        } else {
            const ds = d.datasets
                .filter(s=>s.data.some(v=>Number(v)>0))
                .map(s=>({
                    label:s.label, data:s.data.map(Number),
                    backgroundColor:cc(s.label), borderRadius:3, borderSkipped:false
                }));
            if (!ds.length){ showEmpty(); return; }
            drawBars(MN, ds, true);
        }
    }

    /* ══════════════════════════════
       DRAW 3 — MONTH → CATEGORIES
    ══════════════════════════════ */
    function drawMonth(y, m){
        const d = yearData[y];
        document.getElementById('chartTitle').textContent    = MNF[m-1]+' '+y+' — By Category';
        document.getElementById('chartHint').textContent     = 'Category breakdown for '+MNF[m-1]+' '+y;
        document.getElementById('chartSubLabel').textContent = MNF[m-1]+' '+y;

        if (!d || !d.datasets){ showEmpty(); return; }

        const labels=[], values=[];
        d.datasets.forEach(ds=>{
            const v=Number(ds.data[m-1]);
            if(v>0){ labels.push(ds.label); values.push(v); }
        });
        if (!labels.length){ showEmpty(); return; }

        const max   = Math.max(...values);
        const grand = values.reduce((a,b)=>a+b,0);
        document.getElementById('chartGrandTotal').textContent = fmt(grand);
        document.getElementById('chartTopTag').textContent =
            '🏆 '+labels[values.indexOf(max)]+' is highest';

        hideEmpty();
        const bgColors = mode==='total'
            ? values.map(v=>tl(v,max))
            : labels.map(l=>cc(l));

        drawBars(labels, [{
            label:'Spending', data:values,
            backgroundColor:bgColors, borderRadius:6
        }], false);
    }

    /* ══════════════════════════════
       CORE BAR RENDERER
    ══════════════════════════════ */
    function drawBars(labels, datasets, stacked){
        const ctx = document.getElementById('mainSpendChart').getContext('2d');
        if (inst) inst.destroy();

        inst = new Chart(ctx, {
            type:'bar',
            data:{ labels, datasets },
            options:{
                responsive:true, maintainAspectRatio:false,
                interaction:{ mode:'index', intersect:false },
                plugins:{
                    legend:{
                        display: datasets.length>1,
                        position:'bottom',
                        labels:{ boxWidth:10, boxHeight:10, borderRadius:3, font:{size:10}, padding:10,
                            filter: item => item.text !== undefined
                        }
                    },
                    tooltip:{
                        backgroundColor:'#1A1A1A', titleColor:'#AAAAAA',
                        bodyColor:'#FFFFFF', padding:12, cornerRadius:10,
                        callbacks:{
                            label: c => c.parsed.y===0 ? null :
                                '  '+(datasets.length>1?c.dataset.label+':  ':'')+fmt(c.parsed.y),
                            footer: items => {
                                if (!stacked || items.length<2) return '';
                                const s = items.reduce((a,i)=>a+i.parsed.y,0);
                                return 'Total: '+fmt(s);
                            }
                        }
                    }
                },
                scales:{
                    x:{ stacked, grid:{display:false}, border:{display:false},
                        ticks:{color:'#AAAAAA',font:{size:10},maxRotation:0} },
                    y:{ stacked, grid:{color:'#F5F5F5'}, border:{display:false},
                        ticks:{color:'#AAAAAA',font:{size:10},maxTicksLimit:5,
                            callback:v=>'₹'+(v>=1000?(v/1000).toFixed(1)+'k':v)} }
                }
            }
        });
    }

    function showEmpty(){
        document.getElementById('chartEmpty').style.display = 'flex';
        document.getElementById('mainSpendChart').style.display = 'none';
        document.getElementById('chartGrandTotal').textContent  = '₹0';
        document.getElementById('chartTopTag').textContent      = '';
    }
    function hideEmpty(){
        document.getElementById('chartEmpty').style.display = 'none';
        document.getElementById('mainSpendChart').style.display = 'block';
    }

    document.addEventListener('DOMContentLoaded', init);
})();
</script>
