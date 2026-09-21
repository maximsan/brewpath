/**
 * Ranks what `flutter test` spends its time on, so a slow suite can be
 * attributed rather than guessed at.
 *
 * Usage:
 *   node tool/profile_tests.js                  # runs the suite, then reports
 *   node tool/profile_tests.js --report r.json  # reports on an existing run
 *
 * The suite is 372 files, and the question a total wall time cannot answer is
 * which of two different problems it has: a handful of genuinely slow tests,
 * or a per-file tax paid 372 times. The fixes do not resemble each other —
 * the first is a few tests to repair, the second is fewer, larger files or a
 * different --concurrency — so the report separates them.
 *
 * The discriminator is free in the JSON reporter's own output. Compiling and
 * loading a test file is reported as a hidden test named `loading <path>`,
 * distinct from the tests in it, so "load" below is real per-file overhead
 * measured rather than inferred. Anything left over once both are subtracted
 * from the wall clock is the runner's own setup.
 */

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawnSync } = require("child_process");

const TOP = 20;
const MS_PER_SECOND = 1000;

/** Reads `--report <path>`, or runs the suite into a temporary file. */
function reportPath(argv) {
  const flag = argv.indexOf("--report");
  if (flag !== -1) {
    const given = argv[flag + 1];
    if (!given) fail("--report needs a path");
    return given;
  }
  const out = path.join(
    fs.mkdtempSync(path.join(os.tmpdir(), "brewpath-tests-")),
    "report.json",
  );
  process.stderr.write("Running the suite; this takes as long as CI does.\n");
  const run = spawnSync("flutter", ["test", `--file-reporter=json:${out}`], {
    stdio: ["ignore", "ignore", "inherit"],
  });
  // A failing suite still produces a usable report — only a missing one is
  // fatal, which is what the read below reports.
  if (run.error) fail(`could not run flutter test: ${run.error.message}`);
  return out;
}

function fail(message) {
  process.stderr.write(`tool/profile_tests.js: ${message}\n`);
  process.exit(1);
}

/**
 * Walks the reporter's event stream into one record per test, carrying the
 * suite it belongs to and whether it is a file load rather than a test body.
 */
function parse(file) {
  let lines;
  try {
    lines = fs.readFileSync(file, "utf8").split("\n").filter(Boolean);
  } catch (error) {
    fail(`could not read ${file}: ${error.message}`);
  }

  const suitePaths = new Map();
  const open = new Map();
  const finished = [];
  let wall = 0;

  for (const line of lines) {
    let event;
    try {
      event = JSON.parse(line);
    } catch {
      continue; // The reporter prefixes a banner line on some versions.
    }
    if (typeof event.time === "number") wall = Math.max(wall, event.time);

    if (event.type === "suite") {
      suitePaths.set(event.suite.id, event.suite.path);
    } else if (event.type === "testStart") {
      open.set(event.test.id, {
        name: event.test.name,
        suiteID: event.test.suiteID,
        start: event.time,
      });
    } else if (event.type === "testDone") {
      const started = open.get(event.testID);
      if (!started) continue;
      open.delete(event.testID);
      finished.push({
        name: started.name,
        suite: suitePaths.get(started.suiteID) ?? "(unknown file)",
        ms: event.time - started.start,
        // `hidden` marks the reporter's own bookkeeping entries; the load of
        // a file is the one that matters here.
        isLoad: event.hidden === true && started.name.startsWith("loading "),
      });
    }
  }
  return { finished, wall };
}

const seconds = (ms) => `${(ms / MS_PER_SECOND).toFixed(1)}s`;

function rank(rows, key) {
  const totals = new Map();
  for (const row of rows) {
    totals.set(key(row), (totals.get(key(row)) ?? 0) + row.ms);
  }
  return [...totals].sort((left, right) => right[1] - left[1]);
}

function table(title, ranked, total) {
  process.stdout.write(`\n${title}\n`);
  for (const [name, ms] of ranked.slice(0, TOP)) {
    const share = total > 0 ? `${((ms / total) * 100).toFixed(1)}%` : "—";
    process.stdout.write(
      `  ${seconds(ms).padStart(8)}  ${share.padStart(6)}  ${name}\n`,
    );
  }
}

function main() {
  const { finished, wall } = parse(reportPath(process.argv.slice(2)));
  if (finished.length === 0) fail("the report contains no tests");

  const loads = finished.filter((row) => row.isLoad);
  const tests = finished.filter((row) => !row.isLoad);
  const loadMs = loads.reduce((sum, row) => sum + row.ms, 0);
  const testMs = tests.reduce((sum, row) => sum + row.ms, 0);

  // Tests run in parallel, so these sum past the wall clock; the shares are
  // of the work done, not of the time elapsed.
  const work = loadMs + testMs;
  const share = (ms) => (work > 0 ? `${((ms / work) * 100).toFixed(1)}%` : "—");

  process.stdout.write(
    [
      `Wall clock         ${seconds(wall)}`,
      `Files              ${loads.length}`,
      `Tests              ${tests.length}`,
      `Loading files      ${seconds(loadMs)}  (${share(loadMs)} of work)`,
      `Running tests      ${seconds(testMs)}  (${share(testMs)} of work)`,
    ].join("\n") + "\n",
  );

  table("Slowest files to load", rank(loads, (row) => row.suite), loadMs);
  table("Slowest files to run", rank(tests, (row) => row.suite), testMs);
  table(
    "Slowest individual tests",
    tests
      .sort((left, right) => right.ms - left.ms)
      .map((row) => [`${row.name}  [${path.basename(row.suite)}]`, row.ms]),
    testMs,
  );

  // A lopsided split points at one fix; a middle one means both are real, and
  // saying "running dominates" at 65% would send someone hunting for a slow
  // test that does not exist.
  const MIXED_FLOOR = 0.3;
  const loadShare = work > 0 ? loadMs / work : 0;
  const verdict =
    loadShare > 1 - MIXED_FLOOR
      ? "Loading dominates: the cost is per-file. Fewer, larger files or a\n" +
        "different --concurrency will move it; fixing individual tests will not."
      : loadShare < MIXED_FLOOR
        ? "Running dominates: the cost is in the tests above, not in file count."
        : "Split roughly evenly, so neither fix alone is enough. Loading is a\n" +
          "per-file tax on all " +
          `${loads.length} files; running is concentrated in the files above.`;
  process.stdout.write(`\n${verdict}\n`);
}

main();
