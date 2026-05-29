local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer

function Entity:recoverMoveSpeed()
  local conf = self:cfg()
  self:setProp("moveSpeed", conf.moveSpeed)
  self:setProp("moveAcc", conf.moveAcc)
end

function Entity:beTeabagAction(attackEntity)
  if not attackEntity.skillJsonConf then
    return
  end
  if self:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) or self:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) then
    local actionName = attackEntity.skillJsonConf.beTeabagAction
    if self:getValue("autoHurtSelf") then
      actionName = attackEntity.skillJsonConf.beTeabagAction_damage
    end
    local objID = self.objID
    local isOnce = true
    self:sendClientPlayerAction(actionName, -1, objID, isOnce, true)
  end
end

function Entity:sendClientPlayerAction(actionName, time, objID, isOnce, includeMe)
  local data = {}
  data.actionName = actionName
  data.time = time
  data.objID = objID
  local p = {
    pid = "playerAction",
    data = data,
    isOnce = isOnce,
    includeMe = includeMe
  }
  self:broadcastDungeonPacket(p)
end
