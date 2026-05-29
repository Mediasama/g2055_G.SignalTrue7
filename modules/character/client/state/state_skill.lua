local StateSkill = Lib.class("StateSkill", require("common.state.state_base"))
local CameraManager = T(Lib, "CameraManager")

function StateSkill:enter(param)
  Me:pam_C2S_RequestStopMotion()
  local attackType, skillName, isRecharge = Me.weapon:checkAttackHurt()
  if param.skillName then
    skillName = param.skillName
  end
  print("skillName=", skillName)
  local meleeSkill, from = Skill.getSkill(skillName)
  meleeSkill:setAttackType(attackType)
  meleeSkill:setIsKickATM(param.isKickATM)
  meleeSkill:setIsRechargeSkill(isRecharge)
  self.skill = meleeSkill
  Skill.Cast(meleeSkill, Me, param.packet or {})
  self.beginTickCount = World.CurWorld:getTickCount()
  CameraManager:lockCameraView()
  param.skillName = skillName
  self.entity:sendPacket({
    pid = "playerAction",
    actionName = meleeSkill.castAction,
    time = -1
  })
end

function StateSkill:update()
  local pastTick = World.CurWorld:getTickCount() - self.beginTickCount
  if self.skill.update then
    local isBackSwing = pastTick >= self.skill:getSkillTime() - self.skill.backSwingTime
    local res, info = pcall(self.skill.update, self.skill, isBackSwing)
    if not res then
      print("stack traceback:", info)
    end
  end
  if pastTick >= self.skill:getSkillTime() then
    self.entity:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
  elseif pastTick >= self.skill.preSwingTime and not self.doPreSwingTime then
    self.skill:beginHurt(self.entity)
    self.doPreSwingTime = true
  end
  if not self.skill.resetMoveSpeedTime or pastTick >= self.skill.resetMoveSpeedTime then
  end
end

function StateSkill:isCanEnter()
  local state = self.entity:getCurState()
  print("StateSkill:isCanEnter, state is", state, self.entity.stateManager)
  if state == Define.CHARACTER_STATE_TYPE.SKILL or state == Define.CHARACTER_STATE_TYPE.GROUND or state == Define.CHARACTER_STATE_TYPE.DIE then
    return false
  end
  return true
end

function StateSkill:leave(param)
  self.entity.rechargeFull = false
  print(" StateSkill:leave")
  CameraManager:freeViewEx()
  self.skill:leave()
end

return StateSkill
