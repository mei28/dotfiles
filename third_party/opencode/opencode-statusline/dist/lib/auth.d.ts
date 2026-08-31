export type AuthEntry = {
    type?: "api" | "oauth" | string;
    key?: string;
    access?: string;
    refresh?: string;
    expires?: number;
    accountId?: string;
};
export type CredentialSource = {
    type: "env";
    label: string;
} | {
    type: "config";
    label: string;
} | {
    type: "provider";
    label: string;
} | {
    type: "auth";
    label: string;
};
export type ApiCredential = {
    token: string;
    source: CredentialSource;
};
export type OAuthCredential = {
    access: string;
    refresh?: string;
    expires?: number;
    accountId?: string;
    source: CredentialSource;
};
export declare function getOpencodeDataDir(): string;
export declare function getOpencodeStateDir(): string;
export declare function getAuthJsonPath(): string;
export declare function readAuthJson(): Record<string, AuthEntry>;
export declare function readAuthEntry(keys: readonly string[]): {
    key: string;
    entry: AuthEntry;
} | undefined;
export declare function resolveApiCredential(input: {
    env: readonly string[];
    config?: unknown;
    providerIDs: readonly string[];
    authKeys: readonly string[];
    providerInfo?: {
        key?: string;
    };
}): ApiCredential | undefined;
export declare function resolveOAuthCredential(keys: readonly string[]): OAuthCredential | undefined;
export declare function describeCredentialSource(source: CredentialSource | undefined): string | undefined;
//# sourceMappingURL=auth.d.ts.map