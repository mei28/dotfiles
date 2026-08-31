import { execFile } from "node:child_process";
import { promisify } from "node:util";
import {
  collectProviderUsage,
  findUsageWindow,
  readCachedProviderUsage,
  type ProviderInfoLike,
  type UsageBalance,
  type UsageReport
} from "./providers.js";
import { resolveActiveModel, type MinimalOpencodeClient } from "./opencode-client.js";
import {
  basename,
  formatPercent,
  formatTokenAmount,
  isRecord,
  toFiniteNumber,
  toNonEmptyString
} from "./format.js";
import { loadStatuslineConfig, type StatuslineFieldID } from "./statusline-config.js";

const STATUSLINE_QUOTA_TIMEOUT_MS = 2_500;
const SESSION_MESSAGES_FALLBACK_TIMEOUT_MS = 300;
const SESSION_CHILDREN_TIMEOUT_MS = 300;
const SESSION_DESCENDANTS_TIMEOUT_MS = 1_000;
const MAX_DESCENDANT_DEPTH = 4;
const MAX_DESCENDANT_SESSIONS = 24;
const SESSION_CHILD_CONCURRENCY = 4;
const GIT_DIFF_TIMEOUT_MS = 750;
const GIT_DIFF_CACHE_TTL_MS = 1_500;
const execFileAsync = promisify(execFile);

type TuiApiLike = {
  state: {
    config: unknown;
    provider: ReadonlyArray<ProviderInfoLike>;
    path: {
      state?: string;
      worktree?: string;
      directory?: string;
    };
    vcs?: {
      branch?: string;
    };
    session: {
      get: (sessionID: string) => unknown;
      messages: (sessionID: string) => ReadonlyArray<unknown>;
      status: (sessionID: string) => unknown;
    };
    part?: (messageID: string) => ReadonlyArray<unknown>;
  };
  client?: {
    session?: {
      children?: (...args: any[]) => Promise<unknown>;
      messages?: (...args: any[]) => Promise<unknown>;
    };
  };
};

type ModelMeta = {
  providerID?: string;
  modelID?: string;
};

type TokenTotals = {
  input: number;
  output: number;
  reasoning: number;
  cacheRead: number;
  cacheWrite: number;
  total: number;
};

type SessionCost = {
  amount: number;
  estimated: boolean;
};

type ModelCostRow = {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  tierSize?: number;
  experimental?: boolean;
};

type GenerationMetrics = {
  ttftMs?: number;
  tokensPerSecond?: number;
};

type GitDiffStats = {
  added: number;
  removed: number;
};

const gitDiffStatsCache = new Map<string, {
  loadedAt: number;
  value: Promise<GitDiffStats | undefined>;
}>();

export function invalidateGitDiffStatsCache(): void {
  gitDiffStatsCache.clear();
}

export type TuiStatuslinePart = {
  field: StatuslineFieldID;
  text: string;
};

function parseConfigModel(config: unknown): ModelMeta {
  if (!isRecord(config)) return {};
  const raw = toNonEmptyString(config.model);
  if (!raw) return {};
  const slash = raw.indexOf("/");
  if (slash <= 0) return {};
  return { providerID: raw.slice(0, slash), modelID: raw.slice(slash + 1) || undefined };
}

function modelFromSession(session: unknown): ModelMeta {
  if (!isRecord(session)) return {};
  const model = isRecord(session.model) ? session.model : undefined;
  return {
    providerID: toNonEmptyString(model?.providerID),
    modelID: toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id)
  };
}

function modelFromMessage(message: unknown): ModelMeta {
  if (!isRecord(message)) return {};
  const providerID = toNonEmptyString(message.providerID);
  const modelID = toNonEmptyString(message.modelID);
  if (providerID || modelID) return { providerID, modelID };
  const model = isRecord(message.model) ? message.model : undefined;
  return {
    providerID: toNonEmptyString(model?.providerID),
    modelID: toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id)
  };
}

