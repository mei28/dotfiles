export declare const STATUSLINE_CONFIG_VERSION = 1;
export declare const STATUSLINE_FIELDS: readonly [{
    readonly id: "repo";
    readonly label: "Repository";
    readonly aliases: readonly ["repository", "project"];
}, {
    readonly id: "branch";
    readonly label: "Branch";
    readonly aliases: readonly ["git"];
}, {
    readonly id: "git_diff_stats";
    readonly label: "Git diff stats";
    readonly aliases: readonly ["diff", "changes", "git_diff", "git_changes", "lines", "loc", "delta"];
}, {
    readonly id: "context_used";
    readonly label: "Context used";
    readonly aliases: readonly ["ctx", "ctx_used", "context"];
}, {
    readonly id: "context_remaining";
    readonly label: "Context remaining";
    readonly aliases: readonly ["ctx_left", "left"];
}, {
    readonly id: "context_length";
    readonly label: "Context length";
    readonly aliases: readonly ["context_limit", "ctx_limit", "ctx_max", "model_context", "window"];
}, {
    readonly id: "context_window";
    readonly label: "Context used/total";
    readonly aliases: readonly ["ctx_total", "context_total"];
}, {
    readonly id: "generation_metrics";
    readonly label: "TTFT/speed";
    readonly aliases: readonly ["ttft", "speed", "generation_speed", "gen_speed", "tokens_per_second", "tps", "perf"];
}, {
    readonly id: "subagent_status";
    readonly label: "Subagent status";
    readonly aliases: readonly ["subagent", "subagents", "sub"];
}, {
    readonly id: "agent_status";
    readonly label: "Main agent status";
    readonly aliases: readonly ["agent", "status"];
}, {
    readonly id: "quota_5h";
    readonly label: "5h quota";
    readonly aliases: readonly ["5h", "quota5h", "five_hour"];
}, {
    readonly id: "quota_weekly";
    readonly label: "Weekly quota";
    readonly aliases: readonly ["week", "weekly", "quota_week"];
}, {
    readonly id: "provider_balance";
    readonly label: "Provider balance";
    readonly aliases: readonly ["balance", "bal", "credits", "credit", "remaining_balance", "limit_remaining", "money_left"];
}, {
    readonly id: "session_io";
    readonly label: "Session input/output tokens";
    readonly aliases: readonly ["io", "tokens_io"];
}, {
    readonly id: "session_total";
    readonly label: "Session total tokens";
    readonly aliases: readonly ["tokens", "total_tokens"];
}, {
    readonly id: "session_cost";
    readonly label: "Session cost";
    readonly aliases: readonly ["cost", "spend", "spent", "money", "price", "usd"];
}];
export type StatuslineFieldID = (typeof STATUSLINE_FIELDS)[number]["id"];
export type StatuslineConfig = {
    version: number;
    fields: StatuslineFieldID[];
};
export declare function getStatuslineConfigPath(): string;
export declare function normalizeStatuslineField(value: string): StatuslineFieldID | undefined;
export declare function uniqueFields(fields: readonly StatuslineFieldID[]): StatuslineFieldID[];
export declare function loadStatuslineConfig(): StatuslineConfig;
export declare function saveStatuslineConfig(config: StatuslineConfig): void;
export declare function parseStatuslineFieldArguments(args: string): {
    clear: boolean;
    fields: StatuslineFieldID[];
    unknown: string[];
};
//# sourceMappingURL=statusline-config.d.ts.map