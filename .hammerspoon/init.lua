require('window')
require('ime')
require('launch')
-- require('yabai')


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
