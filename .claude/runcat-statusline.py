#!/usr/bin/env python3
"""
RunCat Neo — Claude Code statusLine sample.

Writes ~/.claude/runcat-usage.json shaped like:

    {
      "title": "Claude Code",
      "symbol": "staroflife",
      "metricsBarValue": "67%",
      "metrics": [
        {"title": "Model",   "formattedValue": "Opus 4.7"},
        {"title": "Context", "formattedValue": "67%", "normalizedValue": 0.67},
        {"title": "5h",      "formattedValue": "3% · 2h13m",  "normalizedValue": 0.03},
        {"title": "7d",      "formattedValue": "3% · 4d6h",   "normalizedValue": 0.03}
      ],
      "lastUpdatedDate": "2026-06-07T05:55:36Z"
    }
"""

import json
import os
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

OUT = Path(os.environ.get("RUNCAT_OUT_FILE", str(Path.home() / ".claude" / "runcat-usage.json")))


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

snapshot = {
    "title": "Claude Code",
    "symbol": "staroflife",
    "metrics": [m for m in [
        {"title": "Model", "formattedValue": model},
        pct("Context", ctx),
        pct("5h", five_hour.get("used_percentage"), five_hour.get("resets_at")),
        pct("7d", seven_day.get("used_percentage"), seven_day.get("resets_at")),
    ] if m is not None],
    "lastUpdatedDate": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
if ctx is not None:
    snapshot["metricsBarValue"] = f"{ctx:g}%"

OUT.parent.mkdir(parents=True, exist_ok=True)
fd, tmp = tempfile.mkstemp(prefix=".runcat-", dir=str(OUT.parent))
with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump(snapshot, f, ensure_ascii=False)
os.replace(tmp, OUT)

print(model)
