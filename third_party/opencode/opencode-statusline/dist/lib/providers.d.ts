export type UsageWindowKey = "fiveHour" | "daily" | "weekly" | "monthly" | "codeReview" | "other";
export type UsageWindow = {
    key: UsageWindowKey;
    label: string;
    used?: number;
    total?: number;
    unit?: string;
    usedPercent?: number;
    remainingPercent?: number;
    resetAtMs?: number;
    resetAfterMs?: number;
};
export type UsageBalance = {
    label: string;
    value: string;
};
export type UsageItem = {
    label: string;
    value: string;
};
export type UsageReport = {
    ok: boolean;
    providerID: string;
    providerName?: string;
    modelID?: string;
    generatedAtMs: number;
    auth?: string;
    plan?: string;
    windows: UsageWindow[];
    balances: UsageBalance[];
    items: UsageItem[];
    error?: string;
};
export type ProviderInfoLike = {
    id?: string;
    name?: string;
    key?: string;
    options?: Record<string, unknown>;
    models?: Record<string, unknown>;
};
export type CollectProviderUsageInput = {
    providerID: string;
    providerName?: string;
    modelID?: string;
    config?: unknown;
    providerInfo?: ProviderInfoLike;
    force?: boolean;
};
export declare function readCachedProviderUsage(input: CollectProviderUsageInput, options?: {
    allowStale?: boolean;
}): UsageReport | undefined;
export declare function clearProviderUsageCache(): void;
export declare function fetchJsonWithTimeout(url: string, init?: RequestInit, timeoutMs?: number): Promise<unknown>;
export declare function findUsageWindow(report: UsageReport | undefined, key: UsageWindowKey): UsageWindow | undefined;
export declare function collectProviderUsage(input: CollectProviderUsageInput): Promise<UsageReport>;
//# sourceMappingURL=providers.d.ts.map