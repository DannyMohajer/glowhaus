// Captures screenshots of a running web build with headless Chrome.
//
//   node tool/screenshots.mjs [baseUrl] [outDir]
//
// Defaults: http://localhost:8100/ and build/screenshots. Serve build/site
// first (e.g. python3 -m http.server 8100 --directory build/site).
// Every shot uses a fresh browser profile; theme and language come from the
// emulated system settings, exactly as a first-time visitor would see them.
// No dependencies: Chrome DevTools Protocol over Node's built-in WebSocket.

import { spawn } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const base = process.argv[2] ?? 'http://localhost:8100/';
const out = process.argv[3] ?? 'build/screenshots';
const chrome =
  process.env.CHROME ??
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

const screens = {
  intro: '#/intro',
  dashboard: '#/home',
  room: '#/rooms/living-room',
  thermostat: '#/rooms/living-room/devices/lr-thermostat',
  settings: '#/settings',
};
const sizes = {
  phone: { width: 390, height: 844, mobile: true },
  tablet: { width: 820, height: 1180, mobile: false },
  desktop: { width: 1280, height: 800, mobile: false },
};

const shots = [];
for (const [name, route] of Object.entries(screens)) {
  for (const size of ['phone', 'tablet']) {
    for (const scheme of ['light', 'dark']) {
      shots.push({ name, route, size, scheme, locale: 'en' });
    }
  }
}
// Persian (RTL): the dashboard on a phone, room + device on a tablet and the
// three-pane desktop layout, in both themes.
for (const scheme of ['light', 'dark']) {
  shots.push({ name: 'dashboard', route: screens.dashboard, size: 'phone', scheme, locale: 'fa' });
  shots.push({ name: 'thermostat', route: screens.thermostat, size: 'tablet', scheme, locale: 'fa' });
  shots.push({ name: 'thermostat', route: screens.thermostat, size: 'desktop', scheme, locale: 'fa' });
}
shots.push({ name: 'thermostat', route: screens.thermostat, size: 'desktop', scheme: 'light', locale: 'en' });
shots.push({ name: 'dashboard', route: screens.dashboard, size: 'phone', scheme: 'light', locale: 'tr' });

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function main() {
  mkdirSync(out, { recursive: true });
  const profile = mkdtempSync(join(tmpdir(), 'glowhaus-shots-'));
  const port = 9333;
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
    for (const shot of shots) {
      const file = `${shot.name}-${shot.size}-${shot.scheme}${shot.locale === 'en' ? '' : `-${shot.locale}`}.png`;
      await capture(cdp, shot, join(out, file));
      console.log(file);
    }
    cdp.close();
  } finally {
    browser.kill();
    await sleep(300);
    rmSync(profile, { recursive: true, force: true });
  }
}

async function capture(cdp, shot, file) {
  const { browserContextId } = await cdp.send('Target.createBrowserContext');
  const { targetId } = await cdp.send('Target.createTarget', {
    url: 'about:blank',
    browserContextId,
  });
  const { sessionId } = await cdp.send('Target.attachToTarget', {
    targetId,
    flatten: true,
  });
  const page = (method, params) => cdp.send(method, params, sessionId);
  const size = sizes[shot.size];
  await page('Emulation.setDeviceMetricsOverride', {
    width: size.width,
    height: size.height,
    deviceScaleFactor: 2,
    mobile: size.mobile,
  });
  await page('Emulation.setEmulatedMedia', {
    features: [{ name: 'prefers-color-scheme', value: shot.scheme }],
  });
  await page('Emulation.setLocaleOverride', { locale: shot.locale });
  // Flutter reads the system language from navigator.languages, which the
  // locale override above leaves alone.
  await page('Page.addScriptToEvaluateOnNewDocument', {
    source: `Object.defineProperty(navigator, 'languages', { get: () => ['${shot.locale}'] });
             Object.defineProperty(navigator, 'language', { get: () => '${shot.locale}' });`,
  });
  await page('Page.enable');
  await page('Page.navigate', { url: base + shot.route });
  // First frame, fonts, and the simulated devices' first state reports.
  await sleep(shot.locale === 'fa' ? 6000 : 4500);
  const { data } = await page('Page.captureScreenshot', { format: 'png' });
  writeFileSync(file, Buffer.from(data, 'base64'));
  await cdp.send('Target.closeTarget', { targetId });
  await cdp.send('Target.disposeBrowserContext', { browserContextId });
}

function connect(url) {
  const socket = new WebSocket(url);
  let nextId = 1;
  const pending = new Map();
  socket.onmessage = (event) => {
    const message = JSON.parse(event.data);
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
        close: () => socket.close(),
      });
  });
}

await main();
