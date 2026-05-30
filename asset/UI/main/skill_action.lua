local LuaTimer = T(Lib, "LuaTimer")
local CameraManager = T(Lib, "CameraManager")
local GoodsBaseConfig = T(Config, "GoodsBaseConfig")
local reticleShrinkSpeedTimer = 40
local reticleSize = 64
local hitReticleSize = 64
local hitReticleInitialAlpha = 1
local hitReticleDisappearSpeed = 0.1
local hitReticleDisappearTime = 100
local RotationRang = {-30, 30}
local HitMainScale = 1.2
local HitSubScale = 0.7
local AtkIconList = {
  "set:g2055_main.json image:icon_0_fire01",
  "set:g2055_main.json image:icon_0_fire02"
}
local AbilityManager = T(Lib, "AbilityManager")
local hpBarList = {
  "set:g2055_main.json image:pbar_0_health_02",
  "set:g2055_main.json image:pbar_0_health_03",
  "set:g2055_main.json image:pbar_0_health_04"
}
local hpIconList = {
  "set:g2055_main.json image:icon_0_health_01",
  "set:g2055_main.json image:icon_0_health_02",
  "set:g2055_main.json image:icon_0_health_03"
}
local WeaponConfig = require("common.config.weapon_config")
local initViewFovAngle = World.cfg.weaponViewFovAngle

function M:onOpen(params)
  self:setUsingAutoRenderingSurface(true)
  self:initUI()
  self:initUIControl()
end

function M:onClose(params)
end

function M:initUI()
  self.selectIndex = 1
  self.btnAtkBtn = self.atk
  self.imgReticle = self.Center
  self.imgReticleHit = self.ReticleHit
  self.imgReticleHit:setAlpha(0)
  local pos = self.btnAtkBtn:getPosition()
  local screenWidth = GUISystem.instance:GetScreenWidth()
  local screenHeight = GUISystem.instance:GetScreenHeight()
  local posX = pos[1][2] + screenWidth / screenHeight * 720 - 1280
  self.btnAtkBtn:setPosition(UDim2.new(0, posX, 0, pos[2][2]))
  self.atkPos = {
    x = posX,
    y = pos[2][2]
  }
  self.auxiliaryTargeting = {25}
  Me.selectIndex = 1
  self.DefaultWindow:setVisible(false)
  self.pickViewItems = {}
  self.barList = {
    self.hpLayout.ProgressBar1,
    self.hpLayout.ProgressBar2,
    self.hpLayout.ProgressBar3
  }
  self.pickViewIndex = 1
  self.meleeTwinkleTimer = {}
end

