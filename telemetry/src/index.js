// Open endpoint: phones hold no secrets, so strict validation is the auth.

const COMMANDS = new Set(["install", "update", "reinstall", "uninstall"]);
const STR = (v, max) => (typeof v === "string" ? v.slice(0, max) : "");
const INT = (v) => (Number.isInteger(v) ? v : 0);

// per-isolate only; Cloudflare abuse protection does the real work.
const hits = new Map();
function limited(ip) {
  const now = Date.now();
  const arr = (hits.get(ip) || []).filter((t) => now - t < 60000);
  arr.push(now);
  hits.set(ip, arr);
  return arr.length > 20;
}

async function pingTelegram(env, row) {
  const token = env.TELEGRAM_BOT_TOKEN;
  const chat = env.TELEGRAM_CHAT_ID;
  if (!token || !chat) return;
  const device = [row.android_sdk && `android ${row.android_sdk}`, row.arch, row.app]
    .filter(Boolean)
    .join(" ");
  const text =
    `jax failure: ${row.command} ${row.module} --${row.tool} (exit ${row.exit_code})\n` +
    `${row.error_class}\n` +
    `jax ${row.jax_version}${device ? ` · ${device}` : ""} · ${row.day}`;
  try {
    await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: chat, text: text.slice(0, 3500) }),
    });
  } catch {
    // alerting is best-effort; never break the report path
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/health") {
      return Response.json({ ok: true });
    }
    if (url.pathname !== "/report" || request.method !== "POST") {
      return new Response("Not found", { status: 404 });
    }
    const ip = request.headers.get("CF-Connecting-IP") || "unknown";
    if (limited(ip)) {
      return Response.json({ ok: true });
    }
    let body;
    try {
      body = await request.json();
      if (!body || typeof body !== "object" || JSON.stringify(body).length > 12288) {
        return new Response("Bad request", { status: 400 });
      }
    } catch {
      return new Response("Bad request", { status: 400 });
    }
    if (!COMMANDS.has(body.command)) {
      return new Response("Bad request", { status: 400 });
    }
    const now = Math.floor(Date.now() / 1000);
    const day = new Date().toISOString().slice(0, 10);
    const row = {
      day,
      command: body.command,
      module: STR(body.module, 32),
      tool: STR(body.tool, 64),
      exit_code: INT(body.exit_code),
      error_class: STR(body.error_class, 200),
      jax_version: STR(body.jax_version, 16),
      log_tail: STR(body.log_tail, 8192),
      android_sdk: STR(body.android_sdk, 8),
      arch: STR(body.arch, 16),
      app: STR(body.app, 32),
    };
    try {
      await env.jax_telemetry
        .prepare(
          "INSERT INTO failures (day, command, module, tool, exit_code, error_class, jax_version, created_at, log_tail, android_sdk, arch, app) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        )
        .bind(
          row.day,
          row.command,
          row.module,
          row.tool,
          row.exit_code,
          row.error_class,
          row.jax_version,
          now,
          row.log_tail,
          row.android_sdk,
          row.arch,
          row.app
        )
        .run();
    } catch {
      return new Response("Bad request", { status: 400 });
    }
    await pingTelegram(env, row);
    return Response.json({ ok: true }, { status: 202 });
  },
};
