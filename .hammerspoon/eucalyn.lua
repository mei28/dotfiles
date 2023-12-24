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


local function remapKey(event)
  if not eucalynEnabled then return false end

  local keyCode = event:getKeyCode()
  local flags = event:getFlags()
  local remappedKeyCode = eucalynKeyMap[keyCode]
  local isKeyDown = event:getType() == hs.eventtap.event.types.keyDown

  if flags.ctrl then
    local ctrlKeyCodes = {
      [0x00] = 0x00, -- a -> a
      [0x2b] = 0x0e, -- , -> e
      [0x22] = 0x03, -- i -> f
      [0x0e] = 0x02, -- e -> d
      [0x2d] = 0x0b, --  n -> b
      [0x05] = 0x04, -- g -> h
      [0x0b] = 0x2d, -- b -> n
      [0x23] = 0x23, -- p -> p
    }
    if ctrlKeyCodes[keyCode] then
      local newEventDown = hs.eventtap.event.newKeyEvent({ 'ctrl' }, remappedKeyCode, true)
      local newEventUp = hs.eventtap.event.newKeyEvent({ 'ctrl' }, remappedKeyCode, false)
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
