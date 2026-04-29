const fs = require('fs');

const base = 'c:/Users/liati/Downloads/ai-workshop-data-teams-Apr26/analyses/fintech-pro-activity-drop_2026-04-28_nimrod-fisher/results';
const R = '\uFFFD'; // Unicode replacement character present in corrupted files

// ── 03_activity-timeseries.svg ──────────────────────────────────────────────
{
  let t = fs.readFileSync(base + '/eda/03_activity-timeseries.svg', 'utf8');
  // Subtitle: 'Jun 6, 2025 · Shaded' — middle-dot separator
  t = t.replace('Jun 6, 2025 ' + R + ' Shaded', 'Jun 6, 2025 &#xB7; Shaded');
  // Comments: '8 → y=', '10 → y=' etc — arrow notation in comments
  t = t.replace(new RegExp('(\\d+) ' + R + ' y=', 'g'), '$1 → y=');
  fs.writeFileSync(base + '/eda/03_activity-timeseries.svg', t, 'utf8');
  console.log('Fixed: 03_activity-timeseries.svg');
}

// ── 04_event-type-breakdown.svg ─────────────────────────────────────────────
{
  let t = fs.readFileSync(base + '/eda/04_event-type-breakdown.svg', 'utf8');
  // Subtitle: 'accounts · Red' — middle-dot separator
  t = t.replace('accounts ' + R + ' Red', 'accounts &#xB7; Red');
  fs.writeFileSync(base + '/eda/04_event-type-breakdown.svg', t, 'utf8');
  console.log('Fixed: 04_event-type-breakdown.svg');
}

// ── 05_user-activity-heatmap.svg ────────────────────────────────────────────
{
  let t = fs.readFileSync(base + '/eda/05_user-activity-heatmap.svg', 'utf8');
  // Subtitle separators
  t = t.replace('accounts ' + R + ' arrow', 'accounts &#xB7; arrow');
  t = t.replace('change ' + R + ' red',    'change &#xB7; red');
  // Change indicator arrows — infer direction from text color already present
  const lines = t.split('\n');
  for (let i = 0; i < lines.length; i++) {
    if (!lines[i].includes(R)) continue;
    if (lines[i].includes('ef4444') || lines[i].includes('f59e0b')) {
      lines[i] = lines[i].split(R).join('&#x25BC;');  // ▼ red/amber = decline
    } else if (lines[i].includes('22c55e')) {
      lines[i] = lines[i].split(R).join('&#x25B2;');  // ▲ green = increase
    } else {
      lines[i] = lines[i].split(R).join('x');         // admin x2
    }
  }
  t = lines.join('\n');
  fs.writeFileSync(base + '/eda/05_user-activity-heatmap.svg', t, 'utf8');
  console.log('Fixed: 05_user-activity-heatmap.svg');
}

// ── 08_platform-benchmark.svg ───────────────────────────────────────────────
{
  let t = fs.readFileSync(base + '/deep-analysis/08_platform-benchmark.svg', 'utf8');
  // Visible text: '37 → 26 events', '574 → 636 events'
  t = t.replace(new RegExp('(\\d+) ' + R + ' (\\d+) events', 'g'), '$1 &#x2192; $2 events');
  // Remaining replacement chars in comments
  t = t.split(R).join('->');
  // Add missing <defs> with #arr arrowhead marker (referenced but never defined)
  const defsBlock = '<defs><marker id="arr" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto"><path d="M0,0 L0,6 L8,3 z" fill="#7c3aed"/></marker></defs>';
  t = t.replace('<rect width="700"', defsBlock + '\n  <rect width="700"');
  fs.writeFileSync(base + '/deep-analysis/08_platform-benchmark.svg', t, 'utf8');
  console.log('Fixed: 08_platform-benchmark.svg');
}

// ── 10_event-type-per-account.svg ───────────────────────────────────────────
{
  let t = fs.readFileSync(base + '/deep-analysis/10_event-type-per-account.svg', 'utf8');
  const lines = t.split('\n');
  for (let i = 0; i < lines.length; i++) {
    if (!lines[i].includes(R)) continue;
    const l = lines[i];
    if (l.includes('<!--')) {
      // Comments
      lines[i] = l.split(R).join('->');
    } else if (l.includes('"11" font-weight="bold" fill="#374151">') && l.trim().endsWith(R + '</text>')) {
      // Lone Δ column header
      lines[i] = l.split(R).join('&#x394;');
    } else {
      // All other visible text: right-arrow (22 → 18 etc)
      lines[i] = l.split(R).join('&#x2192;');
    }
  }
  t = lines.join('\n');
  fs.writeFileSync(base + '/deep-analysis/10_event-type-per-account.svg', t, 'utf8');
  console.log('Fixed: 10_event-type-per-account.svg');
}

console.log('All done. Verifying no replacement chars remain...');
const allFiles = [
  base + '/eda/03_activity-timeseries.svg',
  base + '/eda/04_event-type-breakdown.svg',
  base + '/eda/05_user-activity-heatmap.svg',
  base + '/deep-analysis/08_platform-benchmark.svg',
  base + '/deep-analysis/10_event-type-per-account.svg',
];
allFiles.forEach(f => {
  const content = fs.readFileSync(f, 'utf8');
  const count = (content.match(/\uFFFD/g) || []).length;
  console.log(count === 0 ? 'OK' : 'STILL HAS ' + count + ' issues', f.split('/').pop());
});
