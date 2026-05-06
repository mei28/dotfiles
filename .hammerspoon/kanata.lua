-- kanata HRM 制御 (メニューバー UI)
--   メニューバーに状態表示 + クリックで ON/OFF
--   ホットキー Cmd+Alt+Ctrl+H でも切替可
--   kanata に TCP (port 10000) で layer-switch 送信

local KANATA_PORT = 10000
local LAYER_ON = "base"
local LAYER_OFF = "nomod"

local enabled = true
local menubar = hs.menubar.new()

-- kanata TCP は改行終端 JSON 必須
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

local function refreshMenu()
  if not menubar then return end
  if enabled then
    menubar:setTitle("⌨ HRM")
  else
    menubar:setTitle("⌨ off")
  end
end

local function toggle()
  enabled = not enabled
  sendLayer(enabled and LAYER_ON or LAYER_OFF)
  refreshMenu()
  hs.alert.show("HRM " .. (enabled and "ON" or "OFF"), 0.5)
end

if menubar then
  refreshMenu()
  menubar:setClickCallback(toggle)
end

-- ホットキー
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "h", toggle)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "k", reload)

return {
  toggle = toggle,
  reload = reload,
  enable = function()
    enabled = false
    toggle()
  end,
  disable = function()
    enabled = true
    toggle()
  end,
}