function M:initUIControl()
  local pressTickCount, isCharge
  local this = self
  Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function(x, y)
    if not self:isVisible() then
      return
    end
    print("Event.EVENT_SCENE_TOUCH_BEGIN", x, y, self.atkPos.x)
    if not self.isWeaponView then
      return
    end
    local size = this.btnAtkBtn:getSize()
    if x > self.atkPos.x and x < self.atkPos.x + size.width[2] and y > self.atkPos.y and y < self.atkPos.y + size.height[2] then
      self.touchDownPos = {x = x, y = y}
      Lib.emitEvent(Event.EVENT_FIRE_TOUCH_DOWN)
      self.btnAtkBtn:setImage(AtkIconList[2])
      self.isClickFire = true
    end
  end)
  Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_MOVE, function(x, y)
    if not self:isVisible() then
      return
    end
    if self.isClickFire then
      local size = this.btnAtkBtn:getSize()
      local dx = self.atkPos.x + x - self.touchDownPos.x
      local dy = self.atkPos.y + y - self.touchDownPos.y
      this.btnAtkBtn:setPosition(UDim2.new(0, dx, 0, dy))
    end
    if not CameraManager.isFreeView then
      local bm = Blockman:Instance()
      local yaw = bm:getViewerYaw()
      local pitch = bm:getViewerPitch()
      Me:setBodyYawEx(yaw)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_END, function(x, y)
    if self.isClickFire then
      this.btnAtkBtn:setPosition(UDim2.new(0, self.atkPos.x, 0, self.atkPos.y))
      this.btnAtkBtn:setImage(AtkIconList[1])
      Lib.emitEvent(Event.EVENT_FIRE_TOUCH_UP)
      self.isClickFire = false
    end
  end)
  Lib.subscribeEvent(Event.EVENT_SYNC_WEAPON_DATA, function(weaponData)
    self:updateWeaponView(weaponData)
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_HP, function(hp, maxHp)
    self:updateHp(hp, maxHp)
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_BULLET, function(count)
    self:updateBulletCount(count)
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_WEAPON_VIEW, function(index)
    self:changeWeaponView(index)
  end)
  Lib.subscribeEvent(Event.EVENT_RIDE_ON_CAR, function()
    self:setVisible(false)
    AbilityManager:useDriveAbility()
  end)
  Lib.subscribeEvent(Event.EVENT_RIDE_OFF_CAR, function()
    self:setVisible(true)
    local weaponId = self:onItemSelect(self.selectIndex)
    Me:sendPacket({
      pid = "changeWeapon2s",
      weaponId = weaponId,
      index = self.selectIndex - 1
    })
  end)
  Lib.subscribeEvent(Event.EVENT_ENTER_UNLOCK_CAR, function()
    self:setVisible(false)
    Lib.showScreenMask(true)
  end)
  Lib.subscribeEvent(Event.EVENT_ENTER_UNLOCK_DOOR, function()
    self:setVisible(false)
  end)
  Lib.subscribeEvent(Event.EVENT_EXIT_UNLOCK_CAR, function()
    self:setVisible(true)
    Lib.showScreenMask(false)
  end)
  Lib.subscribeEvent(Event.EVENT_EXIT_UNLOCK_DOOR, function()
    self:setVisible(true)
    Me.weapon:initAction()
  end)
  Lib.subscribeEvent(Event.EVENT_IN_WEAPON, function(dropData)
  end)
  Lib.subscribeEvent(Event.EVENT_ITEM_DATA_HANDBAG, function(data)
    self:updateData(data)
  end)
  Lib.subscribeEvent(Event.EVENT_ITEM_DATA_CLOTHESBAG, function(data, index)
    self:onClickItem(index)
  end)
  for i = 1, 3 do
    self.DefaultWindow["dropWeapon" .. i].onMouseClick = function()
      self:onPickViewClick(i)
    end
  end
  for i = 1, 4 do
    self.weaponLayout["item" .. i].Button.onMouseClick = function()
      self:onClickItem(i)
    end
  end
  Lib.subscribeEvent(Event.EVENT_RETICLE_SCALING, function(isHead)
    self:reticleScaling(isHead)
  end)
  Lib.subscribeEvent(Event.EVENT_ROGUELIKE_ENEMY_HURT, function(color)
    self:setReticleHit(color)
  end)
  Lib.subscribeEvent(Event.EVENT_RESET_ITEM_SELECT, function()
    self:onClickItem(1)
  end)
  self:showDropWeapon()
  
  function self.jumpBtn.onMouseClick()
    -- Lib.openWindow("setting")
    Blockman.instance:setKeyPressing("key.jump", true)
    World.LightTimer("jump", 1, function()
      Blockman.instance:setKeyPressing("key.jump", false)
    end)
    self:getAllDropItemClient()

    -- Air Jump Hack
    local motion = Me.motion
    if motion then
        motion.y = 0.5 -- Apply upward velocity
        Me.motion = motion
    end
  end
  
  function self.DefaultWindow.closeButton.onMouseClick()
    self.DefaultWindow:setVisible(false)
  end
  
  self:showMeleeWeaponView()
  
  function self.DefaultWindow.turnthepage.leftButton.onMouseClick()
    self:preDropWeaponView()
  end
  
  function self.DefaultWindow.turnthepage.rightButton.onMouseClick()
    self:nextDropWeaponView()
  end
  
  local fistTimer
  
  function self.fistButton.onMouseButtonDown()
    isCharge = false
    local tick = 0
    if fistTimer then
      fistTimer()
    end
    fistTimer = World.LightTimer("fistTimer", 1, function()
      tick = tick + 1
      if not Me.onGround or Me:checkIsState(Define.CHARACTER_STATE_TYPE.SKILL) or Me:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) or Me:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) or Me:checkIsState(Define.CHARACTER_STATE_TYPE.CARRY) then
      elseif Me.weapon.getChargeSkill and Me.weapon:getChargeSkill() == nil then
        print("\230\178\161\230\156\137\232\147\132\229\138\155\230\138\128\232\131\189")
      elseif 5 < tick then
        isCharge = true
        fistTimer = nil
        print("======recharg==")
        Me:changeState(Define.CHARACTER_STATE_TYPE.ENERGY)
      else
        return true
      end
    end)
    pressTickCount = World.CurWorld:getTickCount()
  end
  
  function self.fistButton.onMouseButtonUp()
    if Me:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) or Me:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) then
      return
    end
    if fistTimer then
      fistTimer()
    end
    if Me:checkIsState(Define.CHARACTER_STATE_TYPE.CARRY) then
      local msg = Lang:toText("weapon.carry.cant.use")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      return
    end
    if Me:checkIsState(Define.CHARACTER_STATE_TYPE.ENERGY) then
      Me:resetRecharge()
    end
    if not isCharge then
      Me:changeState(Define.CHARACTER_STATE_TYPE.SKILL)
    end
    isCharge = false
  end
  
  self:initCarrier()
  Lib.subscribeEvent(Event.EVENT_MELEE_TWINKLE, function(index)
    self:showMeleeTwinkle(index)
  end)
  Lib.subscribeEvent(Event.EVENT_STOP_MELEE_TWINKLE, function()
    self:stopMeleeTwinkle()
  end)
  Lib.subscribeEvent(Event.EVENT_MELEE_DESTROY, function(index, newIndex)
    self:showMeleeDestroy(index, newIndex)
  end)
  self:initATMKick()
