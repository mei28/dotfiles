#!/usr/bin/env python3
"""
RunCat Neo — Claude Code statusLine sample.

Writes ~/.claude/runcat-usage.json shaped like:

    {
      "title": "Claude Code",
      "symbol": "staroflife",
      "metricsBarValue": "$1.23",
      "metrics": [
        {"title": "Model",   "formattedValue": "Opus 4.7"},
        {"title": "Context", "formattedValue": "67%", "normalizedValue": 0.67},
        {"title": "Today",   "formattedValue": "$1.23"},
        {"title": "Session", "formattedValue": "$0.23"},
        {"title": "5h",      "formattedValue": "3% · 2h13m",  "normalizedValue": 0.03},
        {"title": "7d",      "formattedValue": "3% · 4d6h",   "normalizedValue": 0.03}
      ],
      "lastUpdatedDate": "2026-06-07T05:55:36Z"
    }

Today's cost is computed locally from token usage (ccusage daily --offline --json)
priced at the Claude API tier each in-use model maps to. The model→tier mapping
mirrors the ANTHROPIC_DEFAULT_*_MODEL env vars that route Claude Code requests
to the internal GLM endpoint (glm-5.2-fp8→Opus, glm-5.2-nvfp4→Sonnet/Haiku), so
"what would this cost on Claude" stays consistent with what actually ran.
Session cost is read from the payload's cost.total_cost_usd directly.
"""

import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

OUT = Path(os.environ.get("RUNCAT_OUT_FILE", str(Path.home() / ".claude" / "runcat-usage.json")))
PRICE_CACHE = Path(os.environ.get("RUNCAT_PRICE_FILE", str(Path.home() / ".claude" / "runcat-prices.json")))
PRICING_URL = "https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching"
PRICE_TTL_SECONDS = 86400  # refresh once per day

# Tier in priority order. A proxy model backing several tiers (e.g. the same
# glm serving both Sonnet and Haiku) resolves to the first listed — the primary,
# heavier role, where the bulk of tokens actually run.
_TIER_PRIORITY = ["opus", "sonnet", "haiku", "fable"]
# Model name → tier keywords used to locate the right pricing-table row.
_TIER_KEYWORDS = {"opus": "opus", "sonnet": "sonnet", "haiku": "haiku", "fable": "fable"}


def _parse_price(cell):
    """'$6.25 / MTok' -> 6.25 (float). Raises ValueError on malformed input."""
    m = re.search(r"\$([0-9]+(?:\.[0-9]+)?)", cell)
    if not m:
        raise ValueError(f"unparseable price cell: {cell!r}")
    return float(m.group(1))


def _row_tier(model_cell):
    """Map a pricing-table 'Model' cell to a tier, skipping retired/unmatched rows."""
    low = model_cell.lower()
    if "retired" in low or "starting september" in low:
        return None
    for tier, kw in _TIER_KEYWORDS.items():
        if kw in low:
            return tier
    return None


def fetch_tiers():
    """Fetch Anthropic's prompt-caching pricing page and return a {tier: (in, out,
    cache_write_5m, cache_read)} dict. Raises on fetch or parse failure — no
    fallback, so a broken page surfaces immediately rather than billing silently
    with stale numbers."""
    req = urllib.request.Request(PRICING_URL, headers={"User-Agent": "runcat-statusline/1.0"})
    html = urllib.request.urlopen(req, timeout=10).read().decode("utf-8", "replace")
    tiers = {}
    # The page renders the pricing table as <tr><td>Model</td><td>$in / MTok</td>...
    # Columns: model, base input, 5m cache write, 1h cache write, cache read, output.
    for m in re.finditer(r"<tr[^>]*>(.*?)</tr>", html, re.DOTALL):
        cells = re.findall(r"<td[^>]*>(.*?)</td>", m.group(1), re.DOTALL)
        if len(cells) != 6:
            continue
        text = [re.sub(r"<[^>]+>", "", c).strip() for c in cells]
        tier = _row_tier(text[0])
        if tier is None or tier in tiers:
            continue
        tiers[tier] = (_parse_price(text[1]), _parse_price(text[5]), _parse_price(text[2]), _parse_price(text[4]))
    missing = [t for t in _TIER_PRIORITY if t not in tiers]
    if missing:
        raise ValueError(f"pricing page missing tiers: {missing}")
    return tiers


def load_tiers():
    """Return {tier: (in, out, cache_write_5m, cache_read)}, refreshing the on-disk
    cache when older than PRICE_TTL_SECONDS."""
    if PRICE_CACHE.exists():
        cache = json.loads(PRICE_CACHE.read_text(encoding="utf-8"))
        age = datetime.now(timezone.utc).timestamp() - cache.get("fetchedAt", 0)
        if age < PRICE_TTL_SECONDS and all(t in cache.get("tiers", {}) for t in _TIER_PRIORITY):
            return {t: tuple(cache["tiers"][t]) for t in _TIER_PRIORITY}
    tiers = fetch_tiers()
    payload = {"fetchedAt": int(datetime.now(timezone.utc).timestamp()), "tiers": {t: list(tiers[t]) for t in _TIER_PRIORITY}}
    PRICE_CACHE.parent.mkdir(parents=True, exist_ok=True)
    PRICE_CACHE.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
    return tiers


