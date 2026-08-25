-- Keep the machine awake while the screen is locked.
--
-- Locking with cmd+ctrl+q should not interrupt network connections or jobs
-- running in a terminal. Only idle *system* sleep is suppressed ("systemIdle" ==
-- caffeinate -i), so the display still sleeps and the screen stays locked.
--
-- Closing the lid still sleeps the machine. Clamshell sleep is not an idle
-- sleep and no power assertion holds it off; keep the lid open, or dock to an
-- external display on AC.
--
-- The manual counterpart is `cafwake` / `caf` in configs/caffeinate.bash, for jobs
-- that run while the screen stays unlocked. The two assertions are independent
-- and stack harmlessly.

local M = {}

local CAP_SECONDS = 12 * 60 * 60

local timer = nil
local heldSince = nil

local function release(reason)
  if timer then
    timer:stop()
    timer = nil
  end
  if heldSince then
    hs.caffeinate.set("systemIdle", false)
    heldSince = nil
    print("caffeine: released (" .. reason .. ")")
  end
end

-- Arms a timer for whatever is left of the cap, measured against the wall clock.
local function armTimer()
  if timer then
    timer:stop()
  end
  local remaining = CAP_SECONDS - (hs.timer.secondsSinceEpoch() - heldSince)
  if remaining <= 0 then
    release("cap reached")
    return
  end
  timer = hs.timer.doAfter(remaining, function()
    release("cap reached")
  end)
end

local function hold()
  -- A second lock event while already holding must not extend the cap: the 12
  -- hours run from the first lock.
  if heldSince then
    return
  end
  heldSince = hs.timer.secondsSinceEpoch()
  hs.caffeinate.set("systemIdle", true)
  armTimer()
  print("caffeine: holding systemIdle for up to 12h")
end

-- hs.timer runs on a clock that does not advance while the system is asleep, so
-- a suspend would stretch the cap in wall-clock terms. Re-derive it on wake.
local function recheck()
  if not heldSince then
    return
  end
  armTimer()
end

local watcher = hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.screensDidLock then
    hold()
  elseif event == hs.caffeinate.watcher.screensDidUnlock then
    release("unlocked")
  elseif event == hs.caffeinate.watcher.systemDidWake then
    recheck()
  end
end)

watcher:start()

M.watcher = watcher

return M