async function resolveTuiModel(api: TuiApiLike, sessionID: string): Promise<ModelMeta> {
  const client: MinimalOpencodeClient = {
    session: {
      get: async () => api.state.session.get(sessionID),
      messages: async () => api.state.session.messages(sessionID)
    }
  };
  const resolved = await resolveActiveModel({
    client,
    sessionID,
    config: isRecord(api.state.config) ? api.state.config : {},
    providers: api.state.provider,
    stateDir: api.state.path.state
  });
  if (resolved) return resolved;

  const sessionMeta = modelFromSession(api.state.session.get(sessionID));
  if (sessionMeta.providerID || sessionMeta.modelID) return sessionMeta;

  const messages = api.state.session.messages(sessionID);
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const meta = modelFromMessage(messages[index]);
    if (meta.providerID || meta.modelID) return meta;
  }

  return parseConfigModel(api.state.config);
}

function withTimeout<Value>(promise: Promise<Value>, ms: number): Promise<Value | undefined> {
  return new Promise((resolve) => {
    const timer = setTimeout(() => resolve(undefined), ms);
    promise.then(
      (value) => {
        clearTimeout(timer);
        resolve(value);
      },
      () => {
        clearTimeout(timer);
        resolve(undefined);
      }
    );
  });
}

async function mapWithConcurrency<Input, Output>(
  values: readonly Input[],
  concurrency: number,
  run: (value: Input) => Promise<Output>
): Promise<Output[]> {
  const output = new Array<Output>(values.length);
  let nextIndex = 0;
  const worker = async () => {
    while (nextIndex < values.length) {
      const index = nextIndex;
      nextIndex += 1;
      output[index] = await run(values[index]);
    }
  };
  const workerCount = Math.min(Math.max(1, concurrency), values.length);
  await Promise.all(Array.from({ length: workerCount }, worker));
  return output;
}

function clientCallWithTimeout<Value>(
  run: (signal: AbortSignal) => Promise<Value>,
  ms: number
): Promise<{ timedOut: boolean; value?: Value }> {
  return new Promise((resolve) => {
    const controller = new AbortController();
    let settled = false;
    const finish = (result: { timedOut: boolean; value?: Value }) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      resolve(result);
    };
    const timer = setTimeout(() => {
      controller.abort();
      finish({ timedOut: true });
    }, ms);
    try {
      run(controller.signal).then(
        (value) => finish({ timedOut: false, value }),
        () => finish({ timedOut: controller.signal.aborted })
      );
    } catch {
      finish({ timedOut: controller.signal.aborted });
    }
  });
}

function messageTokens(message: unknown): TokenTotals {
  if (!isRecord(message) || !isRecord(message.tokens)) {
    return { input: 0, output: 0, reasoning: 0, cacheRead: 0, cacheWrite: 0, total: 0 };
  }
  const tokens = message.tokens;
  const input = toFiniteNumber(tokens.input) ?? 0;
  const output = toFiniteNumber(tokens.output) ?? 0;
  const reasoning = toFiniteNumber(tokens.reasoning) ?? 0;
  const cache = isRecord(tokens.cache) ? tokens.cache : {};
  const cacheRead = toFiniteNumber(cache.read)
    ?? toFiniteNumber(tokens.cache_read)
    ?? toFiniteNumber(tokens.cacheRead)
    ?? 0;
  const cacheWrite = toFiniteNumber(cache.write)
    ?? toFiniteNumber(tokens.cache_write)
    ?? toFiniteNumber(tokens.cacheWrite)
    ?? 0;
  const explicitTotal = toFiniteNumber(tokens.total);
  const computedTotal = input + output + reasoning + cacheRead + cacheWrite;
  const total = explicitTotal && explicitTotal > 0 ? explicitTotal : computedTotal;
  return { input, output, reasoning, cacheRead, cacheWrite, total };
}

function sessionTokenTotals(messages: readonly unknown[]): TokenTotals {
  const total: TokenTotals = { input: 0, output: 0, reasoning: 0, cacheRead: 0, cacheWrite: 0, total: 0 };
  for (const message of messages) {
    if (!isRecord(message) || message.role !== "assistant") continue;
    const row = messageTokens(message);
    total.input += row.input;
    total.output += row.output;
    total.reasoning += row.reasoning;
    total.cacheRead += row.cacheRead;
    total.cacheWrite += row.cacheWrite;
    total.total += row.total;
  }
  return total;
}

function messageRecordedCost(message: unknown): number | undefined {
  if (!isRecord(message) || message.role !== "assistant") return undefined;
  const cost = toFiniteNumber(message.cost);
  return cost !== undefined && cost >= 0 ? cost : undefined;
}

function latestContextTokens(messages: readonly unknown[]): number {
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = messages[index];
    if (!isRecord(message) || message.role !== "assistant") continue;
    const total = messageTokens(message).total;
    if (total > 0) return total;
  }
  return 0;
}

