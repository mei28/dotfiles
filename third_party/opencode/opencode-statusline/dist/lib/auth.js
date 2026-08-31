import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { isRecord, toNonEmptyString } from "./format.js";
function firstExistingPath(candidates) {
    return candidates.find((candidate) => {
        try {
            return fs.statSync(candidate).isFile();
        }
        catch {
            return false;
        }
    }) ?? candidates[0];
}
export function getOpencodeDataDir() {
    if (process.env.OPENCODE_STATUSLINE_DATA_DIR)
        return process.env.OPENCODE_STATUSLINE_DATA_DIR;
    if (process.env.XDG_DATA_HOME)
        return path.join(process.env.XDG_DATA_HOME, "opencode");
    return path.join(os.homedir(), ".local", "share", "opencode");
}
export function getOpencodeStateDir() {
    if (process.env.OPENCODE_STATUSLINE_STATE_DIR)
        return process.env.OPENCODE_STATUSLINE_STATE_DIR;
    if (process.env.XDG_STATE_HOME)
        return path.join(process.env.XDG_STATE_HOME, "opencode");
    return path.join(os.homedir(), ".local", "state", "opencode");
}
export function getAuthJsonPath() {
    if (process.env.OPENCODE_AUTH_JSON)
        return process.env.OPENCODE_AUTH_JSON;
    const candidates = [
        path.join(getOpencodeDataDir(), "auth.json"),
        path.join(os.homedir(), "Library", "Application Support", "opencode", "auth.json"),
        process.env.APPDATA ? path.join(process.env.APPDATA, "opencode", "auth.json") : undefined,
        process.env.LOCALAPPDATA ? path.join(process.env.LOCALAPPDATA, "opencode", "auth.json") : undefined
    ].filter((candidate) => Boolean(candidate));
    return firstExistingPath(candidates);
}
export function readAuthJson() {
    try {
        const parsed = JSON.parse(fs.readFileSync(getAuthJsonPath(), "utf8"));
        if (!isRecord(parsed))
            return {};
        const result = {};
        for (const [key, value] of Object.entries(parsed)) {
            if (isRecord(value))
                result[key] = value;
        }
        return result;
    }
    catch {
        return {};
    }
}
export function readAuthEntry(keys) {
    const auth = readAuthJson();
    for (const key of keys) {
        const entry = auth[key];
        if (entry)
            return { key, entry };
    }
    return undefined;
}
function providerConfig(config, providerID) {
    if (!isRecord(config))
        return undefined;
    const providers = config.provider;
    if (!isRecord(providers))
        return undefined;
    const provider = providers[providerID];
    return isRecord(provider) ? provider : undefined;
}
function resolveConfigApiKey(value) {
    const raw = toNonEmptyString(value);
    if (!raw)
        return undefined;
    const envMatch = /^\{env:([A-Za-z_][A-Za-z0-9_]*)\}$/.exec(raw);
    if (envMatch) {
        const token = toNonEmptyString(process.env[envMatch[1]]);
        return token ? { token, label: `{env:${envMatch[1]}}` } : undefined;
    }
    return { token: raw, label: "provider.options.apiKey" };
}
export function resolveApiCredential(input) {
    for (const env of input.env) {
        const token = toNonEmptyString(process.env[env]);
        if (token)
            return { token, source: { type: "env", label: env } };
    }
    for (const providerID of input.providerIDs) {
        const provider = providerConfig(input.config, providerID);
        const options = isRecord(provider?.options) ? provider.options : undefined;
        const resolved = resolveConfigApiKey(options?.apiKey);
        if (resolved) {
            return {
                token: resolved.token,
                source: { type: "config", label: `${providerID}.${resolved.label}` }
            };
        }
    }
    const providerKey = toNonEmptyString(input.providerInfo?.key);
    if (providerKey)
        return { token: providerKey, source: { type: "provider", label: "provider.key" } };
    const auth = readAuthJson();
    for (const key of input.authKeys) {
        const entry = auth[key];
        const authKey = toNonEmptyString(entry?.key);
        if (entry?.type === "api" && authKey) {
            return { token: authKey, source: { type: "auth", label: `auth.json:${key}` } };
        }
    }
    return undefined;
}
export function resolveOAuthCredential(keys) {
    const auth = readAuthJson();
    for (const key of keys) {
        const entry = auth[key];
        const access = toNonEmptyString(entry?.access);
        if (entry?.type !== "oauth" || !access)
            continue;
        return {
            access,
            refresh: toNonEmptyString(entry.refresh),
            expires: typeof entry.expires === "number" ? entry.expires : undefined,
            accountId: toNonEmptyString(entry.accountId),
            source: { type: "auth", label: `auth.json:${key}` }
        };
    }
    return undefined;
}
export function describeCredentialSource(source) {
    if (!source)
        return undefined;
    if (source.type === "env")
        return `env:${source.label}`;
    return source.label;
}
//# sourceMappingURL=auth.js.map