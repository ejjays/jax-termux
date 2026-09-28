// jax-telemetry: opt-in failure reports from the JAX CLI.
// Open endpoint by design (phones hold no secrets). Accepts ONLY the
// documented fields within strict caps; everything else is dropped.
// No IPs, paths, prompts, tokens or file contents are ever stored.

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
      if (!body || typeof body !== "object" || JSON.stringify(body).length > 2048) {
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
    try {
      await env.jax_telemetry
        .prepare(
          "INSERT INTO failures (day, command, module, tool, exit_code, error_class, jax_version, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        )
        .bind(
          day,
          body.command,
          STR(body.module, 32),
          STR(body.tool, 64),
          INT(body.exit_code),
          STR(body.error_class, 200),
          STR(body.jax_version, 16),
          now
        )
        .run();
    } catch {
      return new Response("Bad request", { status: 400 });
    }
    return Response.json({ ok: true }, { status: 202 });
  },
};
