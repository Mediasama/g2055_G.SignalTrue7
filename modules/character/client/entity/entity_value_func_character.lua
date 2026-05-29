local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:action_idle(value)
  if self.objID == Me.objID and self.isPlayEntityMotionTick and World.CurWorld:getTickCount() - self.isPlayEntityMotionTick < 10 then
    print("Entity.ValueFunc:action_idle(value) return")
    return
  end
  self:setActionMapping("idle", value)
end

function Entity.ValueFunc:action_run(value)
  if self.objID == Me.objID and self.isPlayEntityMotionTick and World.CurWorld:getTickCount() - self.isPlayEntityMotionTick < 10 then
    print("Entity.ValueFunc:action_run(value) return")
    return
  end
  self:setActionMapping("run", value)
end

function Entity.ValueFunc:character_state(value)
  if self.objID == Me.objID then
    if value == Define.CHARACTER_STATE_TYPE.DIE then
      self:changeState(Define.CHARACTER_STATE_TYPE.DIE, {notSendServer = true})
    elseif value == Define.CHARACTER_STATE_TYPE.CARRY then
      self:changeState(Define.CHARACTER_STATE_TYPE.CARRY, {notSendServer = true})
    elseif value == Define.CHARACTER_STATE_TYPE.GROUND then
      self:changeState(Define.CHARACTER_STATE_TYPE.GROUND, {notSendServer = true})
    elseif value == Define.CHARACTER_STATE_TYPE.NORMAL and not Me:checkIsState(Define.CHARACTER_STATE_TYPE.NORMAL) and not Me:checkIsState(Define.CHARACTER_STATE_TYPE.SKILL) then
      self:changeState(Define.CHARACTER_STATE_TYPE.NORMAL, {notSendServer = true})
    end
  end
end
