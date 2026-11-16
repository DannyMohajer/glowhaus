// Records the README animation: the app and its devices panel at `#/demo`,
// a tap in the app, a press on a device's own button, the live MQTT traffic,
// a lost command that the app rolls back after the timeout, and a device
// unplugged with its Power switch.
//
//   node tool/record_demo.mjs [baseUrl] [out.gif]
//
// Defaults: http://localhost:8100/ and docs/screenshots/demo.gif. Serve
// build/site first (python3 -m http.server 8100 --directory build/site).
// Needs Chrome and ffmpeg.
//
// The simulated network is set to lose or reject half of all commands, so a
// take only counts when the first tap succeeds and the second is lost; the
// script tries again until it gets one (a take is about 20 seconds). Clicks
// find their targets through Flutter's accessibility tree, never by fixed
// coordinates. No dependencies: Chrome DevTools Protocol over Node's
// WebSocket.

import { spawn, spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const base = process.argv[2] ?? 'http://localhost:8100/';
const out = process.argv[3] ?? 'docs/screenshots/demo.gif';
const chrome =
  process.env.CHROME ??
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
// Tall enough that the traffic list, below the twelve device rows, shows a
// command's set, ack and state between the devices' ambient readings.
const viewport = { width: 1280, height: 1800 };
const maxTakes = 30;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Saved settings the app reads at start (shared_preferences on the web keeps
// JSON-encoded values under a `flutter.` prefix): a slow, unreliable link so
// the pending state is visible and a command can get lost.
const settings = { themeMode: 'light', latencyMs: 900, failureRate: 0.5, showIntro: false };

// A tap marker and a caption, drawn over the Flutter view. Both are plain DOM
// with pointer-events off, so they never get in the way of the clicks.
const overlay = `
  window.__glow = {
    caption(text) {
      let el = document.getElementById('glow-caption');
      if (!el) {
        el = document.createElement('div');
        el.id = 'glow-caption';
        el.style.cssText = 'position:fixed;left:124px;width:740px;top:790px;z-index:99999;pointer-events:none;' +
          'display:flex;justify-content:center;transition:opacity .25s';
        el.innerHTML = '<span style="background:#1c1917;color:#fafaf9;border-radius:999px;padding:12px 22px;' +
          'font:600 17px/1.2 -apple-system,Helvetica,Arial,sans-serif;box-shadow:0 8px 24px rgba(0,0,0,.25)"></span>';
        document.body.appendChild(el);
      }
      el.firstChild.textContent = text;
      el.style.opacity = text ? '1' : '0';
    },
    tap(x, y) {
      const el = document.createElement('div');
      el.style.cssText = 'position:fixed;z-index:99999;pointer-events:none;border-radius:50%;' +
        'width:44px;height:44px;left:' + (x - 22) + 'px;top:' + (y - 22) + 'px;' +
        'background:rgba(28,25,23,.28);border:3px solid rgba(28,25,23,.75);transition:transform .5s,opacity .5s';
      document.body.appendChild(el);
      requestAnimationFrame(() => requestAnimationFrame(() => {
        el.style.transform = 'scale(1.6)';
        el.style.opacity = '0';
      }));
      setTimeout(() => el.remove(), 700);
    },
  };
`;

async function main() {
  const profile = mkdtempSync(join(tmpdir(), 'glowhaus-rec-'));
  const port = 9335;
  const browser = spawn(chrome, [
    '--headless=new',
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${profile}`,
    '--no-first-run',
    '--hide-scrollbars',
    '--enable-unsafe-swiftshader',
  ]);
  try {
    let version;
    for (let i = 0; i < 50 && !version; i++) {
      await sleep(200);
      version = await fetch(`http://127.0.0.1:${port}/json/version`)
        .then((r) => r.json())
        .catch(() => undefined);
    }
    const cdp = await connect(version.webSocketDebuggerUrl);
    for (let take = 1; take <= maxTakes; take++) {
      const frames = mkdtempSync(join(tmpdir(), 'glowhaus-frames-'));
      try {
        const result = await record(cdp, frames);
        console.log(`take ${take}: ${result.note}`);
        if (result.ok) {
          encode(frames, result.list, out);
          console.log(`wrote ${out}`);
          break;
        }
      } finally {
        rmSync(frames, { recursive: true, force: true });
      }
      if (take === maxTakes) throw new Error('no usable take');
    }
    cdp.close();
  } finally {
    browser.kill();
    await sleep(300);
    rmSync(profile, { recursive: true, force: true });
  }
}

async function record(cdp, dir) {
  const { browserContextId } = await cdp.send('Target.createBrowserContext');
  const { targetId } = await cdp.send('Target.createTarget', { url: 'about:blank', browserContextId });
  const { sessionId } = await cdp.send('Target.attachToTarget', { targetId, flatten: true });
  const page = (method, params) => cdp.send(method, params, sessionId);
  const evaluate = async (expression) =>
    (await page('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true })).result.value;

  const list = [];
  cdp.on(sessionId, 'Page.screencastFrame', ({ data, metadata, sessionId: frameId }) => {
    const file = join(dir, `${String(list.length).padStart(5, '0')}.png`);
    writeFileSync(file, Buffer.from(data, 'base64'));
    list.push({ file, at: metadata.timestamp });
    page('Page.screencastFrameAck', { sessionId: frameId }).catch(() => {});
  });

  try {
    await page('Emulation.setDeviceMetricsOverride', { ...viewport, deviceScaleFactor: 1, mobile: false });
    await page('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'light' }] });
    await page('Page.addScriptToEvaluateOnNewDocument', {
      source: `localStorage.setItem('flutter.settings.v1', ${JSON.stringify(JSON.stringify(JSON.stringify(settings)))});
               Object.defineProperty(navigator, 'languages', { get: () => ['en'] });
               ${overlay}`,
    });
    await page('Page.enable');
    await page('Runtime.enable');
    await page('Page.navigate', { url: `${base}#/demo` });
    await sleep(6000);
    // Turn on Flutter's accessibility tree: the clicks below find their
    // targets in it.
    await evaluate(`document.querySelector('flt-semantics-placeholder')?.click()`);
    await sleep(1500);

    const find = (label, role) =>
      evaluate(`(() => {
        const node = [...document.querySelectorAll('flt-semantics')].find((n) =>
          (n.getAttribute('aria-label') || n.textContent).trim() === ${JSON.stringify(label)} &&
          ${role ? `n.getAttribute('role') === ${JSON.stringify(role)}` : 'true'});
        if (!node) return null;
        const r = node.getBoundingClientRect();
        return { x: r.x + r.width / 2, y: r.y + r.height / 2 };
      })()`);
    const panelRow = (name) =>
      evaluate(`[...document.querySelectorAll('flt-semantics[role=group]')]
        .map((n) => n.getAttribute('aria-label') || n.textContent).find((t) => t.startsWith(${JSON.stringify(`${name}\n`)})) ?? ''`);
    const pageText = () =>
      evaluate(`[...document.querySelectorAll('flt-semantics')].map((n) => n.getAttribute('aria-label') || n.textContent).join(' ')`);
    const click = async (label, role) => {
      const at = await find(label, role);
      if (!at) throw new Error(`not found: ${label}`);
      await evaluate(`window.__glow.tap(${at.x}, ${at.y})`);
      for (const type of ['mouseMoved', 'mousePressed', 'mouseReleased']) {
        await page('Input.dispatchMouseEvent', { type, x: at.x, y: at.y, button: 'left', clickCount: 1 });
        if (type === 'mousePressed') await sleep(60);
      }
    };
    const caption = (text) => evaluate(`window.__glow.caption(${JSON.stringify(text)})`);

    await page('Page.startScreencast', { format: 'png', everyNthFrame: 1 });
    await sleep(1500);

    // 1. A tap in the app: set, then the device's ack and retained state.
    await caption('Tap in the app: set → ack → retained state');
    await sleep(1200);
    await click('Reading light', 'switch');
    await sleep(2200);
    if (!(await panelRow('Reading light')).includes('On')) {
      return { ok: false, note: 'first tap was not applied', list };
    }
    await sleep(1600);

    // 2. The device's own button: a state report, no command.
    await caption("The device's own button: it reports, the app follows");
    await sleep(1200);
    await click('Ceiling light: Press its button', 'button');
    await sleep(3200);

    // 3. A lost command: pending, then rolled back when the timeout ends.
    await caption('A command gets lost: after 5 s the app rolls back');
    await sleep(1200);
    await click('Floor lamp', 'switch');
    await sleep(1500);
    if (!(await panelRow('Floor lamp')).includes('On')) {
      return { ok: false, note: 'second tap was applied', list };
    }
    let text = '';
    for (let i = 0; i < 12 && !/didn.t respond|couldn.t apply|busy/.test(text); i++) {
      await sleep(500);
      text = await pageText();
    }
    if (!/didn.t respond/.test(text)) {
      return { ok: false, note: 'second tap was rejected, not lost', list };
    }
    await sleep(2400);

    // 4. The plug, not the device's switch: it says goodbye, the app shows
    // it offline.
    await caption('Pull the plug: the device says goodbye, the app shows it offline');
    await sleep(1200);
    await click('Power plug of Coffee machine', 'switch');
    await sleep(3000);
    if (!(await panelRow('Coffee machine')).includes('Offline')) {
      return { ok: false, note: 'unplugged device not shown offline', list };
    }
    await caption('');
    await sleep(600);
    return { ok: true, note: 'usable', list };
  } finally {
    await page('Page.stopScreencast').catch(() => {});
    cdp.off(sessionId);
    await cdp.send('Target.closeTarget', { targetId });
    await cdp.send('Target.disposeBrowserContext', { browserContextId });
  }
}

// Screencast frames arrive only when something changes, each with its own
// time; ffmpeg's concat list keeps those times, then one palette for the
// whole clip keeps the GIF small.
function encode(dir, list, file) {
  const lines = ['ffconcat version 1.0'];
  list.forEach((frame, i) => {
    const next = list[i + 1]?.at ?? frame.at + 1;
    lines.push(`file '${frame.file}'`, `duration ${Math.max(0.01, next - frame.at).toFixed(3)}`);
  });
  lines.push(`file '${list.at(-1).file}'`);
  const concat = join(dir, 'frames.txt');
  writeFileSync(concat, lines.join('\n'));
  mkdirSync(join(file, '..'), { recursive: true });
  const filter =
    'fps=10,scale=896:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];' +
    '[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle';
  const run = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'concat', '-safe', '0', '-i', concat,
    '-vf', filter, '-loop', '0', file], { stdio: 'inherit' });
  if (run.status !== 0) throw new Error('ffmpeg failed');
}

function connect(url) {
  const socket = new WebSocket(url);
  let nextId = 1;
  const pending = new Map();
  const listeners = new Map();
  socket.onmessage = (event) => {
    const message = JSON.parse(event.data);
    if (message.method) {
      listeners.get(`${message.sessionId}/${message.method}`)?.(message.params);
      return;
    }
    const waiter = pending.get(message.id);
    if (!waiter) return;
    pending.delete(message.id);
    if (message.error) waiter.reject(new Error(JSON.stringify(message.error)));
    else waiter.resolve(message.result);
  };
  return new Promise((resolve) => {
    socket.onopen = () =>
      resolve({
        send(method, params = {}, sessionId) {
          const id = nextId++;
          socket.send(JSON.stringify({ id, method, params, sessionId }));
          return new Promise((res, rej) => pending.set(id, { resolve: res, reject: rej }));
        },
        on: (sessionId, method, callback) => listeners.set(`${sessionId}/${method}`, callback),
        off: (sessionId) => {
          for (const key of listeners.keys()) if (key.startsWith(`${sessionId}/`)) listeners.delete(key);
        },
        close: () => socket.close(),
      });
  });
}

await main();
