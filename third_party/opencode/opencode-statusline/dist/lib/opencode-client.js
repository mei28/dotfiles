import fs from "node:fs";
import path from "node:path";
import { getOpencodeStateDir } from "./auth.js";
import { collectProviderUsage } from "./providers.js";
import { sanitizeDisplayText, toNonEmptyString, isRecord } from "./format.js";
const PLUGIN_STARTED_AT_MS = Date.now();
function unwrapData(value) {
    return isRecord(value) && "data" in value ? value.data : value;
}
function parseModelString(value) {
    const raw = toNonEmptyString(value);
    if (!raw)
        return undefined;
    const slash = raw.indexOf("/");
    if (slash <= 0)
        return undefined;
    return { providerID: raw.slice(0, slash), modelID: raw.slice(slash + 1) || undefined };
}
export async function getConfigData(client) {
    try {
        const response = await client.config?.get?.();
        const data = unwrapData(response);
        return isRecord(data) ? data : {};
    }
    catch {
        return {};
    }
}
export async function getConfiguredProviders(client) {
    try {
        const response = await client.config?.providers?.();
        const data = unwrapData(response);
        if (isRecord(data) && Array.isArray(data.providers))
            return data.providers.filter(isRecord);
        if (Array.isArray(data))
            return data.filter(isRecord);
    }
    catch {
        // Ignore provider-list failures; config/auth fallback still works.
    }
    return [];
}
async function getSessionData(client, sessionID) {
    const attempts = [
        [{ path: { id: sessionID } }],
        [{ path: { sessionID } }],
        [{ sessionID }]
    ];
    for (const args of attempts) {
        try {
            const response = await client.session?.get?.(...args);
            const data = unwrapData(response);
            if (isRecord(data))
                return data;
        }
        catch {
            // Try the next SDK shape.
        }
    }
    return {};
}
async function getSessionMessages(client, sessionID) {
    const attempts = [
        [{ path: { id: sessionID } }],
        [{ path: { sessionID } }],
        [{ sessionID }]
    ];
    for (const args of attempts) {
        try {
            const response = await client.session?.messages?.(...args);
            const data = unwrapData(response);
            if (Array.isArray(data))
                return data.filter(isRecord);
            if (isRecord(data) && Array.isArray(data.messages))
                return data.messages.filter(isRecord);
        }
        catch {
            // Try the next SDK shape.
        }
    }
    return [];
}
function modelFromMessage(message) {
    const directProvider = toNonEmptyString(message.providerID);
    const directModel = toNonEmptyString(message.modelID);
    if (directProvider)
        return { providerID: directProvider, modelID: directModel };
    const model = isRecord(message.model) ? message.model : undefined;
    const providerID = toNonEmptyString(model?.providerID);
    const modelID = toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id);
    return providerID ? { providerID, modelID } : undefined;
}
function timestampMs(value) {
    if (typeof value === "number" && Number.isFinite(value))
        return value;
    const raw = toNonEmptyString(value);
    if (!raw)
        return undefined;
    const numeric = Number(raw);
    if (Number.isFinite(numeric))
        return numeric;
    const parsed = Date.parse(raw);
    return Number.isFinite(parsed) ? parsed : undefined;
}
function recordTimestampMs(record) {
    const time = isRecord(record.time) ? record.time : undefined;
    const candidates = [
        timestampMs(time?.updated),
        timestampMs(time?.created),
        timestampMs(record.updatedAt),
        timestampMs(record.createdAt),
        timestampMs(record.updated),
        timestampMs(record.created)
    ].filter((value) => value !== undefined);
    return candidates.length ? Math.max(...candidates) : undefined;
}
function latestActivityMs(session, messages) {
    const candidates = [
        recordTimestampMs(session),
        ...messages.map((message) => recordTimestampMs(message))
    ].filter((value) => value !== undefined);
    return candidates.length ? Math.max(...candidates) : undefined;
}
function providerHasModel(providers, model) {
    if (!providers?.length)
        return true;
    const provider = providers.find((item) => item.id === model.providerID);
    if (!provider)
        return false;
    if (!model.modelID || !isRecord(provider.models))
        return true;
    return model.modelID in provider.models;
}
function modelFromStateEntry(entry) {
    if (!isRecord(entry))
        return undefined;
    const providerID = toNonEmptyString(entry.providerID);
    const modelID = toNonEmptyString(entry.modelID) ?? toNonEmptyString(entry.id);
    return providerID ? { providerID, modelID } : undefined;
}
function readRecentModelState(providers, stateDir = getOpencodeStateDir()) {
    try {
        const file = path.join(stateDir, "model.json");
        const stat = fs.statSync(file);
        const parsed = JSON.parse(fs.readFileSync(file, "utf8"));
        if (!isRecord(parsed) || !Array.isArray(parsed.recent))
            return undefined;
        for (const entry of parsed.recent) {
            const model = modelFromStateEntry(entry);
            if (model && providerHasModel(providers, model))
                return { model, mtimeMs: stat.mtimeMs };
        }
    }
    catch {
        // The file only exists after the TUI model picker has written recent models.
    }
    return undefined;
}
export function readRecentModelStateFromFile(providers, stateDir) {
    return readRecentModelState(providers, stateDir);
}
export function readRecentModelFromState(providers, stateDir) {
    return readRecentModelState(providers, stateDir)?.model;
}
export async function resolveActiveModel(input) {
    const commandModel = parseModelString(input.commandModel);
    if (commandModel)
        return commandModel;
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
    if (sessionModel)
        return sessionModel;
    for (let index = messages.length - 1; index >= 0; index -= 1) {
        const meta = modelFromMessage(messages[index]);
        if (meta)
            return meta;
    }
    if (configModel)
        return configModel;
    return undefined;
}
export async function injectIgnoredText(client, sessionID, text) {
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
    }
    catch (err) {
        try {
            await client.session?.prompt?.({
                sessionID,
                noReply: true,
                parts
            });
            return;
        }
        catch {
            throw err;
        }
    }
}
export async function buildCurrentProviderUsageReport(input) {
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
    if (!model)
        return { config };
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
//# sourceMappingURL=opencode-client.js.map