local eucalynEventtap
local eucalynEnabled = false

local M = {}
-- キーマップのテーブルを定義
local eucalynKeyMap = {
  [0x0c] = 0x0c, -- q -> q
  [0x0d] = 0x0d, -- w -> w
  [0x0e] = 0x2b, -- e -> ,
  [0x0f] = 0x2f, -- r -> .
  [0x11] = 0x29, -- t -> ;
  [0x10] = 0x2e, -- y -> m
  [0x20] = 0x0f, -- u -> r
  [0x22] = 0x02, -- i -> d
  [0x1f] = 0x10, -- o -> y
  [0x23] = 0x23, -- p -> p
  [0x00] = 0x00, -- a -> a
  [0x01] = 0x1f, -- s -> o
  [0x02] = 0x0e, -- d -> e
  [0x03] = 0x22, -- f -> i
  [0x05] = 0x20, -- g -> u
  [0x04] = 0x05, -- h -> g
  [0x26] = 0x11, -- j -> t
  [0x28] = 0x28, -- k -> k
  [0x25] = 0x01, -- l -> s
  [0x06] = 0x06, -- z -> z
  [0x07] = 0x07, -- x -> x
  [0x08] = 0x08, -- c -> c
  [0x09] = 0x09, -- v -> v
  [0x0b] = 0x03, -- b -> f
  [0x2d] = 0x0b, -- n -> b
  [0x2e] = 0x04, -- m -> h
  [0x2b] = 0x26, -- , -> j
  [0x2f] = 0x25, -- . -> l
  [0x29] = 0x2d, -- ; -> n
  [0x2c] = 0x2c, -- / -> /
}

local qwertyKeyMap = {
  -- [0x0c] = 0x0c, -- q -> q
  -- [0x0d] = 0x0d, -- w -> w
  [0x2b] = 0x0e, -- , -> e
  -- [0x2f] = 0x0f, -- . -> r
  -- [0x29] = 0x11, -- ; -> t
  -- [0x2e] = 0x10, -- m -> y
  -- [0x0f] = 0x20, -- r -> u
  -- [0x02] = 0x22, -- d -> i
  -- [0x10] = 0x1f, -- y -> o
  [0x23] = 0x23, -- p -> p
  [0x00] = 0x00, -- a -> a
  -- [0x1f] = 0x01, -- o -> s
  [0x0e] = 0x02, -- e -> d
  [0x22] = 0x03, -- i -> f
  -- [0x20] = 0x05, -- u -> g
  [0x05] = 0x04, -- g -> h
  -- [0x11] = 0x26, -- t -> j
  -- [0x28] = 0x28, -- k -> k
  [0x01] = 0x25, -- s -> l
  -- [0x06] = 0x06, -- z -> z
  -- [0x07] = 0x07, -- x -> x
  -- [0x08] = 0x08, -- c -> c
  -- [0x09] = 0x09, -- v -> v
  [0x03] = 0x0b, -- f -> b
  [0x0b] = 0x2d, -- b -> n
  -- [0x04] = 0x2e, -- h -> m
  -- [0x26] = 0x2b, -- j -> ,
  -- [0x25] = 0x2f, -- l -> .
  -- [0x2d] = 0x29, -- n -> ;
  -- [0x2c] = 0x2c, -- / -> /
}


local function remapKey(event)
  if not eucalynEnabled then return false end

  local keyCode = event:getKeyCode()
  local flags = event:getFlags()
  local remappedKeyCode = eucalynKeyMap[keyCode]
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
  return eucalynEnabled
end

function M.enableEucalynLayout()
  if not eucalynEventtap then
    eucalynEventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, remapKey)
  end
  eucalynEnabled = true
  eucalynEventtap:start()
end

function M.disableEucalynLayout()
  if eucalynEventtap then
    eucalynEventtap:stop()
  end
  eucalynEnabled = false
end

function M.toggleEucalynLayout()
  if eucalynEnabled then
    M.disableEucalynLayout()
  else
    M.enableEucalynLayout()
  end
end

return M
