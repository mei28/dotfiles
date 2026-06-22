-- wabi limit HUD (menubar glance + canvas detail)
--   左クリック: 詳細メニュー表示 (limits/refresh/HUD toggle)
--   ホットキー: Cmd+Alt+Ctrl+L = HUD トグル
--   表示は state.json を直接読み、更新だけ wabi task に任せる

local HOME = os.getenv("HOME")
local WABI_BIN = HOME .. "/.nix-profile/bin/wabi"
local STATE_PATH = HOME .. "/.local/state/wabi/state.json"
local RENDER_SEC = 90   -- UI 再描画間隔
local TICK_SEC = 900    -- API tick 間隔 (wabi tick --max-age と揃える)
local HUD_HOTKEY = { "cmd", "alt", "ctrl" }
local HUD_KEY = "l"

local COLORS = {
  green = { hex = "#7bd88f" },
  yellow = { hex = "#f6c177" },
  red = { hex = "#eb6f92" },
  text = { hex = "#f4f4f5" },
  muted = { hex = "#a1a1aa" },
  bg = { hex = "#111111", alpha = 0.90 },
  track = { hex = "#3f3f46", alpha = 0.90 },
}

local menubar = hs.menubar.new()
local hud = nil
local renderTimer = nil
local tickTimer = nil
local runningTask = nil
local paused = false
local render = nil
local toggleHUD = nil
local runWabi = nil

local function readState()
  return hs.json.read(STATE_PATH)
end

local function pctColor(p)
  if p == nil then return COLORS.muted end
  if p >= 90 then return COLORS.red end
  if p >= 70 then return COLORS.yellow end
  return COLORS.green
end

local function makeBar(p, cells)
  if p == nil then return string.rep("░", cells) end
  local n = math.floor((math.max(0, math.min(100, p)) / 100) * cells + 0.5)
  return string.rep("█", n) .. string.rep("░", cells - n)
end

local function compactError(message)
  if message == nil or message == "" then return "unknown provider error" end
  local oneLine = message:gsub("%s+", " ")
  if #oneLine <= 72 then return oneLine end
  return oneLine:sub(1, 69) .. "..."
end

local function parseUtc(resets_at)
  if type(resets_at) ~= "string" then return nil end

  local y, mo, d, h, mi, s =
    resets_at:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)%.%d+Z$")
  if not y then
    y, mo, d, h, mi, s =
      resets_at:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)Z$")
  end
  if not y then return nil end

  local asLocal = os.time({
    year = tonumber(y),
    month = tonumber(mo),
    day = tonumber(d),
    hour = tonumber(h),
    min = tonumber(mi),
    sec = tonumber(s),
    isdst = false,
  })
  local offset = os.difftime(os.time(os.date("*t", asLocal)), os.time(os.date("!*t", asLocal)))
  return asLocal + offset
end

local function formatDuration(seconds)
  if seconds < 0 then return "expired" end

  local minutes = math.floor(seconds / 60)
  local days = math.floor(minutes / 1440)
  local hours = math.floor((minutes % 1440) / 60)
  local mins = minutes % 60

  if days > 0 then return string.format("%dd%dh", days, hours) end
  if hours > 0 then return string.format("%dh%dm", hours, mins) end
  return string.format("%dm", mins)
end

local function formatReset(resets_at)
  local epoch = parseUtc(resets_at)
  if not epoch then return nil end

  return {
    clock = os.date("%H:%M", epoch),
    remain = formatDuration(os.difftime(epoch, os.time())),
  }
end

local function windowLine(w)
  if not w then return nil end

  local p = tonumber(w.used_percentage)
  local reset = formatReset(w.resets_at)
  local pct = p and string.format("%d%%", math.floor(p + 0.5)) or "--"
  local clock = reset and reset.clock or "--"
  local remain = reset and reset.remain or "--"

  return string.format("%s %s %s → %s (%s)", w.label or "--", makeBar(p, 14), pct, clock, remain)
end

local function providerWindows(state, key)
  local provider = state and state[key]
  if provider == nil then return {} end
  if provider.error then return { "err: " .. compactError(provider.error) } end

  local lines = {}
  if provider.five_hour then table.insert(lines, windowLine(provider.five_hour)) end
  if provider.secondary then table.insert(lines, windowLine(provider.secondary)) end
  if #lines == 0 then table.insert(lines, "--") end
  return lines
