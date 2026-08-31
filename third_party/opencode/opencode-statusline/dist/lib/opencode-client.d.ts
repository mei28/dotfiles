import { type ProviderInfoLike, type UsageReport } from "./providers.js";
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
export declare function getConfigData(client: MinimalOpencodeClient): Promise<Record<string, unknown>>;
export declare function getConfiguredProviders(client: MinimalOpencodeClient): Promise<ProviderInfoLike[]>;
export declare function readRecentModelStateFromFile(providers?: readonly ProviderInfoLike[], stateDir?: string): RecentModelState | undefined;
export declare function readRecentModelFromState(providers?: readonly ProviderInfoLike[], stateDir?: string): ModelMeta | undefined;
export declare function resolveActiveModel(input: {
    client: MinimalOpencodeClient;
    sessionID: string;
    config?: Record<string, unknown>;
    commandModel?: unknown;
    providers?: readonly ProviderInfoLike[];
    stateDir?: string;
}): Promise<ModelMeta | undefined>;
export declare function injectIgnoredText(client: MinimalOpencodeClient, sessionID: string, text: string): Promise<void>;
export declare function buildCurrentProviderUsageReport(input: {
    client: MinimalOpencodeClient;
    sessionID: string;
    force?: boolean;
    commandModel?: unknown;
    stateDir?: string;
}): Promise<{
    report?: UsageReport;
    model?: ModelMeta;
    config: Record<string, unknown>;
}>;
//# sourceMappingURL=opencode-client.d.ts.map