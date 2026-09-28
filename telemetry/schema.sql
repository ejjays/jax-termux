CREATE TABLE IF NOT EXISTS failures (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  day TEXT NOT NULL,
  command TEXT NOT NULL,
  module TEXT NOT NULL,
  tool TEXT NOT NULL,
  exit_code INTEGER NOT NULL,
  error_class TEXT NOT NULL,
  jax_version TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  log_tail TEXT NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_failures_day_tool ON failures(day, module, tool);
