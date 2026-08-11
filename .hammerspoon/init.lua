require('window')
require('ime')
require('launch')
require('grayscale')
require('enterSwap')
-- disabled: kanata is off (enableKanata = false in nix-darwin/config/kanata.nix), which
-- removes the LaunchDaemon plist, so the HRM toggle and daemon controls have nothing to
-- talk to. Re-enable this together with that flag.
-- require('kanata')
-- disabled: Claude/Codex limit HUD is unused for now (re-enable to restore the menubar item)
-- require('wabi')


-- reload config
hs.hotkey.bind({ 'alt', 'ctrl' }, 'r', function()
  hs.reload()
end)

-- visible key
-- hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.systemDefined },
--   function(event)
--     local type = event:getType()
--     if type == hs.eventtap.event.types.keyDown then
--       print(hs.keycodes.map[event:getKeyCode()])
--     elseif type == hs.eventtap.event.types.systemDefined then
--       local t = event:systemKey()
--       if t.down then
--         print("System key: " .. t.key)
--       end
--     end
--   end):start()

