local GameTimes = T(Lib, "GameTimes")
local LuaTimer = T(Lib, "LuaTimer")
Define.GameTimeDay = {
  "g2052.gui.time.monday",
  "g2052.gui.time.tuesday",
  "g2052.gui.time.wednesday",
  "g2052.gui.time.thursday",
  "g2052.gui.time.friday",
  "g2052.gui.time.saturday",
  "g2052.gui.time.sunday"
}

function GameTimes:Init()
  self.curTimeMin = 0
  self.curTimeHour = 0
  self.curDay = 1
  if self.timer then
    LuaTimer:cancel(self.timer)
  end
  self.timer = LuaTimer:schedule(function()
    self:_OnTick()
  end, 0, World.cfg.timeSpeedRate * 1000)
end

function GameTimes:_OnTick()
  self.curTimeMin = self.curTimeMin + 1
  if self.curTimeMin == 60 then
    self.curTimeMin = 0
    self.curTimeHour = self.curTimeHour + 1
    if self.curTimeHour == 24 then
      self.curTimeHour = 0
      self.curDay = self.curDay + 1
      if self.curDay > 7 then
        self.curDay = 1
      end
    end
    if not World.isClient then
      self:adjustGameTime()
    end
  end
  World.CurWorld:setWorldTime(self.curTimeHour * 1000 + self.curTimeMin / 60 * 1000)
end

function GameTimes:GetTime()
  local time = {
    day = self.curDay,
    hour = self.curTimeHour,
    min = self.curTimeMin
  }
  return time
end

function GameTimes:setTime(hour, min)
  self.curTimeHour = hour
  self.curTimeMin = min
  if not World.isClient then
    self:adjustGameTime()
  end
end

function GameTimes:onPlayerLogin(player)
  if not World.isClient then
    self:adjustGameTime()
  end
end

function GameTimes:adjustGameTime(data)
  if World.isClient then
    if data then
      self.curDay = data.curDay or self.curDay
      self.curTimeHour = data.curTimeHour or self.curTimeHour
      self.curTimeMin = data.curTimeMin or self.curTimeMin
    end
  else
    WorldServer.BroadcastPacket({
      pid = "adjustGameTime",
      curDay = self.curDay,
      curTimeHour = self.curTimeHour,
      curTimeMin = self.curTimeMin
    })
  end
end

GameTimes:Init()
return GameTimes
