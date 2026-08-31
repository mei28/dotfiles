/** @jsxImportSource @opentui/solid */
import { TextAttributes, type BoxRenderable } from "@opentui/core";
import type { JSX } from "@opentui/solid";
import { useTerminalDimensions } from "@opentui/solid";
import type { TuiPlugin, TuiPluginApi, TuiPluginModule, TuiPromptRef } from "@opencode-ai/plugin/tui";
import { For, Show, createEffect, createMemo, createSignal, onCleanup } from "solid-js";
import { buildTuiStatuslineParts, invalidateGitDiffStatsCache } from "./lib/statusline.js";
import { buildTuiUsageText } from "./lib/tui-usage.js";
import { readRecentModelStateFromFile } from "./lib/opencode-client.js";
import type { ProviderInfoLike } from "./lib/providers.js";
import {
  STATUSLINE_FIELDS,
  loadStatuslineConfig,
  saveStatuslineConfig,
  uniqueFields,
  type StatuslineFieldID
} from "./lib/statusline-config.js";
import { isRecord, sanitizeDisplayText, toNonEmptyString } from "./lib/format.js";
import { displayColumns, takeColumns } from "./lib/display-width.js";
import { DialogRequestLifecycle } from "./lib/dialog-lifecycle.js";

const id = "opencode-statusline";
const STATUSLINE_SLOT_ORDER = 95;
const MODEL_POLL_INTERVAL_MS = 2_000;
const FULL_REFRESH_INTERVAL_MS = 60_000;
const STATUSLINE_RENDER_TIMEOUT_MS = 4_000;
const EVENT_REFRESH_DELAYS_MS = [150, 600] as const;
const MOUNT_RECOVERY_DELAYS_MS = [500, 1_500, 4_000] as const;
const SESSION_SIDEBAR_WIDTH = 42;
const SESSION_HORIZONTAL_PADDING = 4;
const PROMPT_HORIZONTAL_PADDING = 4;
const PROMPT_LEFT_BORDER_WIDTH = 1;
const PROMPT_ROW_GAP = 1;
const RIGHT_CONTENT_GAP = 1;
const STATUSLINE_SAFETY_COLUMNS = 2;
const MIN_STATUSLINE_COLUMNS = 8;
const STATUSLINE_SEPARATOR = " | ";
const configListeners = new Set<() => void>();
const usageDialogLifecycle = new DialogRequestLifecycle();

function notifyConfigChanged(): void {
  for (const listener of configListeners) listener();
}

function onConfigChanged(listener: () => void): () => void {
  configListeners.add(listener);
  return () => configListeners.delete(listener);
}

function StatuslineDialog(props: {
  api: TuiPluginApi;
  initialFields?: StatuslineFieldID[];
  current?: StatuslineFieldID;
}): JSX.Element {
  const [fields, setFields] = createSignal<StatuslineFieldID[]>(props.initialFields ?? loadStatuslineConfig().fields);

  const toggle = (field: StatuslineFieldID) => {
    const current = fields();
    const next = current.includes(field)
      ? current.filter((item) => item !== field)
      : [...current, field];
    const normalized = uniqueFields(next);
    setFields(normalized);
    saveStatuslineConfig({ version: 1, fields: normalized });
    notifyConfigChanged();
    setTimeout(() => {
      props.api.ui.dialog.replace(() => <StatuslineDialog api={props.api} initialFields={normalized} current={field} />);
    }, 0);
  };

  const options = () =>
    STATUSLINE_FIELDS.map((field) => {
      const index = fields().indexOf(field.id);
      const selected = index >= 0;
      return {
        title: `${selected ? "[x]" : "[ ]"} ${field.label}`,
        value: field.id,
        description: selected ? `#${index + 1} ${field.id}` : field.id,
        onSelect: () => toggle(field.id)
      };
    });

  return (
    <props.api.ui.DialogSelect
      title="Statusline fields"
      placeholder="Search fields"
      options={options()}
      skipFilter={false}
      current={props.current}
    />
  );
}

function openStatuslineDialog(api: TuiPluginApi): void {
  api.ui.dialog.replace(() => <StatuslineDialog api={api} />);
}

