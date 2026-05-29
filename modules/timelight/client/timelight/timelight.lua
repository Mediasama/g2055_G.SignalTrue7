local TimeLight = T(Lib, "TimeLight")
local LuaTimer = T(Lib, "LuaTimer")
local TimeLightConfig = T(Config, "TimeLightConfig")
local GameTimes = require("client.game_times")
local engineSceneManager = EngineSceneManager.Instance()
local DAYSECONDS = 86400
local pointArr = {}
local spotArr = {}

function TimeLight:Init()
  local root = Root.Instance()
  root:setRealtimeShadowTexSizeLevel(1)
  root:setRealtimeShadowIntensityLevel(0.9)
  root:setRealtimeShadowCullFront(true)
  engineSceneManager:setEnableLightMap(true)
  Lib.lightSubscribeEvent("error!!!!! : TimeLight event : EVENT_QUALITY_LEVEL_CHANGE", Event.EVENT_QUALITY_LEVEL_CHANGE, function(level)
    print("Event.EVENT_QUALITY_LEVEL_CHANGE", level)
    if 0 < level then
      self:_SetLight_hight()
    else
      self:_SetLight_low()
    end
  end)
  if self.timer then
    LuaTimer:cancel(self.timer)
  end
  self.timer = LuaTimer:schedule(function()
    self:_OnTick()
  end, 0, 1000)
end

function TimeLight:GetTime()
  return Lib.timeFormatting(self.seconds)
end

function TimeLight:_OnTick()
  engineSceneManager:setMainLightDir(engineSceneManager:getDirLightDir())
  engineSceneManager:setMainLightColor(engineSceneManager:getDirLightColor())
  local quality = Blockman.Instance().gameSettings:getCurQualityLevel()
  if self.lastQuality == quality then
    return
  end
  self.lastQuality = quality
  local curTime = GameTimes:GetTime()
  local seconds = Lib.time2Seconds(curTime.hour, curTime.min)
  self:_SetTime(seconds)
end

function TimeLight:_SetTime(sec)
  if self.lastQuality and self.lastQuality > 0 then
    self:_SetLight_hight()
  else
    self:_SetLight_low()
  end
end

function TimeLight:_LerpNumber(lerp, from, to)
  return from + (to - from) * lerp
end

function TimeLight:_LerpVector3(lerp, from, to)
  return from + (to - from) * lerp
end

function TimeLight:_LerpColor(lerp, from, to)
  local ret = {}
  for i = 1, 4 do
    table.insert(ret, self:_LerpNumber(lerp, from[i], to[i]))
  end
  return ret
end

function TimeLight:_TimeLerp(sec, from, to)
  if to < from then
    if sec < to then
      sec = sec + DAYSECONDS
    end
    to = to + DAYSECONDS
  end
  return (sec - from) / (to - from)
end

local function setVirtualPointLight(id, pos, ambient, diffuse, specular, Constant, Linear, Quadratic)
  table.insert(pointArr, id)
  if EngineSceneManager.setVirtualPointLight2 then
    engineSceneManager:setVirtualPointLight2(id, pos, ambient, diffuse, specular, Constant, Linear, Quadratic)
  elseif EngineSceneManager.setVirtualPointLight then
    engineSceneManager:setVirtualPointLight(id, pos, ambient, diffuse, specular, Constant, Linear, Quadratic)
  end
end

function TimeLight:_SetLight_hight()
  Blockman.Instance().gameSettings:setEnableRealtimeShadow(0.005)
end

function TimeLight:_SetLight_low()
end

TimeLight:Init()
