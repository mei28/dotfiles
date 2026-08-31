import { use as _$use } from "@opentui/solid";
import { effect as _$effect } from "@opentui/solid";
import { insert as _$insert } from "@opentui/solid";
import { createTextNode as _$createTextNode } from "@opentui/solid";
import { insertNode as _$insertNode } from "@opentui/solid";
import { setProp as _$setProp } from "@opentui/solid";
import { createElement as _$createElement } from "@opentui/solid";
import { createComponent as _$createComponent } from "@opentui/solid";
/** @jsxImportSource @opentui/solid */
import { TextAttributes } from "@opentui/core";
import { useTerminalDimensions } from "@opentui/solid";
import { For, Show, createEffect, createMemo, createSignal, onCleanup } from "solid-js";
import { buildTuiStatuslineParts, invalidateGitDiffStatsCache } from "./lib/statusline.js";
import { buildTuiUsageText } from "./lib/tui-usage.js";
import { readRecentModelStateFromFile } from "./lib/opencode-client.js";
import { STATUSLINE_FIELDS, loadStatuslineConfig, saveStatuslineConfig, uniqueFields } from "./lib/statusline-config.js";
import { isRecord, sanitizeDisplayText, toNonEmptyString } from "./lib/format.js";
import { displayColumns, takeColumns } from "./lib/display-width.js";
import { DialogRequestLifecycle } from "./lib/dialog-lifecycle.js";
const id = "opencode-statusline";
const STATUSLINE_SLOT_ORDER = 95;
const MODEL_POLL_INTERVAL_MS = 2_000;
const FULL_REFRESH_INTERVAL_MS = 60_000;
const STATUSLINE_RENDER_TIMEOUT_MS = 4_000;
const EVENT_REFRESH_DELAYS_MS = [150, 600];
const MOUNT_RECOVERY_DELAYS_MS = [500, 1_500, 4_000];
const SESSION_SIDEBAR_WIDTH = 42;
const SESSION_HORIZONTAL_PADDING = 4;
const PROMPT_HORIZONTAL_PADDING = 4;
const PROMPT_LEFT_BORDER_WIDTH = 1;
const PROMPT_ROW_GAP = 1;
const RIGHT_CONTENT_GAP = 1;
const STATUSLINE_SAFETY_COLUMNS = 2;
const MIN_STATUSLINE_COLUMNS = 8;
const STATUSLINE_SEPARATOR = " | ";
const configListeners = new Set();
const usageDialogLifecycle = new DialogRequestLifecycle();
function notifyConfigChanged() {
  for (const listener of configListeners) listener();
}
function onConfigChanged(listener) {
  configListeners.add(listener);
  return () => configListeners.delete(listener);
}
function StatuslineDialog(props) {
  const [fields, setFields] = createSignal(props.initialFields ?? loadStatuslineConfig().fields);
  const toggle = field => {
    const current = fields();
    const next = current.includes(field) ? current.filter(item => item !== field) : [...current, field];
    const normalized = uniqueFields(next);
    setFields(normalized);
    saveStatuslineConfig({
      version: 1,
      fields: normalized
    });
    notifyConfigChanged();
    setTimeout(() => {
      props.api.ui.dialog.replace(() => _$createComponent(StatuslineDialog, {
        get api() {
          return props.api;
        },
        initialFields: normalized,
        current: field
      }));
    }, 0);
  };
  const options = () => STATUSLINE_FIELDS.map(field => {
    const index = fields().indexOf(field.id);
    const selected = index >= 0;
    return {
      title: `${selected ? "[x]" : "[ ]"} ${field.label}`,
      value: field.id,
      description: selected ? `#${index + 1} ${field.id}` : field.id,
      onSelect: () => toggle(field.id)
    };
  });
  return _$createComponent(props.api.ui.DialogSelect, {
    title: "Statusline fields",
    placeholder: "Search fields",
    get options() {
      return options();
    },
    skipFilter: false,
    get current() {
      return props.current;
    }
  });
}
function openStatuslineDialog(api) {
  api.ui.dialog.replace(() => _$createComponent(StatuslineDialog, {
    api: api
  }));
}
function currentSessionID(api) {
  const route = api.route.current;
  if (route.name !== "session") return undefined;
  return typeof route.params?.sessionID === "string" ? route.params.sessionID : undefined;
}
function usageRows(message) {
  return message.split("\n").filter((line, index) => !(index === 0 && line === "OpenCode Usage")).map(line => {
    if (!line.trim()) return {
      value: ""
    };
    const separator = line.indexOf(":");
    if (separator <= 0) return {
      value: line
    };
    return {
      label: line.slice(0, separator),
      value: line.slice(separator + 1).trim()
    };
  });
}
function closeUsageDialog(api) {
  if (!usageDialogLifecycle.cancel()) return;
  api.ui.dialog.clear();
}
function UsageDialog(props) {
  const theme = () => props.api.theme.current;
  const rows = createMemo(() => usageRows(props.message));
  return (() => {
    var _el$ = _$createElement("box"),
      _el$2 = _$createElement("box"),
      _el$3 = _$createElement("text"),
      _el$5 = _$createElement("text"),
      _el$7 = _$createElement("box"),
      _el$8 = _$createElement("box"),
      _el$9 = _$createElement("box"),
      _el$0 = _$createElement("text");
    _$insertNode(_el$, _el$2);
    _$insertNode(_el$, _el$7);
    _$insertNode(_el$, _el$8);
    _$setProp(_el$, "paddingLeft", 2);
    _$setProp(_el$, "paddingRight", 2);
    _$setProp(_el$, "gap", 1);
    _$insertNode(_el$2, _el$3);
    _$insertNode(_el$2, _el$5);
    _$setProp(_el$2, "flexDirection", "row");
    _$setProp(_el$2, "justifyContent", "space-between");
    _$insertNode(_el$3, _$createTextNode(`OpenCode Usage`));
    _$insertNode(_el$5, _$createTextNode(`esc`));
    _$setProp(_el$7, "gap", 0);
    _$setProp(_el$7, "paddingBottom", 1);
    _$insert(_el$7, _$createComponent(For, {
      get each() {
        return rows();
      },
      children: row => _$createComponent(Show, {
        get when() {
          return row.value;
        },
        get fallback() {
          return (() => {
            var _el$11 = _$createElement("box");
            _$setProp(_el$11, "height", 1);
            return _el$11;
          })();
        },
        get children() {
          var _el$10 = _$createElement("box");
          _$setProp(_el$10, "flexDirection", "row");
          _$setProp(_el$10, "gap", 1);
          _$setProp(_el$10, "width", "100%");
          _$insert(_el$10, _$createComponent(Show, {
            get when() {
              return row.label;
            },
            get fallback() {
              return (() => {
                var _el$12 = _$createElement("text");
                _$setProp(_el$12, "wrapMode", "word");
                _$setProp(_el$12, "width", "100%");
                _$insert(_el$12, () => row.value);
                _$effect(_$p => _$setProp(_el$12, "fg", theme().textMuted, _$p));
                return _el$12;
              })();
            },
            children: label => [(() => {
              var _el$13 = _$createElement("text");
              _$setProp(_el$13, "width", 16);
              _$setProp(_el$13, "flexShrink", 0);
              _$setProp(_el$13, "wrapMode", "none");
              _$insert(_el$13, label);
              _$effect(_$p => _$setProp(_el$13, "fg", theme().textMuted, _$p));
              return _el$13;
            })(), (() => {
              var _el$14 = _$createElement("text");
              _$setProp(_el$14, "wrapMode", "word");
              _$setProp(_el$14, "width", "100%");
              _$insert(_el$14, () => row.value);
              _$effect(_$p => _$setProp(_el$14, "fg", theme().text, _$p));
              return _el$14;
            })()]
          }));
          return _el$10;
        }
      })
    }));
    _$insertNode(_el$8, _el$9);
    _$setProp(_el$8, "flexDirection", "row");
    _$setProp(_el$8, "justifyContent", "flex-end");
    _$setProp(_el$8, "paddingBottom", 1);
    _$insertNode(_el$9, _el$0);
    _$setProp(_el$9, "paddingLeft", 3);
    _$setProp(_el$9, "paddingRight", 3);
    _$insertNode(_el$0, _$createTextNode(`ok`));
    _$effect(_p$ => {
      var _v$ = theme().text,
        _v$2 = TextAttributes.BOLD,
        _v$3 = theme().textMuted,
        _v$4 = props.onClose,
        _v$5 = theme().primary,
        _v$6 = props.onClose,
        _v$7 = theme().selectedListItemText;
      _v$ !== _p$.e && (_p$.e = _$setProp(_el$3, "fg", _v$, _p$.e));
      _v$2 !== _p$.t && (_p$.t = _$setProp(_el$3, "attributes", _v$2, _p$.t));
      _v$3 !== _p$.a && (_p$.a = _$setProp(_el$5, "fg", _v$3, _p$.a));
      _v$4 !== _p$.o && (_p$.o = _$setProp(_el$5, "onMouseUp", _v$4, _p$.o));
      _v$5 !== _p$.i && (_p$.i = _$setProp(_el$9, "backgroundColor", _v$5, _p$.i));
      _v$6 !== _p$.n && (_p$.n = _$setProp(_el$9, "onMouseUp", _v$6, _p$.n));
      _v$7 !== _p$.s && (_p$.s = _$setProp(_el$0, "fg", _v$7, _p$.s));
      return _p$;
    }, {
      e: undefined,
      t: undefined,
      a: undefined,
      o: undefined,
      i: undefined,
      n: undefined,
      s: undefined
    });
    return _el$;
  })();
}
function showUsageDialog(api, message, requestVersion) {
  const installed = usageDialogLifecycle.install(requestVersion, onClose => {
    api.ui.dialog.replace(() => _$createComponent(UsageDialog, {
      api: api,
      message: message,
      onClose: () => closeUsageDialog(api)
    }), onClose);
  });
  if (!installed) return;
  api.ui.dialog.setSize("large");
}
function openUsageDialog(api) {
  const sessionID = currentSessionID(api) ?? "";
  const notice = sessionID ? "" : "No open session: using configured or recent model.\n\n";
  const requestVersion = usageDialogLifecycle.begin();
  showUsageDialog(api, "Loading usage...", requestVersion);
  void buildTuiUsageText(api, sessionID).then(message => showUsageDialog(api, `${notice}${message}`, requestVersion)).catch(err => {
    const message = err instanceof Error && err.message ? err.message : "Could not load usage.";
    showUsageDialog(api, `Usage unavailable\n\n${message}`, requestVersion);
  });
}
function withTimeout(promise, ms) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => resolve(undefined), ms);
    promise.then(value => {
      clearTimeout(timer);
      resolve(value);
    }, error => {
      clearTimeout(timer);
      reject(error);
    });
  });
}
function statuslineSegments(parts) {
  const segments = [];
  for (const part of parts) {
    const text = sanitizeDisplayText(part.text).replace(/\s+/g, " ").trim();
    if (!text) continue;
    if (segments.length > 0) segments.push({
      text: STATUSLINE_SEPARATOR,
      separator: true
    });
    segments.push({
      field: part.field,
      text
    });
  }
  return segments;
}
function segmentsColumns(segments) {
  return segments.reduce((total, segment) => total + displayColumns(segment.text), 0);
}
function truncateStatuslineSegments(parts, maxColumns) {
  if (maxColumns < MIN_STATUSLINE_COLUMNS) return [];
  const segments = statuslineSegments(parts);
  if (segmentsColumns(segments) <= maxColumns) return segments;
  const suffix = "...";
  let remaining = maxColumns - displayColumns(suffix);
  const result = [];
  for (const segment of segments) {
    if (remaining <= 0) break;
    const width = displayColumns(segment.text);
    if (width <= remaining) {
      result.push(segment);
      remaining -= width;
      continue;
    }
    if (segment.separator) break;
    const text = takeColumns(segment.text, remaining);
    if (text) result.push({
      ...segment,
      text
    });
    break;
  }
  if (result.length === 0) return [];
  result.push({
    text: suffix,
    separator: true
  });
  return result;
}
function parseConfigModel(config) {
  if (!isRecord(config)) return {};
  const raw = toNonEmptyString(config.model);
  if (!raw) return {};
  const slash = raw.indexOf("/");
  if (slash <= 0) return {};
  return {
    providerID: raw.slice(0, slash),
    modelID: raw.slice(slash + 1) || undefined
  };
}
function modelFromSession(session) {
  if (!isRecord(session)) return {};
  const model = isRecord(session.model) ? session.model : undefined;
  return {
    providerID: toNonEmptyString(model?.providerID),
    modelID: toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id)
  };
}
function modelFromMessage(message) {
  if (!isRecord(message)) return {};
  const providerID = toNonEmptyString(message.providerID);
  const modelID = toNonEmptyString(message.modelID);
  if (providerID || modelID) return {
    providerID,
    modelID
  };
  const model = isRecord(message.model) ? message.model : undefined;
  return {
    providerID: toNonEmptyString(model?.providerID),
    modelID: toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id)
  };
}
function resolvePromptModel(api, sessionID) {
  const recent = readRecentModelStateFromFile(api.state.provider, api.state.path.state)?.model;
  if (recent) return recent;
  const sessionMeta = modelFromSession(api.state.session.get(sessionID));
  if (sessionMeta.providerID || sessionMeta.modelID) return sessionMeta;
  const messages = api.state.session.messages(sessionID);
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const meta = modelFromMessage(messages[index]);
    if (meta.providerID || meta.modelID) return meta;
  }
  return parseConfigModel(api.state.config);
}
function titleCase(value) {
  return value ? `${value[0]?.toUpperCase() ?? ""}${value.slice(1)}` : value;
}
function promptAgentLabel(api, sessionID) {
  const session = api.state.session.get(sessionID);
  if (!isRecord(session)) return "Build";
  const sessionRecord = session;
  return titleCase(toNonEmptyString(sessionRecord.agent) ?? toNonEmptyString(sessionRecord.mode) ?? "build");
}
function providerModelName(provider, modelID) {
  if (!modelID) return undefined;
  if (!provider || !isRecord(provider.models)) return modelID;
  const model = provider.models[modelID];
  return isRecord(model) ? toNonEmptyString(model.name) ?? modelID : modelID;
}
function promptVariantLabel(api, sessionID) {
  const messages = api.state.session.messages(sessionID);
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = messages[index];
    if (!isRecord(message) || message.role !== "user") continue;
    const model = isRecord(message.model) ? message.model : undefined;
    return toNonEmptyString(model?.variant) ?? toNonEmptyString(message.variant);
  }
  return undefined;
}
function estimatePromptLeftColumns(api, sessionID) {
  const meta = resolvePromptModel(api, sessionID);
  const provider = api.state.provider.find(item => item.id === meta.providerID);
  const variant = promptVariantLabel(api, sessionID);
  const parts = [promptAgentLabel(api, sessionID), "auto", meta.providerID || meta.modelID ? "·" : undefined, providerModelName(provider, meta.modelID), toNonEmptyString(provider?.name) ?? meta.providerID, variant ? "·" : undefined, variant].filter(part => Boolean(part));
  const textColumns = parts.reduce((total, part) => total + displayColumns(part), 0);
  const gapColumns = Math.max(0, parts.length - 1);
  return textColumns + gapColumns;
}
function estimatePromptInnerColumns(api, sessionID, terminalColumns) {
  const session = api.state.session.get(sessionID);
  const isSubagent = isRecord(session) && Boolean(toNonEmptyString(session.parentID));
  const sidebarMode = api.kv.get("sidebar", "auto");
  const sidebarVisible = !isSubagent && sidebarMode !== "hide" && terminalColumns > 120;
  return Math.max(0, terminalColumns - (sidebarVisible ? SESSION_SIDEBAR_WIDTH : 0) - SESSION_HORIZONTAL_PADDING - PROMPT_HORIZONTAL_PADDING - PROMPT_LEFT_BORDER_WIDTH);
}
function statuslineColumnsBudget(input) {
  const promptColumns = estimatePromptInnerColumns(input.api, input.sessionID, input.terminalColumns);
  const leftColumns = estimatePromptLeftColumns(input.api, input.sessionID);
  const rightSlotColumns = Math.max(0, Math.ceil(input.rightSlotColumns));
  const rightGap = rightSlotColumns > 0 ? RIGHT_CONTENT_GAP : 0;
  return Math.max(0, promptColumns - leftColumns - rightSlotColumns - rightGap - PROMPT_ROW_GAP - STATUSLINE_SAFETY_COLUMNS);
}
function statuslineSegmentColor(theme, segment) {
  if (segment.separator || !segment.field) return theme.textMuted;
  switch (segment.field) {
    case "repo":
      return theme.text;
    case "branch":
      return theme.info;
    case "git_diff_stats":
      return theme.warning;
    case "context_used":
      return theme.accent;
    case "context_remaining":
      return theme.success;
    case "context_length":
      return theme.secondary;
    case "context_window":
      return theme.accent;
    case "generation_metrics":
      return theme.info;
    case "subagent_status":
      return theme.primary;
    case "agent_status":
      return theme.primary;
    case "quota_5h":
      return theme.warning;
    case "quota_weekly":
      return theme.warning;
    case "provider_balance":
      return theme.success;
    case "session_io":
      return theme.secondary;
    case "session_total":
      return theme.secondary;
    case "session_cost":
      return theme.success;
    default:
      return theme.textMuted;
  }
}
function eventSessionID(event) {
  if (!isRecord(event)) return undefined;
  const properties = isRecord(event.properties) ? event.properties : undefined;
  if (!properties) return undefined;
  const info = isRecord(properties.info) ? properties.info : undefined;
  const part = isRecord(properties.part) ? properties.part : undefined;
  return toNonEmptyString(properties.sessionID) ?? toNonEmptyString(info?.id) ?? toNonEmptyString(info?.sessionID) ?? toNonEmptyString(part?.sessionID);
}
function eventMatchesSession(event, sessionID) {
  return eventSessionID(event) === sessionID;
}
function StatuslineView(props) {
  const [parts, setParts] = createSignal([]);
  const [layoutVersion, setLayoutVersion] = createSignal(0);
  const dimensions = useTerminalDimensions();
  const maxWidth = createMemo(() => {
    layoutVersion();
    return statuslineColumnsBudget({
      api: props.api,
      sessionID: props.sessionID,
      terminalColumns: dimensions().width,
      rightSlotColumns: props.rightSlotColumns
    });
  });
  const displaySegments = createMemo(() => truncateStatuslineSegments(parts(), maxWidth()));
  const displayWidth = createMemo(() => segmentsColumns(displaySegments()));
  const timers = new Set();
  let disposed = false;
  let version = 0;
  let inFlight = false;
  let pendingReload = false;
  const queuedReloadTimers = new Map();
  let lastRecentModelKey = "";
  const recentModelKey = () => {
    const recent = readRecentModelStateFromFile(props.api.state.provider, props.api.state.path.state);
    return recent ? `${recent.mtimeMs}:${recent.model.providerID}/${recent.model.modelID ?? ""}` : "";
  };
  const reload = () => {
    if (disposed) return;
    if (inFlight) {
      pendingReload = true;
      return;
    }
    inFlight = true;
    pendingReload = false;
    lastRecentModelKey = recentModelKey();
    const currentVersion = ++version;
    void withTimeout(buildTuiStatuslineParts(props.api, props.sessionID), STATUSLINE_RENDER_TIMEOUT_MS).then(next => {
      if (disposed || currentVersion !== version || !next) return;
      setParts(next);
    }).catch(() => {
      if (disposed || currentVersion !== version) return;
      setParts([{
        text: "statusline error"
      }]);
    }).finally(() => {
      inFlight = false;
      if (disposed || !pendingReload) return;
      pendingReload = false;
      scheduleRefresh();
    });
  };
  const queueReload = delay => {
    if (queuedReloadTimers.has(delay)) return;
    const timer = setTimeout(() => {
      queuedReloadTimers.delete(delay);
      timers.delete(timer);
      reload();
    }, delay);
    queuedReloadTimers.set(delay, timer);
    timers.add(timer);
  };
  const scheduleRefresh = () => {
    for (const delay of EVENT_REFRESH_DELAYS_MS) queueReload(delay);
  };
  const scheduleMountRecovery = () => {
    for (const delay of MOUNT_RECOVERY_DELAYS_MS) queueReload(delay);
  };
  const pollRecentModel = () => {
    if (disposed) return;
    const next = recentModelKey();
    if (next === lastRecentModelKey) return;
    reload();
  };
  createEffect(reload);
  scheduleMountRecovery();
  const fullRefreshInterval = setInterval(reload, FULL_REFRESH_INTERVAL_MS);
  const modelPollInterval = setInterval(pollRecentModel, MODEL_POLL_INTERVAL_MS);
  const unsubscribers = [onConfigChanged(scheduleRefresh), props.api.event.on("session.updated", event => {
    if (eventMatchesSession(event, props.sessionID)) {
      invalidateGitDiffStatsCache();
      scheduleRefresh();
    }
  }), props.api.event.on("session.status", event => {
    if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
  }), props.api.event.on("session.idle", event => {
    if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
  }), props.api.event.on("message.updated", event => {
    if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
  }), props.api.event.on("message.removed", event => {
    if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
  }), props.api.event.on("tui.session.select", event => {
    if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
  }), props.api.event.on("tui.command.execute", event => {
    if (event.properties?.command !== "session.sidebar.toggle") return;
    setTimeout(() => {
      if (!disposed) setLayoutVersion(value => value + 1);
    }, 0);
  })];
  onCleanup(() => {
    disposed = true;
    clearInterval(fullRefreshInterval);
    clearInterval(modelPollInterval);
    for (const timer of timers) clearTimeout(timer);
    for (const unsubscribe of unsubscribers) unsubscribe();
  });
  return _$createComponent(Show, {
    get when() {
      return displaySegments().length;
    },
    get children() {
      var _el$15 = _$createElement("box");
      _$setProp(_el$15, "flexShrink", 0);
      _$setProp(_el$15, "flexDirection", "row");
      _$insert(_el$15, _$createComponent(For, {
        get each() {
          return displaySegments();
        },
        children: segment => (() => {
          var _el$16 = _$createElement("text");
          _$setProp(_el$16, "wrapMode", "none");
          _$setProp(_el$16, "flexShrink", 0);
          _$insert(_el$16, () => segment.text);
          _$effect(_p$ => {
            var _v$8 = statuslineSegmentColor(props.api.theme.current, segment),
              _v$9 = displayColumns(segment.text);
            _v$8 !== _p$.e && (_p$.e = _$setProp(_el$16, "fg", _v$8, _p$.e));
            _v$9 !== _p$.t && (_p$.t = _$setProp(_el$16, "width", _v$9, _p$.t));
            return _p$;
          }, {
            e: undefined,
            t: undefined
          });
          return _el$16;
        })()
      }));
      _$effect(_$p => _$setProp(_el$15, "width", displayWidth(), _$p));
      return _el$15;
    }
  });
}
function PromptRightContent(props) {
  const [rightSlotColumns, setRightSlotColumns] = createSignal(0);
  const recordRightSlotWidth = node => {
    const width = node?.width ?? 0;
    setRightSlotColumns(current => current === width ? current : width);
  };
  return (() => {
    var _el$17 = _$createElement("box"),
      _el$18 = _$createElement("box");
    _$insertNode(_el$17, _el$18);
    _$setProp(_el$17, "flexDirection", "row");
    _$setProp(_el$17, "gap", 1);
    _$setProp(_el$17, "alignItems", "center");
    _$setProp(_el$17, "flexShrink", 0);
    _$insert(_el$17, _$createComponent(StatuslineView, {
      get api() {
        return props.api;
      },
      get sessionID() {
        return props.sessionID;
      },
      get rightSlotColumns() {
        return rightSlotColumns();
      }
    }), _el$18);
    _$use(node => recordRightSlotWidth(node), _el$18);
    _$setProp(_el$18, "flexDirection", "row");
    _$setProp(_el$18, "gap", 1);
    _$setProp(_el$18, "flexShrink", 0);
    _$setProp(_el$18, "onSizeChange", function () {
      recordRightSlotWidth(this);
    });
    _$insert(_el$18, _$createComponent(props.api.ui.Slot, {
      name: "session_prompt_right",
      get session_id() {
        return props.sessionID;
      }
    }));
    return _el$17;
  })();
}
function PromptWithInlineStatusline(props) {
  return _$createComponent(props.api.ui.Prompt, {
    get sessionID() {
      return props.prompt.session_id;
    },
    get visible() {
      return props.prompt.visible;
    },
    get disabled() {
      return props.prompt.disabled;
    },
    get onSubmit() {
      return props.prompt.on_submit;
    },
    ref(r$) {
      var _ref$ = props.prompt.ref;
      typeof _ref$ === "function" ? _ref$(r$) : props.prompt.ref = r$;
    },
    get right() {
      return _$createComponent(PromptRightContent, {
        get api() {
          return props.api;
        },
        get sessionID() {
          return props.prompt.session_id;
        }
      });
    }
  });
}
const tui = async api => {
  api.slots.register({
    order: STATUSLINE_SLOT_ORDER,
    slots: {
      session_prompt(_ctx, props) {
        return _$createComponent(PromptWithInlineStatusline, {
          api: api,
          prompt: props
        });
      }
    }
  });
  api.keymap.registerLayer({
    commands: [{
      namespace: "palette",
      name: "opencode-statusline.usage",
      title: "Provider usage",
      desc: "Show current provider usage without adding it to model context",
      category: "System",
      slashName: "usage",
      run() {
        openUsageDialog(api);
      }
    }, {
      namespace: "dialog",
      name: "opencode-statusline.usage.close",
      title: "Close usage dialog",
      hidden: true,
      enabled: () => usageDialogLifecycle.isOpen(),
      run() {
        closeUsageDialog(api);
      }
    }, {
      namespace: "palette",
      name: "opencode-statusline.configure",
      title: "Statusline fields",
      desc: "Configure prompt statusline fields",
      category: "System",
      slashName: "statusline",
      run() {
        openStatuslineDialog(api);
      }
    }],
    bindings: [{
      key: "return",
      desc: "Close usage dialog",
      group: "Dialog",
      cmd: "opencode-statusline.usage.close"
    }]
  });
};
const pluginModule = {
  id,
  tui
};
export default pluginModule;