function modelContextLimit(provider: ProviderInfoLike | undefined, modelID: string | undefined): number | undefined {
  const model = modelInfo(provider, modelID);
  if (!model || !isRecord(model.limit)) return undefined;
  return toFiniteNumber(model.limit.context);
}

function modelInfo(provider: ProviderInfoLike | undefined, modelID: string | undefined): Record<string, unknown> | undefined {
  if (!provider || !modelID || !isRecord(provider.models)) return undefined;
  const model = provider.models[modelID];
  return isRecord(model) ? model : undefined;
}

function modelCostRow(
  row: Record<string, unknown>,
  tierSize?: number,
  experimental = false
): ModelCostRow {
  const cache = isRecord(row.cache) ? row.cache : {};
  return {
    input: toFiniteNumber(row.input) ?? 0,
    output: toFiniteNumber(row.output) ?? 0,
    cacheRead: toFiniteNumber(cache.read) ?? toFiniteNumber(row.cache_read) ?? 0,
    cacheWrite: toFiniteNumber(cache.write) ?? toFiniteNumber(row.cache_write) ?? 0,
    tierSize,
    experimental
  };
}

function parseModelCostRows(model: Record<string, unknown> | undefined): ModelCostRow[] {
  if (!model) return [];
  if (Array.isArray(model.cost)) {
    return model.cost.filter(isRecord).map((row) => {
      const cache = isRecord(row.cache) ? row.cache : {};
      const tier = isRecord(row.tier) ? row.tier : undefined;
      const tierSize = tier?.type === "context" ? toFiniteNumber(tier.size) : undefined;
      return modelCostRow({ ...row, cache }, tierSize);
    });
  }

  if (!isRecord(model.cost)) return [];
  const rows = [modelCostRow(model.cost)];
  if (Array.isArray(model.cost.tiers)) {
    for (const tierRow of model.cost.tiers.filter(isRecord)) {
      const tier = isRecord(tierRow.tier) ? tierRow.tier : undefined;
      const tierSize = tier?.type === "context" ? toFiniteNumber(tier.size) : undefined;
      rows.push(modelCostRow(tierRow, tierSize));
    }
  }
  if (isRecord(model.cost.experimentalOver200K)) {
    rows.push(modelCostRow(model.cost.experimentalOver200K, 200_000, true));
  }
  return rows;
}

function selectModelCostRow(rows: readonly ModelCostRow[], tokens: TokenTotals): ModelCostRow | undefined {
  if (rows.length === 0) return undefined;
  const contextTokens = tokens.input + tokens.cacheRead + tokens.cacheWrite;
  const tiered = rows
    .filter((row) => !row.experimental && row.tierSize !== undefined && contextTokens > row.tierSize)
    .sort((left, right) => (right.tierSize ?? 0) - (left.tierSize ?? 0))[0];
  if (tiered) return tiered;
  const experimental = rows.find((row) => row.experimental && row.tierSize !== undefined && contextTokens > row.tierSize);
  return experimental ?? rows.find((row) => row.tierSize === undefined) ?? rows[0];
}

function estimateMessageCost(input: {
  providers: ReadonlyArray<ProviderInfoLike>;
  fallbackMeta: ModelMeta;
  message: unknown;
}): number | undefined {
  if (!isRecord(input.message) || input.message.role !== "assistant") return undefined;
  const tokens = messageTokens(input.message);
  if (tokens.input + tokens.output + tokens.reasoning + tokens.cacheRead + tokens.cacheWrite <= 0) return undefined;

  const messageMeta = modelFromMessage(input.message);
  const providerID = messageMeta.providerID ?? input.fallbackMeta.providerID;
  const modelID = messageMeta.modelID ?? input.fallbackMeta.modelID;
  const provider = input.providers.find((item) => item.id === providerID);
  const costRow = selectModelCostRow(parseModelCostRows(modelInfo(provider, modelID)), tokens);
  if (!costRow) return undefined;

  return (
    tokens.input * costRow.input
    + tokens.output * costRow.output
    + tokens.reasoning * costRow.output
    + tokens.cacheRead * costRow.cacheRead
    + tokens.cacheWrite * costRow.cacheWrite
  ) / 1_000_000;
}