function currentSessionID(api: TuiPluginApi): string | undefined {
  const route = api.route.current;
  if (route.name !== "session") return undefined;
  return typeof route.params?.sessionID === "string" ? route.params.sessionID : undefined;
}

function usageRows(message: string): Array<{ label?: string; value: string }> {
  return message
    .split("\n")
    .filter((line, index) => !(index === 0 && line === "OpenCode Usage"))
    .map((line) => {
      if (!line.trim()) return { value: "" };
      const separator = line.indexOf(":");
      if (separator <= 0) return { value: line };
      return {
        label: line.slice(0, separator),
        value: line.slice(separator + 1).trim()
      };
    });
}

function closeUsageDialog(api: TuiPluginApi): void {
  if (!usageDialogLifecycle.cancel()) return;
  api.ui.dialog.clear();
}

function UsageDialog(props: { api: TuiPluginApi; message: string; onClose: () => void }): JSX.Element {
  const theme = () => props.api.theme.current;
  const rows = createMemo(() => usageRows(props.message));
  return (
    <box paddingLeft={2} paddingRight={2} gap={1}>
      <box flexDirection="row" justifyContent="space-between">
        <text fg={theme().text} attributes={TextAttributes.BOLD}>
          OpenCode Usage
        </text>
        <text fg={theme().textMuted} onMouseUp={props.onClose}>
          esc
        </text>
      </box>
      <box gap={0} paddingBottom={1}>
        <For each={rows()}>
          {(row) => (
            <Show
              when={row.value}
              fallback={<box height={1} />}
            >
              <box flexDirection="row" gap={1} width="100%">
                <Show when={row.label} fallback={<text fg={theme().textMuted} wrapMode="word" width="100%">{row.value}</text>}>
                  {(label) => (
                    <>
                      <text fg={theme().textMuted} width={16} flexShrink={0} wrapMode="none">
                        {label()}
                      </text>
                      <text fg={theme().text} wrapMode="word" width="100%">
                        {row.value}
                      </text>
                    </>
                  )}
                </Show>
              </box>
            </Show>
          )}
        </For>
      </box>
      <box flexDirection="row" justifyContent="flex-end" paddingBottom={1}>
        <box
          paddingLeft={3}
          paddingRight={3}
          backgroundColor={theme().primary}
          onMouseUp={props.onClose}
        >
          <text fg={theme().selectedListItemText}>ok</text>
        </box>
      </box>
    </box>
  );
}

function showUsageDialog(api: TuiPluginApi, message: string, requestVersion: number): void {
  const installed = usageDialogLifecycle.install(requestVersion, (onClose) => {
    api.ui.dialog.replace(
      () => <UsageDialog api={api} message={message} onClose={() => closeUsageDialog(api)} />,
      onClose
    );
  });
  if (!installed) return;
  api.ui.dialog.setSize("large");
}

function openUsageDialog(api: TuiPluginApi): void {
  const sessionID = currentSessionID(api) ?? "";
  const notice = sessionID ? "" : "No open session: using configured or recent model.\n\n";
  const requestVersion = usageDialogLifecycle.begin();
  showUsageDialog(api, "Loading usage...", requestVersion);
  void buildTuiUsageText(api, sessionID)
    .then((message) => showUsageDialog(api, `${notice}${message}`, requestVersion))
    .catch((err) => {
      const message = err instanceof Error && err.message ? err.message : "Could not load usage.";
      showUsageDialog(api, `Usage unavailable\n\n${message}`, requestVersion);
    });
}

type PromptModelMeta = {
  providerID?: string;
  modelID?: string;
};

type StatuslineDisplayPart = {
  field?: StatuslineFieldID;
  text: string;
};

type StatuslineSegment = StatuslineDisplayPart & {
  separator?: boolean;
};

type PromptSlotProps = {
  session_id: string;
  visible?: boolean;
  disabled?: boolean;
  on_submit?: () => void;
  ref?: (ref: TuiPromptRef | undefined) => void;
};

function withTimeout<Value>(promise: Promise<Value>, ms: number): Promise<Value | undefined> {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => resolve(undefined), ms);
    promise.then(
      (value) => {
        clearTimeout(timer);
        resolve(value);
      },
      (error) => {
        clearTimeout(timer);
        reject(error);
      }
    );
  });
}

