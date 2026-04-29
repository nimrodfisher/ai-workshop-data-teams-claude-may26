const fs = require('fs');

const base = 'c:/Users/liati/Downloads/ai-workshop-data-teams-Apr26/analyses/fintech-pro-activity-drop_2026-04-28_nimrod-fisher/results';

const fixes = [
  { file: base + '/eda/03_activity-timeseries.svg',         w: 700, h: 320 },
  { file: base + '/eda/04_event-type-breakdown.svg',        w: 700, h: 340 },
  { file: base + '/eda/05_user-activity-heatmap.svg',       w: 700, h: 340 },
  { file: base + '/deep-analysis/08_platform-benchmark.svg',w: 700, h: 300 },
  { file: base + '/deep-analysis/10_event-type-per-account.svg', w: 700, h: 360 },
];

fixes.forEach(({ file, w, h }) => {
  let t = fs.readFileSync(file, 'utf8');
  const name = file.split('/').pop();

  // Insert width and height into the <svg ...> opening tag, right after <svg
  // The tag currently looks like: <svg xmlns="..." viewBox="0 0 W H" preserveAspectRatio="..." ...>
  t = t.replace(
    /^(<svg\s)/,
    `<svg width="${w}" height="${h}" `
  );

  // Also prepend XML declaration for correct encoding signal to VS Code renderer
  if (!t.startsWith('<?xml')) {
    t = '<?xml version="1.0" encoding="UTF-8"?>\n' + t;
  }

  fs.writeFileSync(file, t, 'utf8');
  console.log('Fixed dimensions for:', name, `(${w}x${h})`);

  // Verify
  const check = fs.readFileSync(file, 'utf8');
  const svgTag = check.match(/<svg[^>]+>/);
  console.log('  SVG tag:', svgTag ? svgTag[0].slice(0, 120) : 'NOT FOUND');
  console.log('');
});

console.log('All done.');
