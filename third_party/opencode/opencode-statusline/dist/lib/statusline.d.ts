import { type ProviderInfoLike, type UsageReport } from "./providers.js";
import { type StatuslineFieldID } from "./statusline-config.js";
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
export declare function invalidateGitDiffStatsCache(): void;
export type TuiStatuslinePart = {
    field: StatuslineFieldID;
    text: string;
};
export declare function providerBalanceText(report: UsageReport | undefined): string | undefined;
export declare function buildTuiStatuslineParts(api: TuiApiLike, sessionID: string): Promise<TuiStatuslinePart[]>;
export declare function buildTuiStatusline(api: TuiApiLike, sessionID: string): Promise<string>;
export {};
//# sourceMappingURL=statusline.d.ts.map