end

function M:initCarrier()
  Lib.subscribeEvent(Event.EVENT_CHARACTER_STATE_ON_GROUND_UPDATE_BTN, function(param)
    if param.triggerType == "Enter" then
      self.carrierBtn:setVisible(true)
      self.throwBtn:setVisible(false)
      self.userId = param.userId
    elseif self.userId == param.userId then
      self.carrierBtn:setVisible(false)
      self.throwBtn:setVisible(false)
      self.userId = nil
    end
  end)
  Lib.subscribeEvent(Event.EVENT_CHARACTER_STATE_ON_GROUND_CARRY_SUCCESS, function(userId, vis)
    if self.userId == userId then
      if vis then
        self.carrierBtn:setVisible(not vis)
        self.throwBtn:setVisible(vis)
      else
        self.carrierBtn:setVisible(vis)
        self.throwBtn:setVisible(vis)
      end
    end
  end)
  
  function self.throwBtn.onMouseClick()
    Me:tryThrowPlayer(self.userId)
  end
  
  function self.carrierBtn.onMouseClick()
    Me:tryCarryPlayer(self.userId)
  end
end

function M:initATMKick()
  Lib.subscribeEvent(Event.EVENT_NEAR_ATM, function(userId, vis)
    self.kickBtn:setVisible(true)
  end)
  Lib.subscribeEvent(Event.EVENT_LEAVE_ATM, function(userId, vis)
    self.kickBtn:setVisible(false)
  end)
  
  function self.kickBtn.onWindowTouchDown()
    local skillName = "myplugin/" .. World.cfg.kickATMSkill
    Me:changeState(Define.CHARACTER_STATE_TYPE.SKILL, {skillName = skillName, isKickATM = true})
  end
end

function M:updateWeaponView(weaponData)
end

