local NpcDoorsConfig = T(Config, "NpcDoorsConfig")
local NPC_Door = require("server.npc_door")
local NPCDoorManager = Lib.class("NPCDoorManager")
local _instance

function NPCDoorManager.Instance()
  if _instance == nil then
    _instance = NPCDoorManager.new()
    _instance:init()
  end
  return _instance
end

function NPCDoorManager:ctor()
  self.doorDict = {}
  self.loaded = false
end

function NPCDoorManager:init()
  self:startUpdateTimer()
end

function NPCDoorManager:destroy()
  self:stopUpdateTimer()
end

function NPCDoorManager:startUpdateTimer()
  self:stopUpdateTimer()
  self._timer = World.Timer(1, function()
    self:update(1)
    return true
  end)
end

function NPCDoorManager:stopUpdateTimer()
  if self._timer and type(self._timer) == "function" then
    self._timer()
  end
end

function NPCDoorManager:update(timeDelta)
  for index, door in pairs(self.doorDict) do
    door:update(timeDelta)
  end
end

function NPCDoorManager:onPlayerDie(playerId)
  if not playerId then
    return
  end
  for i, door in pairs(self.doorDict) do
    door:onPlayerDie(playerId)
  end
end

function NPCDoorManager:getDoorDict()
  return self.doorDict
end

function NPCDoorManager:getDoor(id)
  return self.doorDict[id]
end

function NPCDoorManager:setDoor(id, door)
  if not id then
    return
  end
  if not door then
    return
  end
  self.doorDict[id] = door
end

function NPCDoorManager:removeDoor(id)
  self.doorDict[id] = nil
end

function NPCDoorManager:loadDoors()
  if self.loaded then
    return
  end
  local doorCFGs = NpcDoorsConfig:getAllCfgs()
  for i, doorCFG in pairs(doorCFGs) do
    local door = NPC_Door.new(doorCFG)
    self:setDoor(door:getID(), door)
  end
  self.loaded = true
end

return NPCDoorManager
