local GuideHelper = T(Lib, "GuideHelper")
local GuideEnemy = require("client.entity.guide_enemy")
local GuideConfig = require("common.config.guide_config")

function GuideHelper:initDoorPosition(position, rotation, isOldPlayer)
  self.doorPosition = position
  self.doorRotation = rotation
  self.isOldPlayer = isOldPlayer
end

function GuideHelper:enterGuild()
  if not Me:isOpenGuide() then
    return
  end
  Lib.subscribeEvent(Event.EVENT_GUIDE_FINISH, function(id, param)
    self:finishStep(id, param)
  end)
  Lib.subscribeEvent(Event.EVENT_GUIDE_OPEN_TIPS, function(id)
    local config = GuideConfig:getCfgById(id)
    if config and config.guideParent == self.curId then
      self:openStepTips(id)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_GUIDE_CLOSE_TIPS, function(id)
    self:closeStepTips(id)
  end)
  local id = Me:getGuideID()
  print("GuideHelper:enterGuild()", id)
  if GuideConfig:getCfgById(id + 1) then
    self:beginStep(id + 1)
  end
end

function GuideHelper:finishStep(id, param)
  if id ~= self.curId then
    return
  end
  if self.curConfig.goldCount > 0 then
    local goldCount = self.curConfig.goldCount
    local pos = param.pos
    self:createGold(goldCount, pos)
  end
  if self.curConfig.isSave then
    Me:sendPacket({
      pid = "saveGuideID",
      id = id
    })
  end
  if self.guildEnemy and id == Define.GUIDE_NPC + 1 then
    self.guildEnemy:onDestroy()
    self.guildEnemy = nil
  end
  local win = self:getGuideWin()
  win:hideWin()
  self:hideGuideArrow()
  if GuideConfig:getCfgById(id + 1) then
    self:beginStep(id + 1)
  end
end

function GuideHelper:beginStep(id)
  local config = GuideConfig:getCfgById(id)
  self:openStepTips(id)
  self:doGuildStep(id, config)
  if config.effect_pos then
    local offset = Lib.v3(config.effect_pos[1], config.effect_pos[2], config.effect_pos[3])
    local pos, rot = self:getPositionAndRotation(offset)
    self:showGuideArrow(pos, rot)
  end
  self.curConfig = config
  self.curId = id
  if id == Define.GUIDE_UNLOCK_WEAPON and Me:getBastionArmoryLevel() > 0 then
    self:finishStep(id)
  end
end

function GuideHelper:openStepTips(id)
  local config = GuideConfig:getCfgById(id)
  local win = self:getGuideWin(config.type)
  if config.type == 1 then
    win:showTopWin(config.desc)
  elseif config.type == 2 then
    win:showTipsWin(config.desc, config.ui_pos)
  end
end

function GuideHelper:closeStepTips(id)
  local win = self:getGuideWin(2)
  win:hideTipsWin()
end

function GuideHelper:getGuideWin(type)
  local win
  if type == 2 then
    if not self.guildTipsWin then
      self.guildTipsWin = UI:openWindow("UI/guide/guide_tips")
      self.guildTipsWin:setAlwaysOnTop(true)
    end
    win = self.guildTipsWin
  else
    if not self.guildWin then
      self.guildWin = UI:openWindow("UI/guide/guide_win")
    end
    win = self.guildWin
  end
  return win
end

function GuideHelper:doGuildStep(id, config)
  if id == Define.GUIDE_NPC then
    self:crateEnemy()
  end
end

function GuideHelper:getPositionAndRotation(offset)
  local cloneOffset = Lib.copy(offset)
  Lib.rotate(cloneOffset, Vector3.new(-self.doorRotation.x, -self.doorRotation.y, -self.doorRotation.z))
  local position = self.doorPosition + cloneOffset
  local rotation = Lib.copy(self.doorRotation)
  return position, rotation
end

function GuideHelper:showGuideArrow(position, rotation)
  self:hideGuideArrow()
  local effectName = "g2055_effect_green_arrow.effect"
  self.arrowEffect = EffectNode.Load(effectName)
  self.arrowEffect:setLocalPosition(position)
  local parent = World.CurMap:getScene():getRoot()
  parent:addChild(self.arrowEffect)
end

function GuideHelper:hideGuideArrow()
  if self.arrowEffect then
    local parent = World.CurMap:getScene():getRoot()
    parent:removeChild(self.arrowEffect)
    self.arrowEffect = nil
  end
end

function GuideHelper:crateEnemy()
  local conf = World.cfg.guildEnemy.offset
  local offset = Lib.v3(conf.x, conf.y, conf.z)
  local pos, rot = self:getPositionAndRotation(offset)
  rot.y = rot.y + conf.yaw
  print("crateEnemy pos=", pos.x, pos.y, pos.z)
  self.guildEnemy = GuideEnemy.new(pos, rot, self)
end

function GuideHelper:createGold(goldCount, pos)
  local fullName = "myplugin/" .. Define.GoldItemID
  local item = Item.CreateItem(fullName, 1)
  local objID = 998
  local dropitem = DropItemClient.Create(998, pos, item, {
    x = 0.001,
    y = 0.001,
    z = 0.001
  }, 10, 9999)
  local itemData = {}
  itemData.itemID = Define.GoldItemID
  itemData.count = goldCount
  itemData.bulletCount = -1
  itemData.guid = 0
  dropitem.itemData = itemData
  local tickCount = 0
  local disTick = 3
  self.pickTimer = World.LightTimer("pickTimer", disTick, function()
    tickCount = tickCount + disTick
    if tickCount < 30 then
      return true
    end
    local mePos = Lib.copy(Me:getPosition())
    mePos.y = mePos.y + 0.5
    local dis = Lib.getPosDistance(mePos, pos)
    if dis < 1.3 then
      dropitem:destroy()
      Me:playSoundByKey("g2055_item_pickWeapon")
      Me:sendPacket({
        pid = "sendGuideGold",
        id = Define.GUIDE_NPC
      })
      Lib.emitEvent(Event.EVENT_GUIDE_FINISH, Define.GUIDE_NPC + 1)
      return false
    end
    return true
  end)
end
