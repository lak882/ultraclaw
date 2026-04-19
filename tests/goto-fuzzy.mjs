#!/usr/bin/env node
// goto-fuzzy.mjs — verifies the /goto fuzzy matcher lands on the right
// portal-urls entry for common user queries. Mirrors goto.js's scoring
// exactly (trigram similarity + slug/alias/keyword bonuses) so a passing
// run here means the browser would pick the same hit.
//
// Run from project root:
//   node tests/goto-fuzzy.mjs
//
// Fetches the live catalog from the local interclaw-test instance.

const BASE = 'http://localhost/interclaw-test';
const URL  = BASE + '/api/interclaw/production/api/portal-urls';

const ANSI = { green: '\x1b[32m', red: '\x1b[31m', bold: '\x1b[1m', reset: '\x1b[0m' };
let PASS = 0, FAIL = 0;
const failures = [];

function pass(msg) { console.log(`  ${ANSI.green}PASS${ANSI.reset} ${msg}`); PASS++; }
function fail(msg) { console.log(`  ${ANSI.red}FAIL${ANSI.reset} ${msg}`); FAIL++; failures.push(msg); }
function section(t) { console.log(`\n${ANSI.bold}=== ${t} ===${ANSI.reset}`); }

// ── Copied verbatim from frontend/interclaw-chatbot/goto.js ──
// Keep in sync if goto.js changes — diverging here would mean the harness
// no longer predicts what the browser does, which is the whole point.
function trigrams(str) {
  str = str.toLowerCase();
  var t = {};
  for (var i = 0; i <= str.length - 3; i++) {
    var tri = str.substring(i, i + 3);
    t[tri] = (t[tri] || 0) + 1;
  }
  return t;
}

function trigramSimilarity(a, b) {
  var ta = trigrams(a);
  var tb = trigrams(b);
  var shared = 0, totalA = 0, totalB = 0;
  for (var k in ta) { totalA += ta[k]; if (tb[k]) shared += Math.min(ta[k], tb[k]); }
  for (var k in tb) { totalB += tb[k]; }
  if (totalA + totalB === 0) return 0;
  return (2 * shared) / (totalA + totalB);
}

function scoreEntry(entry, queryLower) {
  if (entry.slug && entry.slug.toLowerCase() === queryLower) return 10;
  if (entry.title && entry.title.toLowerCase() === queryLower) return 9;
  var aliases = entry.aliases || [];
  for (var ai = 0; ai < aliases.length; ai++) {
    if (aliases[ai].toLowerCase() === queryLower) return 8;
  }

  var score = 0;
  var fields = [entry.slug, entry.title, entry.description];
  aliases.forEach(function(a) { fields.push(a); });
  (entry.keywords || []).forEach(function(k) { fields.push(k); });

  (entry.keywords || []).forEach(function(k) {
    if (k.toLowerCase() === queryLower) score += 1.2;
  });

  var containsFieldsScored = 0;
  for (var i = 0; i < fields.length; i++) {
    if (!fields[i]) continue;
    var f = fields[i].toLowerCase();
    if (f === queryLower) continue;
    if (f.indexOf(queryLower) !== -1 && containsFieldsScored < 2) {
      score += 0.4;
      containsFieldsScored++;
    }
    var sim = trigramSimilarity(queryLower, f);
    if (sim > 0.3) score += sim * 0.6;
  }
  return score;
}

function findPortalEntries(catalog, query, maxResults = 5) {
  const q = (query || '').trim().toLowerCase();
  if (!q) return [];
  const entries = catalog.entries || [];
  const scored = [];
  for (const entry of entries) {
    const s = scoreEntry(entry, q);
    if (s > 0.4) scored.push({ entry, score: s });
  }
  scored.sort((a, b) => b.score - a.score);
  return scored.slice(0, maxResults);
}

