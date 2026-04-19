const fs = require('fs');
const dir = 'c:\\Users\\liati\\Downloads\\ai-workshop-data-teams-Apr26\\analyses\\complainers-profile_2026-04-19_nimrod-fisher\\results';

function barChart({title, subtitle, labels, datasets, yLabel, yMax, note, refLine, refLabel, width, height}) {
  width = width || 600; height = height || 380;
  const ml=70, mr=30, mt=72, mb=80;
  const cw=width-ml-mr, ch=height-mt-mb;
  const nGroups=labels.length, nSets=datasets.length;
  const groupW=cw/nGroups, barW=groupW*0.65/nSets, pad=groupW*0.175;
  const colors=['#3b82f6','#7c3aed','#0891b2','#f59e0b','#10b981'];
  let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" font-family="Arial,sans-serif">`;
  svg += `<rect width="${width}" height="${height}" fill="#f8fafc"/>`;
  svg += `<rect x="${ml}" y="${mt}" width="${cw}" height="${ch}" fill="white" stroke="#e2e8f0"/>`;
  svg += `<text x="${width/2}" y="22" text-anchor="middle" font-size="14" font-weight="bold" fill="#1e293b">${title}</text>`;
  if (subtitle) svg += `<text x="${width/2}" y="42" text-anchor="middle" font-size="10" fill="#64748b">${subtitle}</text>`;
  // gridlines + y labels
  for (let i=0; i<=5; i++) {
    const yv = yMax*i/5;
    const yp = mt + ch - ch*(yv/yMax);
    svg += `<line x1="${ml}" x2="${ml+cw}" y1="${yp}" y2="${yp}" stroke="#e2e8f0" stroke-dasharray="3"/>`;
    svg += `<text x="${ml-6}" y="${yp+4}" text-anchor="end" font-size="10" fill="#64748b">${yv % 1 ? yv.toFixed(1) : yv}</text>`;
  }
  if (refLine != null) {
    const yp = mt + ch - ch*(refLine/yMax);
    svg += `<line x1="${ml}" x2="${ml+cw}" y1="${yp}" y2="${yp}" stroke="#ef4444" stroke-dasharray="5,3" stroke-width="1.5"/>`;
    if (refLabel) svg += `<text x="${ml+cw-4}" y="${yp-4}" text-anchor="end" font-size="9" fill="#ef4444">${refLabel}</text>`;
  }
  // bars
  datasets.forEach((ds, si) => {
    ds.data.forEach((v, gi) => {
      const x = ml + pad + gi*groupW + si*(barW+3);
      const bh = ch*(v/yMax), by = mt+ch-bh;
      svg += `<rect x="${x.toFixed(1)}" y="${by.toFixed(1)}" width="${barW.toFixed(1)}" height="${bh.toFixed(1)}" fill="${ds.color||colors[si]}" rx="2"/>`;
      svg += `<text x="${(x+barW/2).toFixed(1)}" y="${(by-4).toFixed(1)}" text-anchor="middle" font-size="10" font-weight="bold" fill="#1e293b">${v}</text>`;
    });
  });
  // x-axis labels
  labels.forEach((l, i) => {
    const cx = ml + pad + i*groupW + (nSets*(barW+3)-3)/2;
    const lines = l.split('\n');
    lines.forEach((line, li) => {
      svg += `<text x="${cx.toFixed(1)}" y="${mt+ch+15+li*13}" text-anchor="middle" font-size="10" fill="#374151">${line}</text>`;
    });
  });
  // y-axis label
  svg += `<text transform="rotate(-90)" x="${-(mt+ch/2)}" y="15" text-anchor="middle" font-size="11" fill="#374151">${yLabel}</text>`;
  // legend
  if (datasets.length > 1) {
    const legendX = ml, legendY = height - 14;
    datasets.forEach((ds, i) => {
      const lx = legendX + i*140;
      svg += `<rect x="${lx}" y="${legendY-10}" width="12" height="12" fill="${ds.color||colors[i]}" rx="2"/>`;
      svg += `<text x="${lx+16}" y="${legendY}" font-size="10" fill="#374151">${ds.label||''}</text>`;
    });
  }
  if (note) svg += `<text x="${width/2}" y="${height-3}" text-anchor="middle" font-size="9" fill="#94a3b8" font-style="italic">${note}</text>`;
  svg += '</svg>';
  return svg;
}

