local handles = T(Player, "PackageHandlers")

function handles:onUpdateCarryBtn(packet)
  Lib.emitEvent(Event.EVENT_CHARACTER_STATE_ON_GROUND_UPDATE_BTN, packet.param)
end

function handles:onUpdateCarrySuccess(packet)
  Lib.emitEvent(Event.EVENT_CHARACTER_STATE_ON_GROUND_CARRY_SUCCESS, packet.userId, true)
end

function handles:onBeThrowForceMove(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity and entity:isValid() then
    entity:setForceMove(packet.pos, packet.time)
  end
end
