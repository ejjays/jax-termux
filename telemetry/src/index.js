// jax-telemetry: opt-in failure reports from the JAX CLI.
// Open endpoint by design (phones hold no secrets). Accepts ONLY the
// documented fields within strict caps; everything else is dropped.
// No IPs, paths, prompts, tokens or file contents are ever stored.
// v1 payload: { v, command, module, tool, exit_code, error_class,
//               jax_version, log_tail }

const COMMANDS = new Set(["install", "update", "reinstall", "uninstall"]);
const STR = (v, max) => (typeof v === "string" ? v.slice(0, max) : "");
const INT = (v) => (Number.isInteger(v) ? v : 0);

// best-effort per-isolate rate limit: 20 reports / IP / minute
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
  const text =
    `jax failure: ${row.command} ${row.module} --${row.tool} (exit ${row.exit_code})\n` +
    `${row.error_class}\n` +
    `jax ${row.jax_version} · ${row.day}`;
  try {
    await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: chat, text: text.slice(0, 3500) }),
    });
  } catch {
    // alerting must never break the report path
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
    };
    try {
      await env.jax_telemetry
        .prepare(
          "INSERT INTO failures (day, command, module, tool, exit_code, error_class, jax_version, created_at, log_tail) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
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
          row.log_tail
        )
        .run();
    } catch {
      return new Response("Bad request", { status: 400 });
    }
    await pingTelegram(env, row);
    return Response.json({ ok: true }, { status: 202 });
  },
};