function sessionCost(input: {
  providers: ReadonlyArray<ProviderInfoLike>;
  fallbackMeta: ModelMeta;
  messages: readonly unknown[];
}): SessionCost | undefined {
  let amount = 0;
  let hasCost = false;
  let estimated = false;

  for (const message of input.messages) {
    const recorded = messageRecordedCost(message);
    if (recorded !== undefined) {
      amount += recorded;
      hasCost = true;
      continue;
    }

    const estimate = estimateMessageCost({ ...input, message });
    if (estimate !== undefined) {
      amount += estimate;
      hasCost = true;
      estimated = true;
    }
  }

  return hasCost ? { amount, estimated } : undefined;
}

function formatSessionCost(cost: SessionCost | undefined): string | undefined {
  if (!cost) return undefined;
  const amount = cost.amount;
  const precision = amount === 0 || amount >= 0.01 ? 2 : amount >= 0.001 ? 3 : 4;
  const prefix = cost.estimated ? "eq " : "cost ";
  return `${prefix}$${amount.toFixed(precision)}`;
}

function timestampMs(value: unknown): number | undefined {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const raw = toNonEmptyString(value);
  if (!raw) return undefined;
  const numeric = Number(raw);
  if (Number.isFinite(numeric)) return numeric;
  const parsed = Date.parse(raw);
  return Number.isFinite(parsed) ? parsed : undefined;
}

function messageTimeMs(message: Record<string, unknown>, key: "created" | "completed"): number | undefined {
  const time = isRecord(message.time) ? message.time : undefined;
  return timestampMs(time?.[key]) ?? timestampMs(message[`${key}At`]);
}

function partStartMs(part: Record<string, unknown>): number | undefined {
  const time = isRecord(part.time) ? part.time : undefined;
  const state = isRecord(part.state) ? part.state : undefined;
  const stateTime = isRecord(state?.time) ? state.time : undefined;
  return timestampMs(time?.start) ?? timestampMs(stateTime?.start);
}

function partEndMs(part: Record<string, unknown>): number | undefined {
  const time = isRecord(part.time) ? part.time : undefined;
  const state = isRecord(part.state) ? part.state : undefined;
  const stateTime = isRecord(state?.time) ? state.time : undefined;
  return timestampMs(time?.end) ?? timestampMs(stateTime?.end);
}

function latestAssistantMessages(messages: readonly unknown[]): Record<string, unknown>[] {
  const result: Record<string, unknown>[] = [];
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = messages[index];
    if (isRecord(message) && message.role === "assistant") result.push(message);
  }
  return result;
}

function combinedIntervalDurationMs(intervals: Array<{ start: number; end: number }>): number | undefined {
  const sorted = intervals
    .filter((interval) => interval.end > interval.start)
    .sort((left, right) => left.start - right.start);
  if (sorted.length === 0) return undefined;

  let total = 0;
  let currentStart = sorted[0].start;
  let currentEnd = sorted[0].end;
  for (const interval of sorted.slice(1)) {
    if (interval.start <= currentEnd) {
      currentEnd = Math.max(currentEnd, interval.end);
      continue;
    }
    total += currentEnd - currentStart;
    currentStart = interval.start;
    currentEnd = interval.end;
  }
  return total + currentEnd - currentStart;
}

function generationMetricsForMessage(api: TuiApiLike, message: Record<string, unknown>): GenerationMetrics | undefined {
  const messageID = toNonEmptyString(message?.id);
  if (!message || !messageID || !api.state.part) return undefined;

  const created = messageTimeMs(message, "created");
  const completed = messageTimeMs(message, "completed");
  const parts = api.state.part(messageID).filter(isRecord);
  const generatedParts = parts.filter((part) => ["text", "reasoning"].includes(toNonEmptyString(part.type) ?? ""));
  const firstOutputStart = generatedParts
    .map(partStartMs)
    .filter((value): value is number => value !== undefined)
    .sort((left, right) => left - right)[0];
  const generationDurationMs = combinedIntervalDurationMs(
    generatedParts.flatMap((part) => {
      const start = partStartMs(part);
      const end = partEndMs(part) ?? completed;
      return start !== undefined && end !== undefined ? [{ start, end }] : [];
    })
  );

  const tokens = messageTokens(message);
  const ttftMs = created !== undefined && firstOutputStart !== undefined
    ? Math.max(0, firstOutputStart - created)
    : undefined;
  const generatedTokens = tokens.output + tokens.reasoning;
  const tokensPerSecond = generationDurationMs && generatedTokens > 0
    ? generatedTokens / (generationDurationMs / 1000)
    : undefined;

  if (ttftMs === undefined && tokensPerSecond === undefined) return undefined;
  return { ttftMs, tokensPerSecond };
}

