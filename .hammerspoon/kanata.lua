-- kanata 制御 (HRM トグル + daemon 起動/終了)
--   左クリック: メニュー表示 (HRM/start/stop/restart/reload)
--   ホットキー: Cmd+Alt+Ctrl+H = HRM トグル, +K = config reload, +P = daemon トグル
--   daemon 制御は sudo NOPASSWD (/etc/sudoers.d/kanata) に依存

local KANATA_PORT = 10000
local LAYER_ON = "base"
local LAYER_OFF = "nomod"
local SERVICE = "system/dev.mei.kanata-internal"
local PLIST = "/Library/LaunchDaemons/dev.mei.kanata-internal.plist"

local enabled = true
local menubar = hs.menubar.new()

local function sendCommand(json)
  local cmd = string.format(
    "printf '%%s\\n' '%s' | /usr/bin/nc -w 1 localhost %d 2>/dev/null",
    json, KANATA_PORT
  )
  os.execute(cmd)
end

local function sendLayer(name)
  sendCommand(string.format('{"ChangeLayer":{"new":"%s"}}', name))
end

local function reload()
  sendCommand('{"Reload":{}}')
  hs.alert.show("kanata config reloaded", 0.8)
end

local function isRunning()
  local handle = io.popen("/usr/bin/pgrep -x kanata 2>/dev/null")
  if not handle then return false end
  local out = handle:read("*a")
  handle:close()
  return out ~= nil and out ~= ""
end

local function refreshMenu()
  if not menubar then return end
  if not isRunning() then
    menubar:setTitle("⌨ ✕")
  elseif enabled then
    menubar:setTitle("⌨ HRM")
  else
    menubar:setTitle("⌨ off")
  end
end

local function toggleHRM()
  if not isRunning() then
    hs.alert.show("kanata not running", 0.8)
    return
  end
  enabled = not enabled
  sendLayer(enabled and LAYER_ON or LAYER_OFF)
  refreshMenu()
  hs.alert.show("HRM " .. (enabled and "ON" or "OFF"), 0.5)
end

local function startDaemon()
  os.execute("/usr/bin/sudo -n /bin/launchctl bootstrap system " .. PLIST .. " 2>/dev/null")
  hs.timer.doAfter(1.5, function()
    enabled = true
    refreshMenu()
    hs.alert.show(isRunning() and "kanata started" or "kanata start failed", 0.8)
  end)
end

local function stopDaemon()
  os.execute("/usr/bin/sudo -n /bin/launchctl bootout system " .. PLIST .. " 2>/dev/null")
  hs.timer.doAfter(1.5, function()
    refreshMenu()
    hs.alert.show(isRunning() and "kanata stop failed" or "kanata stopped", 0.8)
  end)
end

local function restartDaemon()
  os.execute("/usr/bin/sudo -n /bin/launchctl kickstart -k " .. SERVICE .. " 2>/dev/null")
  hs.timer.doAfter(1.5, function()
    enabled = true
    refreshMenu()
    hs.alert.show("kanata restarted", 0.8)
  end)
end

local function toggleDaemon()
  if isRunning() then stopDaemon() else startDaemon() end
end

local function buildMenu()
  local running = isRunning()
  return {
    { title = running and "● running" or "○ stopped", disabled = true },
    { title = "-" },
    { title = (enabled and "✓ " or "    ") .. "HRM",  fn = toggleHRM,    disabled = not running },
    { title = "Reload config",                          fn = reload,       disabled = not running },
    { title = "-" },
    { title = running and "Stop kanata" or "Start kanata", fn = toggleDaemon },
    { title = "Restart kanata",                            fn = restartDaemon, disabled = not running },
  }
end

if menubar then
  refreshMenu()
  menubar:setMenu(buildMenu)
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "h", toggleHRM)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "k", reload)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "p", toggleDaemon)

-- 外部要因で daemon 状態が変わるケースに備え定期更新
hs.timer.doEvery(5, refreshMenu)

return {
  toggle = toggleHRM,
  reload = reload,
  start = startDaemon,
  stop = stopDaemon,
  restart = restartDaemon,
  isRunning = isRunning,
}