function statuslineSegments(parts: readonly StatuslineDisplayPart[]): StatuslineSegment[] {
  const segments: StatuslineSegment[] = [];
  for (const part of parts) {
    const text = sanitizeDisplayText(part.text).replace(/\s+/g, " ").trim();
    if (!text) continue;
    if (segments.length > 0) segments.push({ text: STATUSLINE_SEPARATOR, separator: true });
    segments.push({ field: part.field, text });
  }
  return segments;
}

function segmentsColumns(segments: readonly StatuslineSegment[]): number {
  return segments.reduce((total, segment) => total + displayColumns(segment.text), 0);
}

function truncateStatuslineSegments(parts: readonly StatuslineDisplayPart[], maxColumns: number): StatuslineSegment[] {
  if (maxColumns < MIN_STATUSLINE_COLUMNS) return [];
  const segments = statuslineSegments(parts);
  if (segmentsColumns(segments) <= maxColumns) return segments;

  const suffix = "...";
  let remaining = maxColumns - displayColumns(suffix);
  const result: StatuslineSegment[] = [];
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
    if (text) result.push({ ...segment, text });
    break;
  }

  if (result.length === 0) return [];
  result.push({ text: suffix, separator: true });
  return result;
}

function parseConfigModel(config: unknown): PromptModelMeta {
  if (!isRecord(config)) return {};
  const raw = toNonEmptyString(config.model);
  if (!raw) return {};
  const slash = raw.indexOf("/");
  if (slash <= 0) return {};
  return { providerID: raw.slice(0, slash), modelID: raw.slice(slash + 1) || undefined };
}

function modelFromSession(session: unknown): PromptModelMeta {
  if (!isRecord(session)) return {};
  const model = isRecord(session.model) ? session.model : undefined;
  return {
    providerID: toNonEmptyString(model?.providerID),
    modelID: toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id)
  };
}

function modelFromMessage(message: unknown): PromptModelMeta {
  if (!isRecord(message)) return {};
  const providerID = toNonEmptyString(message.providerID);
  const modelID = toNonEmptyString(message.modelID);
  if (providerID || modelID) return { providerID, modelID };
  const model = isRecord(message.model) ? message.model : undefined;
  return {
    providerID: toNonEmptyString(model?.providerID),
    modelID: toNonEmptyString(model?.modelID) ?? toNonEmptyString(model?.id)
  };
}

function resolvePromptModel(api: TuiPluginApi, sessionID: string): PromptModelMeta {
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

function titleCase(value: string): string {
  return value ? `${value[0]?.toUpperCase() ?? ""}${value.slice(1)}` : value;
}

function promptAgentLabel(api: TuiPluginApi, sessionID: string): string {
  const session = api.state.session.get(sessionID);
  if (!isRecord(session)) return "Build";
  const sessionRecord = session as Record<string, unknown>;
  return titleCase(
    toNonEmptyString(sessionRecord.agent)
      ?? toNonEmptyString(sessionRecord.mode)
      ?? "build"
  );
}

function providerModelName(provider: ProviderInfoLike | undefined, modelID: string | undefined): string | undefined {
  if (!modelID) return undefined;
  if (!provider || !isRecord(provider.models)) return modelID;
  const model = provider.models[modelID];
  return isRecord(model) ? toNonEmptyString(model.name) ?? modelID : modelID;
}

function promptVariantLabel(api: TuiPluginApi, sessionID: string): string | undefined {
  const messages = api.state.session.messages(sessionID);
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = messages[index];
    if (!isRecord(message) || message.role !== "user") continue;
    const model = isRecord(message.model) ? message.model : undefined;
    return toNonEmptyString(model?.variant)
      ?? toNonEmptyString((message as unknown as Record<string, unknown>).variant);
  }
  return undefined;
}

