local Entity = _ENV.Entity
local AimHelper = T(Lib, "AimHelper")
local HitBoxHelper = T(Lib, "HitBoxHelper")
local EntityColliderHelper = T(Lib, "EntityColliderHelper")
local StateManager = require("common.state.state_manager")
Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(player)
  print("============>> Event.EVENT_PLAYER_LOGIN", player.objID)
  if player.objID ~= Me.objID then
    return
  end
  UI:openWindow("UI/main/skill_action")
  Me.joystickWin = UI:openWindow("UI/main/mobile_editor_joystick")
  UI:openWindow("UI/be_damage")
  Me.mainUIWin = UI:openWindow("UI/main/tips_win")
  Me.mainUIWin:setAlwaysOnTop(true)
  local cameraCfg = World.cfg.fightCameraCfg
  if not cameraCfg then
    return
  end
  local AbilityManager = T(Lib, "AbilityManager")
  AbilityManager:init(Me)
  Me.stateManager = StateManager.new(Me)
  print("====player.stateManager", Me.stateManager)
  Me:changeState(Define.CHARACTER_STATE_TYPE.NORMAL)
  Me:playBgmByKey("g2055_mainDayBGM")
  for level = 1, 3 do
    Blockman.Instance():setQualityLevelData(level - 1, 16, 0)
    if 1 < level then
      Blockman.Instance():setQualityLevelData(level - 1, 5, 0.02)
    end
  end
end)
Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
  local entity = World.CurWorld:getEntity(objID)
  if entity and entity:isValid() then
    if entity.isPlayer then
      AimHelper:addPlayerCollisionBox(entity)
    end
    HitBoxHelper:addPlayerHitBox(entity)
  end
end)
Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objID)
  local entity = World.CurWorld:getEntity(objID)
  if entity then
    EntityColliderHelper:removeEntityCollisionBox(entity)
    if entity:isValid() then
      if entity.isPlayer then
        AimHelper:removePlayerCollisionBox(entity)
      end
      HitBoxHelper:removePlayerHitBox(entity)
    end
  end
end)

function Entity:checkIsState(state)
  if not self.getCurState then
    return false
  end
  local curState = self:getCurState()
  return curState == state
end

function Entity:changeState(state, param)
  if self.stateManager then
    self.stateManager:changeState(state, param)
  end
end

function Entity:getCurState()
  if self.stateManager then
    return self.stateManager:getCurState()
  else
    return self:getCharacterState()
  end
end
