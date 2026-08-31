import fs from "node:fs";
import path from "node:path";
import { getOpencodeStateDir } from "./auth.js";
import { collectProviderUsage, type ProviderInfoLike, type UsageReport } from "./providers.js";
import { sanitizeDisplayText, toNonEmptyString, isRecord } from "./format.js";

export type MinimalOpencodeClient = {
  config?: {
    get?: (...args: unknown[]) => Promise<unknown>;
    providers?: (...args: unknown[]) => Promise<unknown>;
  };
  session?: {
    get?: (...args: unknown[]) => Promise<unknown>;
    messages?: (...args: unknown[]) => Promise<unknown>;
    prompt?: (...args: unknown[]) => Promise<unknown>;
  };
  app?: {
    log?: (...args: unknown[]) => Promise<unknown>;
  };
};

export type ModelMeta = {
  providerID: string;
  modelID?: string;
};

export type RecentModelState = {
  model: ModelMeta;
  mtimeMs: number;
};

const PLUGIN_STARTED_AT_MS = Date.now();

function unwrapData(value: unknown): unknown {
  return isRecord(value) && "data" in value ? value.data : value;
}

function parseModelString(value: unknown): ModelMeta | undefined {
  const raw = toNonEmptyString(value);
  if (!raw) return undefined;
  const slash = raw.indexOf("/");
  if (slash <= 0) return undefined;
  return { providerID: raw.slice(0, slash), modelID: raw.slice(slash + 1) || undefined };
}

export async function getConfigData(client: MinimalOpencodeClient): Promise<Record<string, unknown>> {
  try {
    const response = await client.config?.get?.();
    const data = unwrapData(response);
    return isRecord(data) ? data : {};
  } catch {
    return {};
  }
}

export async function getConfiguredProviders(client: MinimalOpencodeClient): Promise<ProviderInfoLike[]> {
  try {
    const response = await client.config?.providers?.();
    const data = unwrapData(response);
    if (isRecord(data) && Array.isArray(data.providers)) return data.providers.filter(isRecord) as ProviderInfoLike[];
    if (Array.isArray(data)) return data.filter(isRecord) as ProviderInfoLike[];
  } catch {
    // Ignore provider-list failures; config/auth fallback still works.
  }
  return [];
}

async function getSessionData(client: MinimalOpencodeClient, sessionID: string): Promise<Record<string, unknown>> {
  const attempts: unknown[][] = [
    [{ path: { id: sessionID } }],
    [{ path: { sessionID } }],
    [{ sessionID }]
  ];
  for (const args of attempts) {
    try {
      const response = await client.session?.get?.(...args);
      const data = unwrapData(response);
      if (isRecord(data)) return data;
    } catch {
      // Try the next SDK shape.
    }
  }
  return {};
}

async function getSessionMessages(client: MinimalOpencodeClient, sessionID: string): Promise<Record<string, unknown>[]> {
  const attempts: unknown[][] = [
    [{ path: { id: sessionID } }],
    [{ path: { sessionID } }],
    [{ sessionID }]
  ];
  for (const args of attempts) {
    try {
      const response = await client.session?.messages?.(...args);
      const data = unwrapData(response);
      if (Array.isArray(data)) return data.filter(isRecord);
      if (isRecord(data) && Array.isArray(data.messages)) return data.messages.filter(isRecord);
    } catch {
      // Try the next SDK shape.
    }
  }
  return [];
}

function modelFromMessage(message: Record<string, unknown>): ModelMeta | undefined {
  const directProvider = toNonEmptyString(message.providerID);
  const directModel = toNonEmptyString(message.modelID);
  if (directProvider) return { providerID: directProvider, modelID: directModel };
  const model = isRecord(message.model) ? message.model : undefined;
  const providerID = toNonEmptyString(model?.providerID);
  const modelID = toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id);
  return providerID ? { providerID, modelID } : undefined;
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

function recordTimestampMs(record: Record<string, unknown>): number | undefined {
  const time = isRecord(record.time) ? record.time : undefined;
  const candidates = [
    timestampMs(time?.updated),
    timestampMs(time?.created),
    timestampMs(record.updatedAt),
    timestampMs(record.createdAt),
    timestampMs(record.updated),
    timestampMs(record.created)
  ].filter((value): value is number => value !== undefined);
  return candidates.length ? Math.max(...candidates) : undefined;
}

function latestActivityMs(session: Record<string, unknown>, messages: readonly Record<string, unknown>[]): number | undefined {
  const candidates = [
    recordTimestampMs(session),
    ...messages.map((message) => recordTimestampMs(message))
  ].filter((value): value is number => value !== undefined);
  return candidates.length ? Math.max(...candidates) : undefined;
}

