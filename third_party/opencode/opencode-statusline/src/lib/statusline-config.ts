import fs from "node:fs";
import path from "node:path";
import { getOpencodeDataDir } from "./auth.js";
import { isRecord, toNonEmptyString } from "./format.js";

export const STATUSLINE_CONFIG_VERSION = 1;

export const STATUSLINE_FIELDS = [
  { id: "repo", label: "Repository", aliases: ["repository", "project"] },
  { id: "branch", label: "Branch", aliases: ["git"] },
  { id: "git_diff_stats", label: "Git diff stats", aliases: ["diff", "changes", "git_diff", "git_changes", "lines", "loc", "delta"] },
  { id: "context_used", label: "Context used", aliases: ["ctx", "ctx_used", "context"] },
  { id: "context_remaining", label: "Context remaining", aliases: ["ctx_left", "left"] },
  { id: "context_length", label: "Context length", aliases: ["context_limit", "ctx_limit", "ctx_max", "model_context", "window"] },
  { id: "context_window", label: "Context used/total", aliases: ["ctx_total", "context_total"] },
  { id: "generation_metrics", label: "TTFT/speed", aliases: ["ttft", "speed", "generation_speed", "gen_speed", "tokens_per_second", "tps", "perf"] },
  { id: "subagent_status", label: "Subagent status", aliases: ["subagent", "subagents", "sub"] },
  { id: "agent_status", label: "Main agent status", aliases: ["agent", "status"] },
  { id: "quota_5h", label: "5h quota", aliases: ["5h", "quota5h", "five_hour"] },
  { id: "quota_weekly", label: "Weekly quota", aliases: ["week", "weekly", "quota_week"] },
  { id: "provider_balance", label: "Provider balance", aliases: ["balance", "bal", "credits", "credit", "remaining_balance", "limit_remaining", "money_left"] },
  { id: "session_io", label: "Session input/output tokens", aliases: ["io", "tokens_io"] },
  { id: "session_total", label: "Session total tokens", aliases: ["tokens", "total_tokens"] },
  { id: "session_cost", label: "Session cost", aliases: ["cost", "spend", "spent", "money", "price", "usd"] }
] as const;

export type StatuslineFieldID = (typeof STATUSLINE_FIELDS)[number]["id"];

export type StatuslineConfig = {
  version: number;
  fields: StatuslineFieldID[];
};

const FIELD_BY_TOKEN = new Map<string, StatuslineFieldID>();
for (const field of STATUSLINE_FIELDS) {
  FIELD_BY_TOKEN.set(field.id, field.id);
  FIELD_BY_TOKEN.set(field.label.toLowerCase().replace(/\s+/g, "_"), field.id);
  for (const alias of field.aliases) FIELD_BY_TOKEN.set(alias, field.id);
}

export function getStatuslineConfigPath(): string {
  if (process.env.OPENCODE_STATUSLINE_CONFIG) return process.env.OPENCODE_STATUSLINE_CONFIG;
  return path.join(getOpencodeDataDir(), "statusline-plugin.json");
}

export function normalizeStatuslineField(value: string): StatuslineFieldID | undefined {
  return FIELD_BY_TOKEN.get(value.trim().toLowerCase().replace(/[-\s]+/g, "_"));
}

export function uniqueFields(fields: readonly StatuslineFieldID[]): StatuslineFieldID[] {
  const seen = new Set<StatuslineFieldID>();
  const result: StatuslineFieldID[] = [];
  for (const field of fields) {
    if (seen.has(field)) continue;
    seen.add(field);
    result.push(field);
  }
  return result;
}

export function loadStatuslineConfig(): StatuslineConfig {
  try {
    const parsed: unknown = JSON.parse(fs.readFileSync(getStatuslineConfigPath(), "utf8"));
    if (!isRecord(parsed) || !Array.isArray(parsed.fields)) {
      return { version: STATUSLINE_CONFIG_VERSION, fields: [] };
    }
    const fields = parsed.fields
      .map((field) => (typeof field === "string" ? normalizeStatuslineField(field) : undefined))
      .filter((field): field is StatuslineFieldID => Boolean(field));
    return { version: STATUSLINE_CONFIG_VERSION, fields: uniqueFields(fields) };
  } catch {
    return { version: STATUSLINE_CONFIG_VERSION, fields: [] };
  }
}

export function saveStatuslineConfig(config: StatuslineConfig): void {
  const file = getStatuslineConfigPath();
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(
    file,
    `${JSON.stringify({ version: STATUSLINE_CONFIG_VERSION, fields: uniqueFields(config.fields) }, null, 2)}\n`
  );
}

export function parseStatuslineFieldArguments(args: string): {
  clear: boolean;
  fields: StatuslineFieldID[];
  unknown: string[];
} {
  const tokens = args
    .split(/[\s,]+/g)
    .map((token) => token.trim())
    .filter(Boolean);

  if (tokens.some((token) => ["clear", "none", "off", "reset"].includes(token.toLowerCase()))) {
    return { clear: true, fields: [], unknown: [] };
  }

  const fields: StatuslineFieldID[] = [];
  const unknown: string[] = [];
  for (const token of tokens) {
    const field = normalizeStatuslineField(token);
    if (field) fields.push(field);
    else if (toNonEmptyString(token)) unknown.push(token);
  }
  return { clear: false, fields: uniqueFields(fields), unknown };
}