# Map each proxy model to its Claude tier from the ANTHROPIC_DEFAULT_<TIER>_MODEL
# env vars that route Claude Code requests to it (e.g. ANTHROPIC_DEFAULT_OPUS_MODEL
# =glm-5.2-fp8 -> Opus). Built once at import; unknown models fall through to the
# claude-* prefix table for direct-Claude usage where env is unset.
_MODEL_TIER = {}
for _t in _TIER_PRIORITY:
    _m = os.environ.get(f"ANTHROPIC_DEFAULT_{_t.upper()}_MODEL")
    if _m and _m not in _MODEL_TIER:
        _MODEL_TIER[_m] = _t

# Fallback for direct-Claude usage (env unset): recognize real model ids by prefix.
_CLAUDE_PREFIX_TIER = [
    ("claude-opus", "opus"),
    ("claude-sonnet", "sonnet"),
    ("claude-haiku", "haiku"),
    ("claude-fable", "fable"),
]


def tier_for(model_name):
    tier = _MODEL_TIER.get(model_name)
    if tier:
        return tier
    for prefix, t in _CLAUDE_PREFIX_TIER:
        if model_name.startswith(prefix):
            return t
    return None


def time_left(resets_at):
    """Unix epoch seconds -> "3d4h" / "2h13m" / "47m" ("0m" once the window has passed)."""
    if not isinstance(resets_at, (int, float)):
        return None
    minutes = int((resets_at - datetime.now(timezone.utc).timestamp()) // 60)
    if minutes <= 0:
        return "0m"
    hours, minutes = divmod(minutes, 60)
    days, hours = divmod(hours, 24)
    if days:
        return f"{days}d{hours}h"
    if hours:
        return f"{hours}h{minutes:02d}m"
    return f"{minutes}m"


def pct(title, value, resets_at=None):
    if value is None:
        return None
    left = time_left(resets_at)
    formatted = f"{value:g}%" if left is None else f"{value:g}% · {left}"
    return {"title": title, "formattedValue": formatted, "normalizedValue": round(value / 100, 4)}


def today_cost_local():
    """Sum today's token usage priced at the Claude API tier each model maps to.

    Reads ccusage daily --offline --json (local logs only, ~0.8s) and prices
    tokens at the live Anthropic rates (cached 24h). Returns a USD float, or
    None when today's usage data is empty / ccusage is unavailable.
    Raises on a price-fetch/parse failure so the status line surfaces it
    rather than billing silently with stale numbers.
    """
    tiers = load_tiers()
    try:
        out = subprocess.run(
            ["bun", "x", "ccusage@latest", "daily", "--offline", "--json"],
            capture_output=True, text=True, timeout=10,
        )
        daily = json.loads(out.stdout).get("daily", [])
    except (subprocess.SubprocessError, json.JSONDecodeError):
        return None
    today_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    total = 0.0
    for entry in daily:
        if entry.get("period") != today_str:
            continue
        for m in entry.get("modelBreakdowns", []):
            tier = tiers.get(tier_for(m.get("modelName", "")))
            if tier is None:
                continue
            in_p, out_p, cc_p, cr_p = tier
            total += m.get("inputTokens", 0) / 1e6 * in_p
            total += m.get("outputTokens", 0) / 1e6 * out_p
            total += m.get("cacheCreationTokens", 0) / 1e6 * cc_p
            total += m.get("cacheReadTokens", 0) / 1e6 * cr_p
    return total


try:
    payload = json.load(sys.stdin)
    if not isinstance(payload, dict):
        payload = {}
except Exception:
    payload = {}

model = (payload.get("model") or {}).get("display_name") or "Claude Code"
ctx = (payload.get("context_window") or {}).get("used_percentage")
rate_limits = payload.get("rate_limits") or {}
five_hour = rate_limits.get("five_hour") or {}
seven_day = rate_limits.get("seven_day") or {}

today_cost = None
today_cost_err = None
try:
    today_cost = today_cost_local()
except Exception as exc:  # price fetch/parse failure — surface, don't swallow
    today_cost_err = f"ERR:{type(exc).__name__}"
session_cost = (payload.get("cost") or {}).get("total_cost_usd")

snapshot = {
    "title": "Claude Code",
    "symbol": "staroflife",
    "metrics": [m for m in [
        {"title": "Model", "formattedValue": model},
        pct("Context", ctx),
        {"title": "Today", "formattedValue": today_cost_err or (f"${today_cost:.2f}" if today_cost is not None else None)} if (today_cost is not None or today_cost_err) else None,
        {"title": "Session", "formattedValue": f"${session_cost:.2f}"} if session_cost is not None else None,
        pct("5h", five_hour.get("used_percentage"), five_hour.get("resets_at")),
        pct("7d", seven_day.get("used_percentage"), seven_day.get("resets_at")),
    ] if m is not None],
    "lastUpdatedDate": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
bar = today_cost_err or (f"${today_cost:.2f}" if today_cost is not None else None) or (f"{ctx:g}%" if ctx is not None else None)
if bar is not None:
    snapshot["metricsBarValue"] = bar

OUT.parent.mkdir(parents=True, exist_ok=True)
fd, tmp = tempfile.mkstemp(prefix=".runcat-", dir=str(OUT.parent))
with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump(snapshot, f, ensure_ascii=False)
os.replace(tmp, OUT)

print(model)
