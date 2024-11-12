local oonishiEventtap
local oonishiEnabled = false

local M = {}
-- キーマップのテーブルを定義
-- qwerty -> oonishi
local oonishiKeyMap = {
  [0x0c] = 0x0c, -- q -> q
  [0x0d] = 0x25, -- w -> l
  [0x0e] = 0x20, -- e -> u
  [0x0f] = 0x2b, -- r -> ,
  [0x11] = 0x2f, -- t -> .
  [0x10] = 0x03, -- y -> f
  [0x20] = 0x0d, -- u -> w
  [0x22] = 0x0f, -- i -> r
  [0x1f] = 0x10, -- o -> y
  [0x23] = 0x23, -- p -> p

  [0x00] = 0x0e, -- a -> e
  [0x01] = 0x22, -- s -> i
  [0x02] = 0x00, -- d -> a
  [0x03] = 0x1f, -- f -> o
  [0x05] = 0x2c, -- g -> /
  [0x04] = 0x28, -- h -> k
  [0x26] = 0x11, -- j -> t
  [0x28] = 0x2d, -- k -> n
  [0x25] = 0x01, -- l -> s
  [0x29] = 0x04, -- ; -> h

  [0x06] = 0x06, -- z -> z
  [0x07] = 0x07, -- x -> x
  [0x08] = 0x08, -- c -> c
  [0x09] = 0x09, -- v -> v
  [0x0b] = 0x29, -- b -> ;
  [0x2d] = 0x05, -- n -> g
  [0x2e] = 0x02, -- m -> d
  [0x2b] = 0x2e, -- , -> m
  [0x2f] = 0x26, -- . -> j
  [0x2c] = 0x0b, -- / -> b
}

local qwertyKeyMap = {
  [0x0c] = 0x0c, -- q -> q
  [0x25] = 0x0d, -- l -> w
  [0x20] = 0x0e, -- u -> e
  [0x2b] = 0x0f, -- , -> r
  [0x2f] = 0x11, -- . -> t
  [0x03] = 0x10, -- f -> y
  [0x0d] = 0x20, -- w -> u
  [0x0f] = 0x22, -- r -> i
  [0x10] = 0x1f, -- y -> o
  [0x23] = 0x23, -- p -> p

  [0x0e] = 0x00, -- e -> a
  [0x22] = 0x01, -- i -> s
  [0x00] = 0x02, -- a -> d
  [0x1f] = 0x03, -- o -> f
  [0x2c] = 0x05, -- / -> g
  [0x28] = 0x04, -- k -> h
  [0x11] = 0x26, -- t -> j
  [0x2d] = 0x28, -- n -> k
  [0x01] = 0x25, -- s -> l
  [0x04] = 0x29, -- h -> ;

  [0x06] = 0x06, -- z -> z
  [0x07] = 0x07, -- x -> x
  [0x08] = 0x08, -- c -> c
  [0x09] = 0x09, -- v -> v
  [0x29] = 0x0b, -- ; -> b
  [0x05] = 0x2d, -- g -> n
  [0x02] = 0x2e, -- d -> m
  [0x2e] = 0x2b, -- m -> ,
  [0x26] = 0x2f, -- j -> .
  [0x0b] = 0x2c, -- b -> /
}


local function remapKey(event)
  if not oonishiEnabled then return false end

  local keyCode = event:getKeyCode()
  local flags = event:getFlags()
  local remappedKeyCode = oonishiKeyMap[keyCode]
  local isKeyDown = event:getType() == hs.eventtap.event.types.keyDown

  if flags.ctrl and not (flags.shift or flags.alt or flags.cmd or flags.fn) then
    if qwertyKeyMap[remappedKeyCode] then
      local originalKeyCode = qwertyKeyMap[remappedKeyCode]
      local mods = { "ctrl" }

      local newEventDown = hs.eventtap.event.newKeyEvent(mods, originalKeyCode, true)
      local newEventUp = hs.eventtap.event.newKeyEvent(mods, originalKeyCode, false)
      return true, { newEventDown, newEventUp }
    end
  end

  if remappedKeyCode then
    local mods = {}
    if flags.shift then table.insert(mods, "shift") end
    if flags.ctrl then table.insert(mods, "ctrl") end
    if flags.alt then table.insert(mods, "alt") end
    if flags.cmd then table.insert(mods, "cmd") end

    local newEventDown = hs.eventtap.event.newKeyEvent(mods, remappedKeyCode, true)
    local newEventUp = hs.eventtap.event.newKeyEvent(mods, remappedKeyCode, false)
    return true, { newEventDown, newEventUp }
  end

  return false
end

function M.isEnabled()
  return oonishiEnabled
end

function M.enableOonishiLayout()
  if not oonishiEventtap then
    oonishiEventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, remapKey)
  end
  oonishiEnabled = true
  oonishiEventtap:start()
end

function M.disableOonishiLayout()
  if oonishiEventtap then
    oonishiEventtap:stop()
  end
  oonishiEnabled = false
end

function M.toggleOonishiLayout()
  if oonishiEnabled then
    M.disableOonishiLayout()
  else
    M.enableOonishiLayout()
  end
end

return M