// Chart 01: ticket distribution
fs.writeFileSync(dir + '\\01_ticket-distribution.svg', barChart({
  title: 'Ticket Volume Distribution per Account',
  subtitle: 'n=50 accounts — 82% have at least one ticket',
  labels: ['0 tickets','1 ticket','2 tickets','3 tickets','4 tickets'],
  datasets: [{data:[9,14,19,5,3], color:'#3b82f6'}],
  yLabel: 'Accounts', yMax: 24,
  note: 'Most accounts file 1–2 tickets; only 9 have never filed'
}));

// Chart 02: complaint rate + avg tickets by plan
fs.writeFileSync(dir + '\\02_complaint-by-plan.svg', barChart({
  title: 'H2: Complaint Rate & Avg Tickets by Plan',
  subtitle: 'Enterprise leads on both dimensions but gap is modest',
  labels: ['Enterprise\n(n=19)', 'Pro\n(n=15)', 'Free\n(n=16)'],
  datasets: [
    {label: 'Complaint rate %', data:[94.7, 73.3, 75.0], color:'#1d4ed8'},
    {label: 'Avg tickets/account', data:[1.68, 1.60, 1.44], color:'#93c5fd'}
  ],
  yLabel: '% or avg count', yMax: 110,
  refLine: 82, refLabel: 'Overall 82%',
  note: 'Enterprise complaint rate 1.29× Pro/Free — below 2× H2 threshold; H2 not confirmed'
}));

// Chart 03: engagement by ticket bucket
fs.writeFileSync(dir + '\\03_engagement-by-bucket.svg', barChart({
  title: 'H1: Platform Engagement by Ticket-Volume Bucket',
  subtitle: 'Mean and median events per account in the events window',
  labels: ['0 tickets\n(n=9)', '1–2 tickets\n(n=33)', '3+ tickets\n(n=8)'],
  datasets: [
    {label: 'Mean events', data:[35.1, 39.6, 42.0], color:'#3b82f6'},
    {label: 'Median events', data:[39, 40, 40.5], color:'#93c5fd'}
  ],
  yLabel: 'Events per account', yMax: 60,
  note: 'Mean: 35→42 = 1.20× ratio — weak signal, below H1 threshold of 1.5×'
}));

// Chart 04: tickets over time
fs.writeFileSync(dir + '\\04_tickets-over-time.svg', barChart({
  title: 'Ticket Volume Over Time (Monthly)',
  subtitle: '* Jun 2025 partial month',
  labels: ['Dec 24','Jan 25','Feb 25','Mar 25','Apr 25','May 25','Jun 25*'],
  datasets: [{data:[10,9,14,9,12,21,4], color:'#3b82f6'}],
  yLabel: 'Tickets opened', yMax: 28,
  note: 'May 2025: 21 tickets — 2.1× the monthly average of 10'
}));

// Chart 05: category by plan
fs.writeFileSync(dir + '\\05_category-by-plan.svg', barChart({
  title: 'Ticket Category by Plan',
  subtitle: 'Pro: feature-request dominant; Free: billing-heavy; Enterprise: even spread',
  labels: ['Bug','Billing','Feature\nRequest','Usage\nQuestion'],
  datasets: [
    {label:'Enterprise', data:[8,8,8,8], color:'#1d4ed8'},
    {label:'Free',       data:[6,8,4,5], color:'#0891b2'},
    {label:'Pro',        data:[8,1,10,5], color:'#7c3aed'}
  ],
  yLabel: 'Tickets', yMax: 14,
  note: 'Pro billing = 1 ticket; Free billing = 8 — clearest category signal in the data'
}));

// Chart 06: H4 pre-signal
fs.writeFileSync(dir + '\\06_presignal-h4.svg', barChart({
  title: 'H4: Event Activity Spikes Before First Ticket',
  subtitle: 'n=29 accounts with first ticket >= Mar 2025 (events window)',
  labels: ['Baseline\n(T-60 to T-30)', 'Pre-ticket\n(T-30 to T)'],
  datasets: [{data:[8.0, 11.2], color:'#ef4444'}],
  yLabel: 'Avg events (30-day window)', yMax: 16,
  note: '13/29 accounts (45%) show >1.5× spike — H4 CONFIRMED (threshold: 40%, ratio: 1.6×)'
}));

console.log('All 6 SVG charts saved to results/');