function estimatePromptLeftColumns(api: TuiPluginApi, sessionID: string): number {
  const meta = resolvePromptModel(api, sessionID);
  const provider = api.state.provider.find((item) => item.id === meta.providerID);
  const variant = promptVariantLabel(api, sessionID);
  const parts = [
    promptAgentLabel(api, sessionID),
    "auto",
    meta.providerID || meta.modelID ? "·" : undefined,
    providerModelName(provider, meta.modelID),
    toNonEmptyString(provider?.name) ?? meta.providerID,
    variant ? "·" : undefined,
    variant
  ].filter((part): part is string => Boolean(part));

  const textColumns = parts.reduce((total, part) => total + displayColumns(part), 0);
  const gapColumns = Math.max(0, parts.length - 1);
  return textColumns + gapColumns;
}

function estimatePromptInnerColumns(api: TuiPluginApi, sessionID: string, terminalColumns: number): number {
  const session = api.state.session.get(sessionID);
  const isSubagent = isRecord(session) && Boolean(toNonEmptyString(session.parentID));
  const sidebarMode = api.kv.get<"auto" | "hide">("sidebar", "auto");
  const sidebarVisible = !isSubagent && sidebarMode !== "hide" && terminalColumns > 120;
  return Math.max(
    0,
    terminalColumns
      - (sidebarVisible ? SESSION_SIDEBAR_WIDTH : 0)
      - SESSION_HORIZONTAL_PADDING
      - PROMPT_HORIZONTAL_PADDING
      - PROMPT_LEFT_BORDER_WIDTH
  );
}

function statuslineColumnsBudget(input: {
  api: TuiPluginApi;
  sessionID: string;
  terminalColumns: number;
  rightSlotColumns: number;
}): number {
  const promptColumns = estimatePromptInnerColumns(input.api, input.sessionID, input.terminalColumns);
  const leftColumns = estimatePromptLeftColumns(input.api, input.sessionID);
  const rightSlotColumns = Math.max(0, Math.ceil(input.rightSlotColumns));
  const rightGap = rightSlotColumns > 0 ? RIGHT_CONTENT_GAP : 0;
  return Math.max(
    0,
    promptColumns
      - leftColumns
      - rightSlotColumns
      - rightGap
      - PROMPT_ROW_GAP
      - STATUSLINE_SAFETY_COLUMNS
  );
}