function latestGenerationMetrics(api: TuiApiLike, messages: readonly unknown[]): GenerationMetrics | undefined {
  let partial: GenerationMetrics | undefined;
  for (const message of latestAssistantMessages(messages)) {
    const metrics = generationMetricsForMessage(api, message);
    if (!metrics) continue;
    if (metrics.ttftMs !== undefined && metrics.tokensPerSecond !== undefined) return metrics;
    partial ??= metrics;
  }
  return partial;
}

function formatLatencyMs(value: number): string {
  if (value < 1000) return `${Math.round(value)}ms`;
  const seconds = value / 1000;
  if (seconds < 10) return `${seconds.toFixed(1).replace(/\.0$/, "")}s`;
  return `${Math.round(seconds)}s`;
}

function formatTokensPerSecond(value: number): string {
  if (value >= 100) return String(Math.round(value));
  if (value >= 10) return value.toFixed(1).replace(/\.0$/, "");
  return value.toFixed(2).replace(/0+$/, "").replace(/\.$/, "");
}

function generationMetricsText(metrics: GenerationMetrics | undefined): string | undefined {
  if (!metrics) return undefined;
  const parts: string[] = [];
  if (metrics.ttftMs !== undefined) parts.push(`ttft ${formatLatencyMs(metrics.ttftMs)}`);
  if (metrics.tokensPerSecond !== undefined) parts.push(`gen ${formatTokensPerSecond(metrics.tokensPerSecond)} tok/s`);
  return parts.length ? parts.join(" ") : undefined;
}

function parseGitNumstat(stdout: string): GitDiffStats {
  const stats: GitDiffStats = { added: 0, removed: 0 };
  for (const line of stdout.split("\n")) {
    const [addedRaw, removedRaw] = line.split("\t", 3);
    const added = Number(addedRaw);
    const removed = Number(removedRaw);
    if (!Number.isFinite(added) || !Number.isFinite(removed)) continue;
    stats.added += added;
    stats.removed += removed;
  }
  return stats;
}

async function runGitNumstat(cwd: string, args: string[]): Promise<GitDiffStats | undefined> {
  try {
    const { stdout } = await execFileAsync("git", args, {
      cwd,
      encoding: "utf8",
      timeout: GIT_DIFF_TIMEOUT_MS,
      windowsHide: true,
      maxBuffer: 1024 * 1024
    });
    return parseGitNumstat(stdout);
  } catch {
    return undefined;
  }
}

async function loadGitDiffStats(cwd: string): Promise<GitDiffStats | undefined> {
  const stats = await runGitNumstat(cwd, ["diff", "HEAD", "--no-ext-diff", "--numstat", "--"]);
  if (!stats) return undefined;
  return stats.added > 0 || stats.removed > 0 ? stats : undefined;
}

async function gitDiffStats(api: TuiApiLike): Promise<GitDiffStats | undefined> {
  const cwd = toNonEmptyString(api.state.path.worktree) ?? toNonEmptyString(api.state.path.directory);
  if (!cwd) return undefined;

  const now = Date.now();
  const cached = gitDiffStatsCache.get(cwd);
  if (cached && now - cached.loadedAt < GIT_DIFF_CACHE_TTL_MS) return cached.value;

  const value = loadGitDiffStats(cwd);
  gitDiffStatsCache.set(cwd, { loadedAt: now, value });
  return value;
}

function gitDiffStatsText(stats: GitDiffStats | undefined): string | undefined {
  return stats ? `+${stats.added},-${stats.removed}` : undefined;
}

function sessionStatusLabel(status: unknown): string | undefined {
  if (!isRecord(status)) return undefined;
  const type = toNonEmptyString(status.type);
  if (!type) return undefined;
  if (type === "retry") {
    const attempt = toFiniteNumber(status.attempt);
    return attempt ? `retry#${attempt}` : "retry";
  }
  return type;
}

function isInactiveSessionStatus(status: string | undefined): boolean {
  return !status || ["idle", "done", "complete", "completed"].includes(status);
}

