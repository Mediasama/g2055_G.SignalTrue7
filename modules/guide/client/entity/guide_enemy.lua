local GuideEnemy = Lib.class("GuideEnemy")
local EnemyConfig = World.cfg.guildEnemy

function GuideEnemy:ctor(pos, rotate, guildHelper)
  local function initEntity(entity)
    if entity then
      local skin = {
        custom_hair = "g2055_costume_01",
        
        custom_face = "g2055_costume_01",
        clothes_tops = "g2055_costume_01",
        clothes_pants = "g2055_costume_01",
        custom_shoes = "g2055_costume_01"
      }
      entity:applySkin(skin)
      entity.guideEnemy = self
      self.entity = entity
      print("entity create success")
      entity:updateUpperAction1("g2055_movement_akinmbo", -1, true, 0, true)
    end
  end
  
  local params = {
    objID = 99999,
    name = Lang:toText(EnemyConfig.name),
    rotationYaw = rotate.y,
    rotationPitch = 0,
    cfgName = "myplugin/player1",
    actorName = "g2055_boy.actor",
    pos = pos,
    curHp = 100
  }
  Game.EntitySpawn(Me, params, initEntity)
  print("init npc attr", rotate.y)
  self.curHp = EnemyConfig.maxHp
  self.guildHelper = guildHelper
end

function GuideEnemy:onHit(isRecharge)
  local hurt = EnemyConfig.normalAttack
  if isRecharge then
    hurt = EnemyConfig.rechargeAttack
  end
  Me:showHurtEffect(self.entity, hurt, Me.objID)
  Lib.emitEvent(Event.EVENT_ROGUELIKE_ENEMY_HURT, 3)
  self.curHp = self.curHp - hurt
  if self.curHp <= 0 then
    self:onDieGround()
  else
    if self.curHp <= EnemyConfig.HeadHuggingHp then
      local actionName = "g2055_movement_squat"
      self.entity:updateUpperAction1(actionName, -1, true, 0, true)
    else
    end
  end
  self.entity:doHurtInC(Lib.v3(0, 0, 0), 4)
end

function GuideEnemy:onDieGround()
  if self.doOnce then
    return
  end
  self.doOnce = true
  print("GuideEnemy:onDieGround()")
  local actionName = "g2055_fall"
  self.entity:updateUpperAction1(actionName, -1, true, 0, true)
  self.entity:setActionMapping("idle", actionName)
  local pos = self.entity:getPosition()
  local cloneOffset = Lib.v3(EnemyConfig.goldOffset.x, EnemyConfig.goldOffset.y, EnemyConfig.goldOffset.z)
  local rotation = Vector3.new(-self.entity:getRotationPitch(), -self.entity:getRotationYaw(), -self.entity:getRotationRoll())
  Lib.rotate(cloneOffset, rotation)
  local position = pos + cloneOffset
  self.guildHelper:finishStep(Define.GUIDE_NPC, {pos = position})
end

function GuideEnemy:onDestroy()
  self.entity:destroy()
end

return GuideEnemy
