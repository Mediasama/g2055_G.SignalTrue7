local stateNormal = Lib.class("stateNormal", require("common.state.state_base"))

function stateNormal:enter(param)
  local state = self.entity:getCurState()
  if state == Define.CHARACTER_STATE_TYPE.GROUND or state == Define.CHARACTER_STATE_TYPE.BeCARRY then
    self.entity:setActionIdle("idle")
    self.entity:setActionRun("run")
    local packet = {
      pid = "EntityPlayAction",
      objID = self.entity.objID,
      action = "idle",
      time = -1,
      refreshBaseAction = true
    }
    self.entity:sendPacketToTracking(packet, true)
  elseif state == Define.CHARACTER_STATE_TYPE.DIE then
    self.entity:revive()
  end
  if not Me.isRestSpeed and Me.sendPacket then
    Me:sendPacket({
      pid = "resetMoveSpeed"
    })
    Me.isRestSpeed = true
  end
end

function stateNormal:leave(param)
end

return stateNormal
