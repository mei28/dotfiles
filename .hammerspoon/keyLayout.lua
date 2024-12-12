local Layout = {}
Layout.__index = Layout

function Layout:new(name, keyMap, reverseMap)
  return setmetatable({
    name = name,
    keyMap = keyMap,
    reverseMap = reverseMap,
    eventTap = nil,
    enabled = false,
  }, self)
end

function Layout:remapKey(event)
  if not self.enabled then return false end

  local keyCode = event:getKeyCode()
  local flags = event:getFlags()
  local remappedKeyCode = self.keyMap[keyCode]
  local isKeyDown = event:getType() == hs.eventtap.event.types.keyDown

  if flags.ctrl and not (flags.shift or flags.alt or flags.cmd or flags.fn) then
    local originalKeyCode = self.reverseMap[keyCode]
    if originalKeyCode then
      local mods = { "ctrl" }
      local newEventDown = hs.eventtap.event.newKeyEvent(mods, originalKeyCode, true)
      local newEventUp = hs.eventtap.event.newKeyEvent(mods, originalKeyCode, false)
      return true, { newEventDown, newEventUp }
    end
  end

  if remappedKeyCode then
    local mods = {}
    for _, mod in ipairs({ "shift", "ctrl", "alt", "cmd" }) do
      if flags[mod] then table.insert(mods, mod) end
    end

    local newEventDown = hs.eventtap.event.newKeyEvent(mods, remappedKeyCode, true)
    local newEventUp = hs.eventtap.event.newKeyEvent(mods, remappedKeyCode, false)
    return true, { newEventDown, newEventUp }
  end

  return false
end

function Layout:isEnabled()
  return self.enabled
end

function Layout:enableLayout()
  if not self.eventTap then
    self.eventTap = hs.eventtap.new(
      { hs.eventtap.event.types.keyDown },
      function(event) return self:remapKey(event) end
    )
  end
  self.enabled = true
  self.eventTap:start()
end

function Layout:disableLayout()
  if self.eventTap then
    self.eventTap:stop()
  end
  self.enabled = false
end

function Layout:toggleLayout()
  if self.enabled then
    self:disableLayout()
  else
    self:enableLayout()
  end
end

return Layout