function M:updateHp(hp, maxHp)
  self.curHp = hp
  self.maxHp = maxHp or self.maxHp
  maxHp = Me:getMaxHp()
  local bar
  for i, v in ipairs(self.barList) do
    v:setVisible(false)
  end
  local percent = hp / maxHp
  if 0.8 < percent then
    bar = self.barList[1]
  elseif 0.3 < percent then
    bar = self.barList[2]
  else
    bar = self.barList[3]
  end
  bar:setVisible(true)
  bar:setProgress(percent)
end

function M:openAuxiliaryTargeting()
  if self.viewFovAngleTimer then
    self.viewFovAngleTimer()
    self.viewFovAngleTimer = nil
    Me.weapon:setOnOpenAimAt(false)
  end
  if not Me.weapon then
    return
  end
  local curViewFovAngle = Blockman.instance:getViewFovAngle()
  local launcher = Me.weapon:getLauncher()
  local targetViewFovAngle = launcher.openAim or initViewFovAngle
  Blockman.instance:setViewFovAngle(targetViewFovAngle)
  local dif = targetViewFovAngle - curViewFovAngle
end

function M:closeAuxiliaryTargeting()
  if self.viewFovAngleTimer then
    self.viewFovAngleTimer()
    self.viewFovAngleTimer = nil
    Me.weapon:setOnOpenAimAt(false)
  end
  if Me.weapon then
  end
  Blockman.instance:setViewFovAngle(initViewFovAngle)
end

function M:reticleScaling(isHead)
  if self.scalingTimer then
    self.scalingTimer()
    self.scalingTimer = nil
  end
  local endSize = reticleSize
  if isHead then
    endSize = reticleSize * HitMainScale
  else
    endSize = reticleSize * HitSubScale
  end
  self:setReticleAccuracy(endSize)
  local curReticleSize = self.imgReticle:getSize().width[2]
  local reticleShrinkSpeed = (curReticleSize - reticleSize) / reticleShrinkSpeedTimer
  self.scalingTimer = Me:timer(1, function()
    local shrinkEndSize = reticleSize
    local shrinkSize = self.imgReticle:getSize().width[2] - reticleShrinkSpeed
    self:setReticleAccuracy(shrinkSize)
    if shrinkEndSize <= shrinkSize then
      return true
    end
  end)
end

function M:setReticleAccuracy(accuracy)
  self.imgReticle:setSize(UDim2.new(0, accuracy, 0, accuracy))
  self.imgReticleHit:setSize(UDim2.new(0, accuracy, 0, accuracy))
end

local rotationV3 = {
  x = 0,
  y = 0,
  z = 1
}

local function rotationToQuaternion(v3, rotation)
  local halfRotation = 0.5 * rotation
  local halfSin = math.sin(halfRotation)
  return {
    w = math.cos(halfRotation),
    x = v3.x * halfSin,
    y = v3.y * halfSin,
    z = v3.z * halfSin
  }
end

function M:setReticleHit(color)
  self.alpha = hitReticleInitialAlpha
  self.hitSize = hitReticleSize
  local degree = math.random(RotationRang[1] + 100, RotationRang[2] + 100) - 100
  local leftQ = rotationToQuaternion(rotationV3, math.rad(degree))
  self.imgReticleHit:setProperty("Rotation", "w:" .. leftQ.w .. " x:" .. leftQ.x .. " y:" .. leftQ.y .. " z:" .. leftQ.z)
  if not self.reticleHitTimer then
    self.reticleHitTimer = LuaTimer:scheduleTimer(function()
      self.alpha = math.max(0, self.alpha - hitReticleDisappearSpeed)
      self.hitSize = self.hitSize + 1
      self.imgReticleHit:setAlpha(self.alpha)
      if self.alpha <= 0 then
        LuaTimer:cancel(self.reticleHitTimer)
        self.reticleHitTimer = nil
      end
    end, hitReticleDisappearTime)
  end
end

function M:getAllDropItemClient()
  local tab = {}
  local curTick = World.CurWorld:getTickCount()
  for _, obj in ipairs(World.CurWorld:getAllObject()) do
    if obj.className == "DropItemClient" then
      if not obj.itemData.bornTick then
        obj.itemData.bornTick = curTick
      elseif curTick - obj.itemData.bornTick >= 20 then
        tab[obj.objID] = obj
      end
    end
  end
  return tab