function providerHasModel(providers: readonly ProviderInfoLike[] | undefined, model: ModelMeta): boolean {
  if (!providers?.length) return true;
  const provider = providers.find((item) => item.id === model.providerID);
  if (!provider) return false;
  if (!model.modelID || !isRecord(provider.models)) return true;
  return model.modelID in provider.models;
}

function modelFromStateEntry(entry: unknown): ModelMeta | undefined {
  if (!isRecord(entry)) return undefined;
  const providerID = toNonEmptyString(entry.providerID);
  const modelID = toNonEmptyString(entry.modelID) ?? toNonEmptyString(entry.id);
  return providerID ? { providerID, modelID } : undefined;
}

function readRecentModelState(
  providers?: readonly ProviderInfoLike[],
  stateDir = getOpencodeStateDir()
): RecentModelState | undefined {
  try {
    const file = path.join(stateDir, "model.json");
    const stat = fs.statSync(file);
    const parsed: unknown = JSON.parse(fs.readFileSync(file, "utf8"));
    if (!isRecord(parsed) || !Array.isArray(parsed.recent)) return undefined;
    for (const entry of parsed.recent) {
      const model = modelFromStateEntry(entry);
      if (model && providerHasModel(providers, model)) return { model, mtimeMs: stat.mtimeMs };
    }
  } catch {
    // The file only exists after the TUI model picker has written recent models.
  }
  return undefined;
}

export function readRecentModelStateFromFile(
  providers?: readonly ProviderInfoLike[],
  stateDir?: string
): RecentModelState | undefined {
  return readRecentModelState(providers, stateDir);
}

export function readRecentModelFromState(
  providers?: readonly ProviderInfoLike[],
  stateDir?: string
): ModelMeta | undefined {
  return readRecentModelState(providers, stateDir)?.model;
}

export async function resolveActiveModel(input: {
  client: MinimalOpencodeClient;
  sessionID: string;
  config?: Record<string, unknown>;
  commandModel?: unknown;
  providers?: readonly ProviderInfoLike[];
  stateDir?: string;
}): Promise<ModelMeta | undefined> {
  const commandModel = parseModelString(input.commandModel);
  if (commandModel) return commandModel;

  const configModel = parseModelString(input.config?.model);
  const session = await getSessionData(input.client, input.sessionID);
  const messages = await getSessionMessages(input.client, input.sessionID);
  const recentModel = readRecentModelState(input.providers, input.stateDir);
  const activityMs = latestActivityMs(session, messages);
  const recentIsCurrentRunSelection = recentModel && recentModel.mtimeMs + 1_000 >= PLUGIN_STARTED_AT_MS;
  const recentIsAfterSessionActivity = recentModel && (activityMs === undefined || recentModel.mtimeMs + 1_000 >= activityMs);
  if (recentModel && recentIsAfterSessionActivity && (!configModel || recentIsCurrentRunSelection)) {
    return recentModel.model;
  }

  const sessionModel = modelFromMessage(session);
  if (sessionModel) return sessionModel;

  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const meta = modelFromMessage(messages[index]);
    if (meta) return meta;
  }

  if (configModel) return configModel;

  return undefined;
}

export async function injectIgnoredText(
  client: MinimalOpencodeClient,
  sessionID: string,
  text: string
): Promise<void> {
  const parts = [{ type: "text", text: sanitizeDisplayText(text), ignored: true }];
  try {
    await client.session?.prompt?.({
      path: { id: sessionID },
      body: {
        noReply: true,
        parts
      }
    });
    return;
  } catch (err) {
    try {
      await client.session?.prompt?.({
        sessionID,
        noReply: true,
        parts
      });
      return;
    } catch {
      throw err;
    }
  }
}

export async function buildCurrentProviderUsageReport(input: {
  client: MinimalOpencodeClient;
  sessionID: string;
  force?: boolean;
  commandModel?: unknown;
  stateDir?: string;
}): Promise<{ report?: UsageReport; model?: ModelMeta; config: Record<string, unknown> }> {
  const config = await getConfigData(input.client);
  const providers = await getConfiguredProviders(input.client);
  const model = await resolveActiveModel({
    client: input.client,
    sessionID: input.sessionID,
    config,
    commandModel: input.commandModel,
    providers,
    stateDir: input.stateDir
  });
  if (!model) return { config };

  const providerInfo = providers.find((provider) => provider.id === model.providerID);
  const report = await collectProviderUsage({
    providerID: model.providerID,
    providerName: toNonEmptyString(providerInfo?.name),
    modelID: model.modelID,
    config,
    providerInfo,
    force: input.force
  });
  return { report, model, config };
}
