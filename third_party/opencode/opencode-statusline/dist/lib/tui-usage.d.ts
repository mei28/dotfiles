import { type ProviderInfoLike } from "./providers.js";
type TuiUsageApiLike = {
    state: {
        config: unknown;
        provider: ReadonlyArray<ProviderInfoLike>;
        path?: {
            state?: string;
        };
        session: {
            get: (sessionID: string) => unknown;
            messages: (sessionID: string) => ReadonlyArray<unknown>;
        };
    };
};
export declare function buildTuiUsageText(api: TuiUsageApiLike, sessionID: string): Promise<string>;
export {};
//# sourceMappingURL=tui-usage.d.ts.map