end

function M:showDropWeapon()
  if self.pickTimer then
    return
  end
  self.inObjIDs = {}
  self.pickTimer = World.LightTimer("pickTimer", 3, function()
    local curHp = Me:getCurHp()
    if 0 < curHp then
      local isHas
      local mePos = Lib.copy(Me:getPosition())
      mePos.y = mePos.y + 0.5
      local curObjIds = {}
      for oid, dropItem in pairs(self:getAllDropItemClient()) do
        local pos = dropItem:getPosition()
        local dis = Lib.getPosDistance(mePos, pos)
        if dis < 1.3 then
          local itemData = dropItem.itemData
          itemData.objID = oid
          if GoodsBaseConfig:isCostItem(itemData.itemID) then
            self:pickWeapon(itemData.itemID, 1, oid)
          else
            curObjIds[oid] = itemData
          end
          isHas = true
        end
      end
      if isHas then
        for objID, data in pairs(self.inObjIDs) do
          if not curObjIds[objID] then
            self:pickViewRemoveItem(data)
          end
        end
        for objID, data in pairs(curObjIds) do
          if not self.inObjIDs[objID] then
            local index, b = self:getInsertIndex()
            if b then
              self:pickWeapon(data.itemID, index, objID)
            else
              self:pickViewAddItem(data)
            end
          end
        end
      else
        self.DefaultWindow:setVisible(false)
        self.pickViewItems = {}
      end
      self.inObjIDs = curObjIds
    end
    return true
  end)
end

function M:pickViewAddItem(item)
  if item.itemID == Define.GoldItemID then
    print(debug.traceback("pickViewAddItem"))
  end
  for _, data in ipairs(self.pickViewItems) do
    if data.objID == item.objID then
      return
    end
  end
  table.insert(self.pickViewItems, item)
  self:updatePickView()
end

function M:pickViewRemoveItem(item)
  local index
  for i, data in ipairs(self.pickViewItems) do
    if data.objID == item.objID then
      index = i
    end
  end
  if index then
    table.remove(self.pickViewItems, index)
    self:updatePickView()
  end
end