end

local function styled(text, color, size)
  return hs.styledtext.new(text, {
    color = color,
    font = { name = "Menlo", size = size or 12 },
  })
end

local function titlePart(prefix, provider)
  if provider == nil then return styled(prefix .. "--", COLORS.muted) end
  if provider.error then return styled(prefix .. "err", COLORS.red) end
  if provider.five_hour == nil or provider.five_hour.used_percentage == nil then
    return styled(prefix .. "--", COLORS.muted)
  end

  local p = tonumber(provider.five_hour.used_percentage)
  if p == nil then return styled(prefix .. "--", COLORS.muted) end
  return styled(prefix .. string.format("%d", math.floor(p + 0.5)), pctColor(p))
end

local function renderMenubar(state)
  if not menubar then return end

  if not state then
    menubar:setTitle("wabi …")
    return
  end

  menubar:setTitle(titlePart("C", state.claude) .. styled(" ", COLORS.muted) .. titlePart("X", state.codex))
end

local function buildMenu()
  local state = readState()
  local items = {}

  if not state then
    table.insert(items, { title = "no data — run wabi update", disabled = true })
  else
    table.insert(items, { title = "Claude", disabled = true })
    for _, line in ipairs(providerWindows(state, "claude")) do
      table.insert(items, { title = "  " .. line, disabled = true })
    end
    table.insert(items, { title = "Codex", disabled = true })
    for _, line in ipairs(providerWindows(state, "codex")) do
      table.insert(items, { title = "  " .. line, disabled = true })
    end
  end

  table.insert(items, { title = "-" })
  table.insert(items, { title = "Refresh now", fn = function() runWabi({ "update" }, true) end })
  table.insert(items, { title = "Toggle HUD (⌘⌥⌃L)", fn = function() toggleHUD() end })
  table.insert(items, { title = "-" })
  if paused then
    table.insert(items, { title = "▶ Resume", fn = function()
      paused = false
      renderTimer:start()
      tickTimer:start()
      render()
    end })
  else
    table.insert(items, { title = "⏸ Pause", fn = function()
      paused = true
      renderTimer:stop()
      tickTimer:stop()
      renderMenubar(nil)
    end })
  end

  return items
end

local function hudRect()
  local frame = hs.screen.mainScreen():frame()
  return {
    x = frame.x + frame.w - 420,
    y = frame.y + 34,
    w = 390,
    h = 210,
  }
end

local function textElement(text, frame, color, size)
  return {
    type = "text",
    text = styled(text, color or COLORS.text, size),
    frame = frame,
  }
end

local function appendWindowElements(elements, y, providerName, w)
  local p = tonumber(w.used_percentage)
  local reset = formatReset(w.resets_at)
  local pct = p and string.format("%d%%", math.floor(p + 0.5)) or "--"
  local resetText = reset and (reset.clock .. " (" .. reset.remain .. ")") or "--"

  table.insert(elements, textElement(providerName .. " " .. (w.label or "--"), { x = 22, y = y, w = 88, h = 20 }, COLORS.text, 12))
  table.insert(elements, {
    type = "rectangle",
    action = "fill",
    frame = { x = 116, y = y + 5, w = 138, h = 8 },
    roundedRectRadii = { xRadius = 4, yRadius = 4 },
    fillColor = COLORS.track,
  })
  table.insert(elements, {
    type = "rectangle",
    action = "fill",
    frame = { x = 116, y = y + 5, w = p and math.max(2, math.min(138, 138 * p / 100)) or 0, h = 8 },
    roundedRectRadii = { xRadius = 4, yRadius = 4 },
    fillColor = pctColor(p),
  })
  table.insert(elements, textElement(pct, { x = 268, y = y, w = 46, h = 20 }, pctColor(p), 12))
  table.insert(elements, textElement(resetText, { x = 316, y = y, w = 58, h = 20 }, COLORS.muted, 11))
end

