export function isRecord(value) {
    return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}
export function toFiniteNumber(value) {
    if (typeof value === "number" && Number.isFinite(value))
        return value;
    if (typeof value === "string" && value.trim()) {
        const parsed = Number(value);
        if (Number.isFinite(parsed))
            return parsed;
    }
    return undefined;
}
export function toNonEmptyString(value) {
    return typeof value === "string" && value.trim() ? value.trim() : undefined;
}
export function clampPercent(value) {
    if (!Number.isFinite(value))
        return 0;
    return Math.min(100, Math.max(0, value));
}
export function usedPercentFromRemaining(percentRemaining) {
    return clampPercent(100 - percentRemaining);
}
export function formatPercent(value) {
    const clamped = clampPercent(value);
    if (Math.abs(clamped - Math.round(clamped)) < 0.05)
        return `${Math.round(clamped)}%`;
    return `${clamped.toFixed(1)}%`;
}
export function formatMoney(value, currency = "USD") {
    const amount = toFiniteNumber(value);
    if (amount === undefined)
        return undefined;
    if (currency === "USD")
        return `$${amount.toFixed(2)}`;
    if (currency === "CNY")
        return `CNY ${amount.toFixed(2)}`;
    return `${amount.toFixed(2)} ${currency}`;
}
export function formatTokenAmount(value) {
    if (!Number.isFinite(value))
        return "";
    const sign = value < 0 ? "-" : "";
    let n = Math.abs(value);
    const units = ["", "K", "M", "G", "T"];
    let index = 0;
    while (n >= 1024 && index < units.length - 1) {
        n /= 1024;
        index += 1;
    }
    const digits = index === 0 ? "0" : n >= 100 ? "0" : n >= 10 ? "1" : "2";
    const text = index === 0
        ? String(Math.round(n))
        : n
            .toFixed(Number(digits))
            .replace(/(\.\d*?[1-9])0+$/, "$1")
            .replace(/\.0+$/, "");
    return `${sign}${text}${units[index]}`;
}
export function formatDurationMs(ms) {
    if (!Number.isFinite(ms) || ms <= 0)
        return undefined;
    const totalSeconds = Math.round(ms / 1000);
    const days = Math.floor(totalSeconds / 86400);
    const hours = Math.floor((totalSeconds % 86400) / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    if (days > 0)
        return `${days}d ${hours}h`;
    if (hours > 0)
        return `${hours}h ${minutes}m`;
    if (minutes > 0)
        return `${minutes}m`;
    return `${totalSeconds}s`;
}
function pad2(value) {
    return String(value).padStart(2, "0");
}
export function formatLocalDateTime(ms) {
    if (!Number.isFinite(ms) || ms <= 0)
        return undefined;
    const date = new Date(ms);
    return [
        `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}`,
        `${pad2(date.getHours())}:${pad2(date.getMinutes())}:${pad2(date.getSeconds())}`
    ].join(" ");
}
export function formatReset(value) {
    const resetAtMs = value.resetAtMs;
    if (resetAtMs && Number.isFinite(resetAtMs) && resetAtMs > 0) {
        return formatLocalDateTime(resetAtMs);
    }
    const resetAfterMs = value.resetAfterMs;
    if (resetAfterMs && Number.isFinite(resetAfterMs) && resetAfterMs > 0) {
        const duration = formatDurationMs(resetAfterMs);
        return duration ? `in ${duration}` : undefined;
    }
    return undefined;
}
export function sanitizeDisplayText(value) {
    return value.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "").trimEnd();
}
export function truncateText(value, max = 160) {
    const cleaned = sanitizeDisplayText(value).replace(/\s+/g, " ").trim();
    if (cleaned.length <= max)
        return cleaned;
    return `${cleaned.slice(0, Math.max(0, max - 3))}...`;
}
export function basename(input) {
    if (!input)
        return undefined;
    const normalized = input.replace(/\\/g, "/").replace(/\/+$/, "");
    const last = normalized.split("/").filter(Boolean).pop();
    return last || undefined;
}
//# sourceMappingURL=format.js.map