function M:updatePickView()
  if #self.pickViewItems == 0 then
    self.DefaultWindow:setVisible(false)
  else
    self.DefaultWindow:setVisible(true)
    local totalPage = math.ceil(#self.pickViewItems / 3)
    if totalPage < self.pickViewIndex then
      self.pickViewIndex = 1
    end
    for i = 1, 3 do
      local index = (self.pickViewIndex - 1) * 3 + i
      local data = self.pickViewItems[index]
      local layout = self.DefaultWindow["dropWeapon" .. i]
      if data then
        layout:setVisible(true)
        local conf = WeaponConfig:getCfgById(data.itemID)
        if conf then
          layout.weaponImage:setImage(conf.longItemIcon)
          if not data.isMelee then
            layout.Imagebullet:setVisible(true)
            layout.bulletCount:setVisible(true)
            layout.bulletCount:setText(data.bulletCount)
          else
            layout.Imagebullet:setVisible(false)
            layout.bulletCount:setVisible(false)
          end
        else
          layout:setVisible(false)
        end
      else
        layout:setVisible(false)
      end
    end
    self.DefaultWindow.turnthepage.hText:setText(self.pickViewIndex)
    self.DefaultWindow.turnthepage.tText:setText("/" .. totalPage)
    if self.pickViewIndex == 1 then
      self.DefaultWindow.turnthepage.leftButton:setNormalImage("set:g2055_button.json image:btn_0_left02")
    else
      self.DefaultWindow.turnthepage.leftButton:setNormalImage("set:g2055_button.json image:btn_0_left01")
    end
    if self.pickViewIndex == totalPage then
      self.DefaultWindow.turnthepage.rightButton:setNormalImage("set:g2055_button.json image:btn_0_right02")
    else
      self.DefaultWindow.turnthepage.rightButton:setNormalImage("set:g2055_button.json image:btn_0_right01")
    end
  end
end

function M:showMeleeWeaponView()
  self.isWeaponView = false
  self.btnAtkBtn:setVisible(false)
  self.ReticleHit:setVisible(false)
  self.Center:setVisible(false)
  self.fistButton:setVisible(true)
end

function M:showGunWeaponView()
  self.isWeaponView = true
  self.btnAtkBtn:setVisible(true)
  self.ReticleHit:setVisible(true)
  self.Center:setVisible(true)
  self.fistButton:setVisible(false)
end

function M:showCarView()
end

function M:onClickItem(index)
  if Me:checkIsState(Define.CHARACTER_STATE_TYPE.GROUND) or Me:checkIsState(Define.CHARACTER_STATE_TYPE.DIE) or Me:checkIsState(Define.CHARACTER_STATE_TYPE.SKILL) or Me:checkIsState(Define.CHARACTER_STATE_TYPE.CARRY) then
    return
  end
  if self.selectIndex == index then
    return
  end
  if 1 < index then
    local data = self.weaponList[index - 1]
    if not data then
      return
    end
  end
  local weaponId = self:onItemSelect(index)
  Me:sendPacket({
    pid = "changeWeapon2s",
    weaponId = weaponId,
    index = index - 1
  })
  self.weaponLayout["item" .. self.selectIndex].select:setVisible(false)
  self.weaponLayout["item" .. index].select:setVisible(true)
  self.selectIndex = index
  Me.selectIndex = index
end

function M:onItemSelect(index)
  local weaponId = tonumber(World.cfg.defaultWeaponID)
  local isWeaponView
  if 1 < index then
    local data = self.weaponList[index - 1]
    if not data then
      return
    end
    weaponId = data.itemID
    isWeaponView = not data.isMelee
  end
  local eventData = {}
  eventData.weaponId = weaponId
  eventData.isCanBuyBullet = isWeaponView
  eventData.isBulletFull = true
  if isWeaponView then
    local conf = WeaponConfig:getCfgById(weaponId)
    local data = self.weaponList[index - 1]
    eventData.isBulletFull = conf.bulletCount == data.bulletCount
    eventData.bulletCount = data.bulletCount
  end
  Lib.emitEvent(Event.EVENT_GOODS_SHELF_UPDATE_WEAPON_SWITCH, eventData)
  local jsonCfg = WeaponConfig:getWeaponJsonById(weaponId)
  if not isWeaponView then
    self:showMeleeWeaponView()
    AbilityManager:useFistAbility(jsonCfg.camera)
  else
    self:showGunWeaponView()
    AbilityManager:useGunAbility(jsonCfg.launcher.camera)
  end
  Me.speedState = Define.SPEED_STATE.NONE
  return weaponId
end

function M:getInsertIndex()
  for i = 1, 3 do
    local data = self.weaponList[i]
    if not data then
      return i + 1, true
    end
  end
  if self.selectIndex == 1 then
    return 2
  else
    return self.selectIndex
  end
end

function M:pickWeapon(itemID, index, objID)
  print("M:pickWeapon(itemID, index, objID)", itemID, index, objID)
  local clonePosition = Vector3.new(0, 0, 1.5)
  local rotation = Vector3.new(-Me:getRotationPitch(), -Me:getRotationYaw(), -Me:getRotationRoll())
  Lib.rotate(clonePosition, rotation)
  local pos = Me:getPosition() + clonePosition
  Me:playSoundByKey("g2055_item_pickWeapon")
  Me:sendPacket({
    pid = "pickItemFromClient",
    type = Define.InventoryType.HandBag,
    index = index - 1,
    itemID = itemID,
    objID = objID,
    pos = pos
  })
end

function M:updateItemView()
  for i = 1, 3 do
    local data = self.weaponList[i]
    local layout = self.weaponLayout["item" .. i + 1]
    if data then
      local conf = WeaponConfig:getCfgById(data.itemID)
      local icon = conf.itemIcon
      layout.weaponImage:setImage(icon)
      if not data.isMelee or data.itemID == 101001 or data.itemID == 101007 then
        layout.Imagebullet:setVisible(true)
        if 1 > data.bulletCount then
          layout.bulletCountText:setText("[colour='FFFF0000']" .. data.bulletCount)
        else
          layout.bulletCountText:setText("[colour='FFFFFFFF']" .. data.bulletCount)
        end
      else
        layout.bulletCountText:setText("")
        layout.Imagebullet:setVisible(false)
      end
      layout.weaponImage:setVisible(true)
      layout.bulletCountText:setVisible(true)
    else
      layout.weaponImage:setVisible(false)
      layout.bulletCountText:setVisible(false)
      layout.Imagebullet:setVisible(false)
    end
  end
end

function M:updateBulletCount(count)
  local i = self.selectIndex
  local layout = self.weaponLayout["item" .. i]
  layout.bulletCountText:setText(count)
end

function M:updateData(data)
  if self.weaponList and self.selectIndex then
    local index = self.selectIndex - 1
    if self.weaponList[index] and data[index] and self.weaponList[index].guid == data[index].guid then
      self.weaponList = data
      self:updateItemView()
      return
    end
  end
  self.weaponList = data
  self:onItemSelect(self.selectIndex)
  self:updateItemView()
end

function M:onPickViewClick(index)
  index = (self.pickViewIndex - 1) * 3 + index
  local inDrop = self.pickViewItems[index]
  print("onPickViewClick index itemID", index, inDrop.itemID)
  if self.selectIndex == 1 then
    self:pickWeapon(inDrop.itemID, 2, inDrop.objID)
  else
    self:pickWeapon(inDrop.itemID, self.selectIndex, inDrop.objID)
  end
  self:updatePickView()
end

function M:preDropWeaponView()
  if self.pickViewIndex < 2 then
    return
  end
  self.pickViewIndex = self.pickViewIndex - 1
  self:updatePickView()
end

function M:nextDropWeaponView()
  if not self.pickViewItems or self.pickViewIndex >= math.ceil(#self.pickViewItems / 3) then
    return
  end
  self.pickViewIndex = self.pickViewIndex + 1
  self:updatePickView()
end

function M:changeWeaponView(index)
  if self.selectIndex == 1 then
    return
  end
  self:onItemSelect(index)
  self.weaponLayout["item" .. self.selectIndex].select:setVisible(false)
  self.weaponLayout["item" .. index].select:setVisible(true)
  self.selectIndex = index
  Me.selectIndex = index
end

function M:showMeleeTwinkle(index)
  local alpha = 1
  local onCount = 10
  local layout = self.weaponLayout["item" .. index + 1]
  if not self.meleeTwinkleTimer[index] then
    local isCut = true
    self.meleeTwinkleTimer[index] = World.LightTimer("showMeleeTwinkle", 1, function()
      local one = 1 / onCount
      if isCut then
        alpha = alpha - one
        if alpha < 0 then
          alpha = 0
        end
      else
        alpha = alpha + one
        if 1 < alpha then
          alpha = 1
        end
      end
      layout.weaponImage:setAlpha(alpha)
      if alpha == 0 then
        isCut = false
      end
      if alpha == 1 then
        isCut = true
      end
      return true
    end)
  end
end

function M:showMeleeDestroy(index, newIndex)
  if self.meleeTwinkleTimer[index] then
    self.meleeTwinkleTimer[index]()
    local layout = self.weaponLayout["item" .. index + 1]
    layout.weaponImage:setAlpha(1)
    self.meleeTwinkleTimer[index] = nil
  end
  self:changeWeaponView(newIndex + 1)
end

function M:stopMeleeTwinkle()
  local index = self.selectIndex - 1
  if self.meleeTwinkleTimer[index] then
    self.meleeTwinkleTimer[index]()
    local layout = self.weaponLayout["item" .. index + 1]
    layout.weaponImage:setAlpha(1)
    self.meleeTwinkleTimer[index] = nil
  end
end
