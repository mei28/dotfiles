-- Discord で Enter ↔ Shift+Enter を入れ替え
--   Enter        → Shift+Enter (改行)
--   Cmd+Enter    → Enter        (送信)

local DISCORD_BUNDLE = "com.hnc.Discord"
local enterKeyCode = hs.keycodes.map["return"]

local function isDiscordFront()
  local app = hs.application.frontmostApplication()
  return app and app:bundleID() == DISCORD_BUNDLE
end

local tap = hs.eventtap.new({
  hs.eventtap.event.types.keyDown,
  hs.eventtap.event.types.keyUp,
}, function(e)
  if not isDiscordFront() then return false end
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
