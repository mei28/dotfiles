export declare function isRecord(value: unknown): value is Record<string, unknown>;
export declare function toFiniteNumber(value: unknown): number | undefined;
export declare function toNonEmptyString(value: unknown): string | undefined;
export declare function clampPercent(value: number): number;
export declare function usedPercentFromRemaining(percentRemaining: number): number;
export declare function formatPercent(value: number): string;
export declare function formatMoney(value: unknown, currency?: string): string | undefined;
export declare function formatTokenAmount(value: number): string;
export declare function formatDurationMs(ms: number): string | undefined;
export declare function formatLocalDateTime(ms: number): string | undefined;
export declare function formatReset(value: {
    resetAtMs?: number;
    resetAfterMs?: number;
}): string | undefined;
export declare function sanitizeDisplayText(value: string): string;
export declare function truncateText(value: string, max?: number): string;
export declare function basename(input: string | undefined): string | undefined;
//# sourceMappingURL=format.d.ts.map