function statuslineSegmentColor(theme: TuiPluginApi["theme"]["current"], segment: StatuslineSegment) {
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

function eventSessionID(event: unknown): string | undefined {
  if (!isRecord(event)) return undefined;
  const properties = isRecord(event.properties) ? event.properties : undefined;
  if (!properties) return undefined;
  const info = isRecord(properties.info) ? properties.info : undefined;
  const part = isRecord(properties.part) ? properties.part : undefined;
  return toNonEmptyString(properties.sessionID)
    ?? toNonEmptyString(info?.id)
    ?? toNonEmptyString(info?.sessionID)
    ?? toNonEmptyString(part?.sessionID);
}

function eventMatchesSession(event: unknown, sessionID: string): boolean {
  return eventSessionID(event) === sessionID;
}

function StatuslineView(props: {
  api: TuiPluginApi;
  sessionID: string;
  rightSlotColumns: number;
}): JSX.Element {
  const [parts, setParts] = createSignal<StatuslineDisplayPart[]>([]);
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
  const timers = new Set<ReturnType<typeof setTimeout>>();
  let disposed = false;
  let version = 0;
  let inFlight = false;
  let pendingReload = false;
  const queuedReloadTimers = new Map<number, ReturnType<typeof setTimeout>>();
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
    void withTimeout(buildTuiStatuslineParts(props.api, props.sessionID), STATUSLINE_RENDER_TIMEOUT_MS)
      .then((next) => {
        if (disposed || currentVersion !== version || !next) return;
        setParts(next);
      })
      .catch(() => {
        if (disposed || currentVersion !== version) return;
        setParts([{ text: "statusline error" }]);
      })
      .finally(() => {
        inFlight = false;
        if (disposed || !pendingReload) return;
        pendingReload = false;
        scheduleRefresh();
      });
  };

  const queueReload = (delay: number) => {
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
  const unsubscribers = [
    onConfigChanged(scheduleRefresh),
    props.api.event.on("session.updated", (event) => {
      if (eventMatchesSession(event, props.sessionID)) {
        invalidateGitDiffStatsCache();
        scheduleRefresh();
      }
    }),
    props.api.event.on("session.status", (event) => {
      if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
    }),
    props.api.event.on("session.idle", (event) => {
      if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
    }),
    props.api.event.on("message.updated", (event) => {
      if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
    }),
    props.api.event.on("message.removed", (event) => {
      if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
    }),
    props.api.event.on("tui.session.select", (event) => {
      if (eventMatchesSession(event, props.sessionID)) scheduleRefresh();
    }),
    props.api.event.on("tui.command.execute", (event) => {
      if ((event as any).properties?.command !== "session.sidebar.toggle") return;
      setTimeout(() => {
        if (!disposed) setLayoutVersion((value) => value + 1);
      }, 0);
    })
  ];

  onCleanup(() => {
    disposed = true;
    clearInterval(fullRefreshInterval);
    clearInterval(modelPollInterval);
    for (const timer of timers) clearTimeout(timer);
    for (const unsubscribe of unsubscribers) unsubscribe();
  });

  return (
    <Show when={displaySegments().length}>
      <box width={displayWidth()} flexShrink={0} flexDirection="row">
        <For each={displaySegments()}>
          {(segment) => (
            <text
              fg={statuslineSegmentColor(props.api.theme.current, segment)}
              wrapMode="none"
              width={displayColumns(segment.text)}
              flexShrink={0}
            >
              {segment.text}
            </text>
          )}
        </For>
      </box>
    </Show>
  );
}

function PromptRightContent(props: { api: TuiPluginApi; sessionID: string }): JSX.Element {
  const [rightSlotColumns, setRightSlotColumns] = createSignal(0);

  const recordRightSlotWidth = (node: BoxRenderable | undefined) => {
    const width = node?.width ?? 0;
    setRightSlotColumns((current) => (current === width ? current : width));
  };

  return (
    <box flexDirection="row" gap={1} alignItems="center" flexShrink={0}>
      <StatuslineView api={props.api} sessionID={props.sessionID} rightSlotColumns={rightSlotColumns()} />
      <box
        flexDirection="row"
        gap={1}
        flexShrink={0}
        ref={(node: BoxRenderable) => recordRightSlotWidth(node)}
        onSizeChange={function (this: BoxRenderable) {
          recordRightSlotWidth(this);
        }}
      >
        <props.api.ui.Slot name="session_prompt_right" session_id={props.sessionID} />
      </box>
    </box>
  );
}

function PromptWithInlineStatusline(props: {
  api: TuiPluginApi;
  prompt: PromptSlotProps;
}): JSX.Element {
  return (
    <props.api.ui.Prompt
      sessionID={props.prompt.session_id}
      visible={props.prompt.visible}
      disabled={props.prompt.disabled}
      onSubmit={props.prompt.on_submit}
      ref={props.prompt.ref as any}
      right={<PromptRightContent api={props.api} sessionID={props.prompt.session_id} />}
    />
  );
}

const tui: TuiPlugin = async (api) => {
  api.slots.register({
    order: STATUSLINE_SLOT_ORDER,
    slots: {
      session_prompt(_ctx, props: PromptSlotProps) {
        return <PromptWithInlineStatusline api={api} prompt={props} />;
      }
    }
  });

  api.keymap.registerLayer({
    commands: [
      {
        namespace: "palette",
        name: "opencode-statusline.usage",
        title: "Provider usage",
        desc: "Show current provider usage without adding it to model context",
        category: "System",
        slashName: "usage",
        run() {
          openUsageDialog(api);
        }
      },
      {
        namespace: "dialog",
        name: "opencode-statusline.usage.close",
        title: "Close usage dialog",
        hidden: true,
        enabled: () => usageDialogLifecycle.isOpen(),
        run() {
          closeUsageDialog(api);
        }
      },
      {
        namespace: "palette",
        name: "opencode-statusline.configure",
        title: "Statusline fields",
        desc: "Configure prompt statusline fields",
        category: "System",
        slashName: "statusline",
        run() {
          openStatuslineDialog(api);
        }
      }
    ],
    bindings: [
      {
        key: "return",
        desc: "Close usage dialog",
        group: "Dialog",
        cmd: "opencode-statusline.usage.close"
      }
    ]
  } as any);
};

const pluginModule: TuiPluginModule & { id: string } = {
  id,
  tui
};

export default pluginModule;