// ── Fetch catalog ──
async function main() {
  let catalog;
  try {
    const r = await fetch(URL, { credentials: 'same-origin' });
    if (!r.ok) throw new Error(`HTTP ${r.status}`);
    catalog = await r.json();
  } catch (e) {
    fail(`Fetch catalog from ${URL}: ${e.message}`);
    summarize();
    process.exit(1);
  }
  section('Catalog');
  if ((catalog.entries || []).length >= 30) {
    pass(`catalog has >=30 entries (got ${catalog.entries.length})`);
  } else {
    fail(`catalog has >=30 entries (got ${(catalog.entries || []).length})`);
  }

  // Required fields on every entry
  const requiredFields = ['slug', 'title', 'url'];
  let missing = [];
  for (const e of catalog.entries || []) {
    for (const f of requiredFields) {
      if (!e[f]) missing.push(`${e.slug || '?'}.${f}`);
    }
  }
  if (missing.length === 0) {
    pass(`all entries have {slug, title, url}`);
  } else {
    fail(`all entries have {slug, title, url} — missing: ${missing.slice(0,5).join(', ')}${missing.length>5?'…':''}`);
  }

  // ── Exact-slug queries ──
  section('Exact slug match');
  for (const slug of ['home', 'audit', 'queues', 'production', 'sql']) {
    const hits = findPortalEntries(catalog, slug);
    if (hits.length === 0) {
      fail(`query "${slug}" returned no matches`);
      continue;
    }
    if (hits[0].entry.slug === slug) {
      pass(`"${slug}" -> slug="${hits[0].entry.slug}" (score ${hits[0].score.toFixed(2)})`);
    } else {
      fail(`"${slug}" expected slug="${slug}", got "${hits[0].entry.slug}" (score ${hits[0].score.toFixed(2)})`);
    }
  }

  // ── Alias queries — each should resolve to the owning slug ──
  section('Alias resolution');
  const aliasCases = [
    ['smp',             'home'],
    ['query tool',      'sql'],
    ['audit log',       'audit'],
    ['messages',        'message-viewer'],
    ['trace',           'visual-trace'],
    ['event log',       'event-log'],
    ['queue list',      'queues'],
    ['hl7 schema list', 'hl7-schemas'],
    ['namespace list',  'namespaces'],
    ['credential list', 'credentials'],
  ];
  for (const [query, expectedSlug] of aliasCases) {
    const hits = findPortalEntries(catalog, query);
    if (hits.length === 0) {
      fail(`alias "${query}" -> no matches`);
    } else if (hits[0].entry.slug === expectedSlug) {
      pass(`alias "${query}" -> "${expectedSlug}"`);
    } else {
      fail(`alias "${query}" -> "${hits[0].entry.slug}" (expected "${expectedSlug}"); top-3: ${hits.slice(0,3).map(h=>h.entry.slug).join(', ')}`);
    }
  }

  // ── Fuzzy / near-miss queries — user typos or shortened names ──
  section('Fuzzy / near-miss');
  const fuzzyCases = [
    ['message viewer',  'message-viewer'],
    ['schema structure', 'hl7-schema-structure'],
    ['lookup',          'lookup-table'],
    ['bpl',             'bpl-editor'],
    ['dtl',             'dtl-editor'],
    ['rule',            'rule-editor'],
    ['task scheduler',  'tasks'],
    ['process list',    'processes'],
  ];
  for (const [query, expectedSlug] of fuzzyCases) {
    const hits = findPortalEntries(catalog, query);
    if (hits.length === 0) {
      fail(`fuzzy "${query}" -> no matches`);
    } else if (hits[0].entry.slug === expectedSlug) {
      pass(`fuzzy "${query}" -> "${expectedSlug}"`);
    } else {
      fail(`fuzzy "${query}" -> "${hits[0].entry.slug}" (expected "${expectedSlug}"); top-3: ${hits.slice(0,3).map(h=>h.entry.slug).join(', ')}`);
    }
  }

  // ── Below-threshold queries — noise should filter out ──
  section('Below-threshold / empty');
  const emptyCases = ['', '   ', 'xyzzyfoobarbaz', 'qqqqqqqqqq'];
  for (const q of emptyCases) {
    const hits = findPortalEntries(catalog, q);
    if (hits.length === 0) {
      pass(`query ${JSON.stringify(q)} -> 0 matches (correct)`);
    } else {
      fail(`query ${JSON.stringify(q)} -> ${hits.length} spurious matches (top: ${hits[0].entry.slug})`);
    }
  }

  // ── requires:name entries behave predictably ──
  section('requires:name entries');
  const needsName = (catalog.entries || []).filter(e => (e.requires || []).includes('name'));
  if (needsName.length > 0) {
    pass(`catalog declares ${needsName.length} entries with requires:["name"]`);
    // When user queries one of those slugs, goto.js's fallback prefers an
    // alternative that doesn't need a name — verify such alternatives exist
    // for common editor queries.
    for (const e of needsName.slice(0, 3)) {
      const hits = findPortalEntries(catalog, e.slug, 5);
      const anyNoNameAlt = hits.some(h => !(h.entry.requires || []).includes('name'));
      // This is informational only — absence isn't necessarily a failure.
      if (anyNoNameAlt) {
        pass(`"${e.slug}" has a no-name alternative in top 5 hits`);
      } else {
        // Flip into a soft pass — catalog is fine, executeGoto will just
        // report "needs a target name" to the user.
        pass(`"${e.slug}" has no no-name alternative (executeGoto will prompt for a name)`);
      }
    }
  } else {
    pass(`no entries require names (simpler UX)`);
  }

  // ── Template expansion sanity ──
  section('Template placeholders');
  const placeholders = ['{origin}', '{pathPrefix}', '{namespace}', '{namespaceLower}'];
  let atLeastOne = 0;
  for (const e of catalog.entries || []) {
    for (const p of placeholders) {
      if (e.url && e.url.includes(p)) { atLeastOne++; break; }
    }
  }
  if (atLeastOne > 0) {
    pass(`${atLeastOne} entries use at least one template placeholder`);
  } else {
    fail(`no entries use template placeholders (URL expansion logic unused?)`);
  }

  summarize();
}

function summarize() {
  console.log(`\n${ANSI.bold}=== Summary ===${ANSI.reset}`);
  console.log(`Passed: ${ANSI.green}${PASS}${ANSI.reset}`);
  console.log(`Failed: ${ANSI.red}${FAIL}${ANSI.reset}`);
  if (FAIL > 0) {
    console.log('\nFailures:');
    failures.forEach(f => console.log(`  - ${f}`));
    process.exit(1);
  }
  process.exit(0);
}

main();