function allowsBackgroundStatuslineRefresh(status: string | undefined): boolean {
  return isInactiveSessionStatus(status) || status === "queued" || status === "pending";
}

function agentStatusText(status: string | undefined): string | undefined {
  if (!status || ["queued", "pending"].includes(status)) return undefined;
  return status;
}

async function getChildSessions(
  api: TuiApiLike,
  sessionID: string,
  timeoutMs = SESSION_CHILDREN_TIMEOUT_MS
): Promise<unknown[]> {
  const deadline = Date.now() + timeoutMs;
  const attempts: unknown[][] = [
    [{ sessionID }],
    [{ path: { sessionID } }],
    [{ path: { id: sessionID } }]
  ];
  for (const args of attempts) {
    const remainingMs = deadline - Date.now();
    if (remainingMs <= 0) return [];
    try {
      const result = await clientCallWithTimeout(
        (signal) => Promise.resolve(api.client?.session?.children?.(...args, { signal })),
        remainingMs
      );
      if (result.timedOut) return [];
      const response = result.value;
      const data = isRecord(response) && "data" in response ? response.data : response;
      if (Array.isArray(data)) return data;
    } catch {
      // Try the next SDK shape.
    }
  }
  return [];
}

function uniqueChildSessions(children: readonly unknown[], parentID: string): unknown[] {
  const seen = new Set([parentID]);
  const result: unknown[] = [];
  for (const child of children) {
    const id = isRecord(child) ? toNonEmptyString(child.id) : undefined;
    if (!id || seen.has(id)) continue;
    seen.add(id);
    result.push(child);
    if (result.length >= MAX_DESCENDANT_SESSIONS) break;
  }
  return result;
}

function childSessionIDs(children: readonly unknown[]): string[] {
  return children
    .map((child) => isRecord(child) ? toNonEmptyString(child.id) : undefined)
    .filter((id): id is string => Boolean(id));
}

async function getDescendantSessions(
  api: TuiApiLike,
  sessionID: string,
  directChildren: readonly unknown[]
): Promise<unknown[]> {
  const deadline = Date.now() + SESSION_DESCENDANTS_TIMEOUT_MS;
  const seen = new Set([sessionID]);
  const descendants: unknown[] = [];
  let frontier = [...directChildren];

  for (let depth = 0; depth < MAX_DESCENDANT_DEPTH && frontier.length > 0; depth += 1) {
    const current: string[] = [];
    for (const child of frontier) {
      const id = isRecord(child) ? toNonEmptyString(child.id) : undefined;
      if (!id || seen.has(id)) continue;
      seen.add(id);
      descendants.push(child);
      current.push(id);
      if (descendants.length >= MAX_DESCENDANT_SESSIONS) return descendants;
    }
    const nested = await mapWithConcurrency(current, SESSION_CHILD_CONCURRENCY, (childID) => {
      const remainingMs = Math.min(SESSION_CHILDREN_TIMEOUT_MS, deadline - Date.now());
      return remainingMs > 0 ? getChildSessions(api, childID, remainingMs) : Promise.resolve([]);
    });
    frontier = nested.flat();
    if (Date.now() >= deadline) break;
  }
  return descendants;
}

async function getClientSessionMessages(
  api: TuiApiLike,
  sessionID: string,
  timeoutMs = SESSION_MESSAGES_FALLBACK_TIMEOUT_MS
): Promise<unknown[]> {
  const deadline = Date.now() + timeoutMs;
  const attempts: unknown[][] = [
    [{ sessionID }],
    [{ path: { sessionID } }],
    [{ path: { id: sessionID } }]
  ];
  for (const args of attempts) {
    const remainingMs = deadline - Date.now();
    if (remainingMs <= 0) return [];
    try {
      const result = await clientCallWithTimeout(
        (signal) => Promise.resolve(api.client?.session?.messages?.(...args, { signal })),
        remainingMs
      );
      if (result.timedOut) return [];
      const response = result.value;
      const data = isRecord(response) && "data" in response ? response.data : response;
      if (Array.isArray(data)) return data;
      if (isRecord(data) && Array.isArray(data.messages)) return data.messages;
    } catch {
      // Try the next SDK shape.
    }
  }
  return [];
}

