local PlayerBehaviorServer = Player
local oldSetMap = Object.setMap

function PlayerBehaviorServer:setMap(newMap)
  local result = oldSetMap(self, newMap)
  if result then
    Trigger.CheckTriggers(self:cfg(), Define.TriggerHandlers.PLAYER_TELEPORT_MAP, {obj1 = self})
  else
    Trigger.CheckTriggers(self:cfg(), Define.TriggerHandlers.PLAYER_TELEPORT_POSITION, {obj1 = self})
  end
  return result
end
