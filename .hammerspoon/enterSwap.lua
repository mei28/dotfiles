-- 指定アプリで Enter ↔ Shift+Enter を入れ替え
--   Enter        → Shift+Enter (改行)
--   Cmd+Enter    → Enter        (送信)
--
-- 対象アプリを増やす時は BUNDLES に bundle ID を追加するだけ。
-- bundle ID は `osascript -e 'id of app "AppName"'` で取得可能。

local BUNDLES = {
  ["com.hnc.Discord"] = true,
  ["com.anthropic.claudefordesktop"] = true,
}

local enterKeyCode = hs.keycodes.map["return"]

local function isTargetFront()
  local app = hs.application.frontmostApplication()
  return app and BUNDLES[app:bundleID()] == true
end

local tap = hs.eventtap.new({
  hs.eventtap.event.types.keyDown,
  hs.eventtap.event.types.keyUp,
}, function(e)
  if not isTargetFront() then return false end
  if e:getKeyCode() ~= enterKeyCode then return false end

  local flags = e:getFlags()
  if flags.cmd then
    -- Cmd+Enter → Enter (送信)
    e:setFlags({})
  else
    -- Enter → Shift+Enter (改行)
    e:setFlags({ shift = true })
  end
  return false
end)

tap:start()

return tap