async function sessionMessages(api: TuiApiLike, sessionID: string): Promise<readonly unknown[]> {
  const local = api.state.session.messages(sessionID);
  if (sessionTokenTotals(local).total > 0) return local;
  const status = sessionStatusLabel(api.state.session.status(sessionID));
  if (!allowsBackgroundStatuslineRefresh(status)) return local;
  const remote = await getClientSessionMessages(api, sessionID);
  if (sessionTokenTotals(remote).total > 0) return remote;
  return local.length > 0 ? local : remote;
}

async function sessionMessagesWithChildren(
  api: TuiApiLike,
  messages: readonly unknown[],
  children: readonly unknown[]
): Promise<unknown[]> {
  const childMessages = await mapWithConcurrency(
    childSessionIDs(children),
    SESSION_CHILD_CONCURRENCY,
    (childID) => sessionMessages(api, childID)
  );
  return [...messages, ...childMessages.flat()];
}

async function subagentText(api: TuiApiLike, sessionID: string, children?: readonly unknown[]): Promise<string | undefined> {
  const session = api.state.session.get(sessionID);
  if (isRecord(session) && toNonEmptyString(session.parentID)) {
    const status = sessionStatusLabel(api.state.session.status(sessionID));
    return allowsBackgroundStatuslineRefresh(status) ? undefined : `sub ${status}`;
  }

  const childSessions = children ?? uniqueChildSessions(await getChildSessions(api, sessionID), sessionID);
  if (childSessions.length === 0) return undefined;
  const statuses = childSessions.map((child) => {
    const childID = isRecord(child) ? toNonEmptyString(child.id) : undefined;
    return childID ? sessionStatusLabel(api.state.session.status(childID)) : undefined;
  });
  const active = statuses.filter((status) => !allowsBackgroundStatuslineRefresh(status));
  return active.length ? `sub ${active.length} ${active[0]}` : undefined;
}

function quotaText(window: ReturnType<typeof findUsageWindow>, label: string): string | undefined {
  if (!window?.usedPercent && window?.usedPercent !== 0) return undefined;
  return `${label} ${formatPercent(window.usedPercent)}`;
}

function providerBalanceRank(balance: UsageBalance): number {
  const label = balance.label.toLowerCase();
  if (label.includes("remaining")) return 0;
  if (label.includes("balance")) return 1;
  if (label.includes("credit")) return 2;
  return 3;
}

function displayableBalanceValue(balance: UsageBalance): string | undefined {
  const value = toNonEmptyString(balance.value);
  return value && /\d/.test(value) ? value : undefined;
}

export function providerBalanceText(report: UsageReport | undefined): string | undefined {
  if (!report?.ok) return undefined;
  const selected = report.balances
    .map((balance, index) => ({ balance, index, rank: providerBalanceRank(balance), value: displayableBalanceValue(balance) }))
    .filter((item): item is { balance: UsageBalance; index: number; rank: number; value: string } => Boolean(item.value))
    .sort((left, right) => left.rank - right.rank || left.index - right.index)[0];
  return selected ? `bal ${selected.value}` : undefined;
}