local function appendProviderElements(elements, y, providerName, provider)
  if provider == nil then
    table.insert(elements, textElement(providerName .. " --", { x = 22, y = y, w = 340, h = 20 }, COLORS.muted, 12))
    return y + 24
  end

  if provider.error then
    table.insert(elements, textElement(providerName .. " err: " .. compactError(provider.error), { x = 22, y = y, w = 340, h = 20 }, COLORS.red, 12))
    return y + 24
  end

  if provider.five_hour then
    appendWindowElements(elements, y, providerName, provider.five_hour)
    y = y + 24
  end
  if provider.secondary then
    appendWindowElements(elements, y, providerName, provider.secondary)
    y = y + 24
  end
  if provider.five_hour == nil and provider.secondary == nil then
    table.insert(elements, textElement(providerName .. " --", { x = 22, y = y, w = 340, h = 20 }, COLORS.muted, 12))
    y = y + 24
  end

  return y
end

local function drawHUD(state)
  local rect = hudRect()
  if not hud then
    hud = hs.canvas.new(rect)
    hud:level("overlay")
    hud:behavior({ "canJoinAllSpaces", "fullScreenAuxiliary" })
    hud:clickActivating(false)
    hud:mouseCallback(nil)
  else
    hud:frame(rect)
  end

  local elements = {
    {
      type = "rectangle",
      action = "fill",
      frame = { x = 0, y = 0, w = rect.w, h = rect.h },
      roundedRectRadii = { xRadius = 8, yRadius = 8 },
      fillColor = COLORS.bg,
    },
    textElement("wabi limits", { x = 18, y = 14, w = 180, h = 24 }, COLORS.text, 14),
  }

  if not state then
    table.insert(elements, textElement("no data — run wabi update", { x = 22, y = 56, w = 330, h = 22 }, COLORS.muted, 12))
  else
    local y = 52
    y = appendProviderElements(elements, y, "Claude", state.claude)
    appendProviderElements(elements, y + 8, "Codex", state.codex)
  end

  hud:replaceElements(elements)
end

render = function()
  local state = readState()
  renderMenubar(state)
  if hud and hud:isShowing() then drawHUD(state) end
end

toggleHUD = function()
  local state = readState()
  drawHUD(state)
  if hud:isShowing() then hud:hide() else hud:show() end
end

runWabi = function(args, alertWhenMissing)
  if runningTask and runningTask:isRunning() then return end

  local file = io.open(WABI_BIN, "r")
  if not file then
    if alertWhenMissing then hs.alert.show("wabi binary not found", 1.0) end
    return
  end
  file:close()

  local task = hs.task.new(WABI_BIN, function(exitCode, stdout, stderr)
    runningTask = nil
    if exitCode ~= 0 then
      local output = stderr and stderr ~= "" and stderr or stdout
      hs.alert.show("wabi " .. args[1] .. " failed: " .. compactError(output), 1.4)
    end
    hs.timer.doAfter(4, render)
  end, args)

  if not task then
    hs.alert.show("wabi task failed to start", 1.0)
    return
  end

  task:setEnvironment({
    PATH = HOME .. "/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin",
    HOME = HOME,
  })
  runningTask = task
  if not task:start() then
    runningTask = nil
    hs.alert.show("wabi task failed to start", 1.0)
  end
end

if menubar then
  render()
  menubar:setMenu(buildMenu)
end

local function hasActiveWindow()
  local state = readState()
  if not state then return false end
  return (state.claude and state.claude.five_hour ~= nil)
      or (state.codex  and state.codex.five_hour  ~= nil)
end

hs.hotkey.bind(HUD_HOTKEY, HUD_KEY, toggleHUD)

-- UI 再描画のみ: API は叩かないので常時 OK
renderTimer = hs.timer.doEvery(RENDER_SEC, render)

-- API tick: アクティブウィンドウがある場合のみ実行
-- (未使用時は5時間ウィンドウを開始しない / バイナリ未インストールを安全にスキップ)
tickTimer = hs.timer.doEvery(TICK_SEC, function()
  if hasActiveWindow() then
    runWabi({ "tick", "--max-age", tostring(TICK_SEC) }, false)
  end
end)

return {
  render = render,
  toggle = toggleHUD,
  refresh = function() runWabi({ "update" }, true) end,
  renderTimer = renderTimer,
  tickTimer = tickTimer,
}