export async function buildTuiStatuslineParts(api: TuiApiLike, sessionID: string): Promise<TuiStatuslinePart[]> {
  const fields = loadStatuslineConfig().fields;
  if (fields.length === 0) return [];

  const [messages, meta] = await Promise.all([
    sessionMessages(api, sessionID),
    resolveTuiModel(api, sessionID)
  ]);
  const provider = api.state.provider.find((item) => item.id === meta.providerID);
  const sessionStatus = sessionStatusLabel(api.state.session.status(sessionID));
  const canRefreshBackgroundFields = allowsBackgroundStatuslineRefresh(sessionStatus);
  const contextUsed = latestContextTokens(messages);
  const contextLimit = modelContextLimit(provider, meta.modelID);
  const generationMetrics = latestGenerationMetrics(api, messages);
  const childFields = fields.some((field) => ["subagent_status", "session_io", "session_total", "session_cost"].includes(field));
  const diffStatsPromise = fields.includes("git_diff_stats") && canRefreshBackgroundFields
    ? gitDiffStats(api)
    : Promise.resolve(undefined);
  const childDataPromise = childFields && canRefreshBackgroundFields
    ? (async () => {
        const directChildren = uniqueChildSessions(await getChildSessions(api, sessionID), sessionID);
        const children = directChildren.length > 0
          ? await getDescendantSessions(api, sessionID, directChildren)
          : directChildren;
        const allMessages = await sessionMessagesWithChildren(api, messages, children);
        return { children, allMessages };
      })()
    : Promise.resolve({ children: [] as unknown[], allMessages: [...messages] });

  const providerUsageFields = fields.some((field) => ["quota_5h", "quota_weekly", "provider_balance"].includes(field));
  const providerID = meta.providerID;
  const quotaReportPromise = providerID && providerUsageFields
    ? (async () => {
        const usageInput = {
          providerID,
          providerName: toNonEmptyString(provider?.name),
          modelID: meta.modelID,
          config: api.state.config,
          providerInfo: provider
        };
        let report = readCachedProviderUsage(usageInput, { allowStale: true });
        if (canRefreshBackgroundFields) {
          const refreshed = await withTimeout(collectProviderUsage(usageInput), STATUSLINE_QUOTA_TIMEOUT_MS);
          if (refreshed) report = refreshed;
        }
        return report?.ok ? report : undefined;
      })()
    : Promise.resolve(undefined);

  const [diffStats, childData, quotaReport] = await Promise.all([
    diffStatsPromise,
    childDataPromise,
    quotaReportPromise
  ]);
  const { children, allMessages } = childData;
  const sessionTokens = sessionTokenTotals(allMessages);
  const cost = fields.includes("session_cost")
    ? sessionCost({ providers: api.state.provider, fallbackMeta: meta, messages: allMessages })
    : undefined;

  const parts: TuiStatuslinePart[] = [];
  for (const field of fields) {
    const text = await renderField({
      api,
      sessionID,
      field,
      provider,
      contextUsed,
      contextLimit,
      generationMetrics,
      gitDiffStats: diffStats,
      children,
      sessionTokens,
      sessionCost: cost,
      quotaReport
    });
    if (text) parts.push({ field, text });
  }

  return parts;
}

export async function buildTuiStatusline(api: TuiApiLike, sessionID: string): Promise<string> {
  const parts = await buildTuiStatuslineParts(api, sessionID);
  return parts.map((part) => part.text).join(" | ");
}

async function renderField(input: {
  api: TuiApiLike;
  sessionID: string;
  field: StatuslineFieldID;
  provider?: ProviderInfoLike;
  contextUsed: number;
  contextLimit?: number;
  generationMetrics?: GenerationMetrics;
  gitDiffStats?: GitDiffStats;
  children?: readonly unknown[];
  sessionTokens: TokenTotals;
  sessionCost?: SessionCost;
  quotaReport?: Awaited<ReturnType<typeof collectProviderUsage>>;
}): Promise<string | undefined> {
  switch (input.field) {
    case "repo":
      return basename(input.api.state.path.worktree) ?? basename(input.api.state.path.directory);
    case "branch":
      return input.api.state.vcs?.branch;
    case "git_diff_stats":
      return gitDiffStatsText(input.gitDiffStats);
    case "context_used":
      return `ctx ${formatTokenAmount(input.contextUsed)}`;
    case "context_remaining":
      return input.contextLimit === undefined
        ? undefined
        : `ctx left ${formatTokenAmount(Math.max(0, input.contextLimit - input.contextUsed))}`;
    case "context_length":
      return input.contextLimit === undefined
        ? undefined
        : `ctx max ${formatTokenAmount(input.contextLimit)}`;
    case "context_window":
      return input.contextLimit === undefined
        ? undefined
        : `ctx ${formatTokenAmount(input.contextUsed)}/${formatTokenAmount(input.contextLimit)}`;
    case "generation_metrics":
      return generationMetricsText(input.generationMetrics);
    case "subagent_status":
      return subagentText(input.api, input.sessionID, input.children);
    case "agent_status": {
      const status = sessionStatusLabel(input.api.state.session.status(input.sessionID));
      return agentStatusText(status);
    }
    case "quota_5h":
      return quotaText(findUsageWindow(input.quotaReport, "fiveHour"), "5h");
    case "quota_weekly":
      return quotaText(findUsageWindow(input.quotaReport, "weekly"), "week");
    case "provider_balance":
      return providerBalanceText(input.quotaReport);
    case "session_io":
      return `${formatTokenAmount(input.sessionTokens.input)} in / ${formatTokenAmount(input.sessionTokens.output)} out`;
    case "session_total":
      return `${formatTokenAmount(input.sessionTokens.total)} used`;
    case "session_cost":
      return formatSessionCost(input.sessionCost);
    default:
      return undefined;
  }
}
