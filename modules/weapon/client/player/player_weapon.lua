local Player = _ENV.Player
local Weapon = require("client.weapon")
local Melee = require("client.melee")
local isWeaponFireActive = true
local WeaponConfig = T(Config, "WeaponConfig")

function Player:initWeaponEvent()
  Lib.lightSubscribeEvent("SwitchWeaponActive", Event.EVENT_SWITCH_WEAPON_ACTIVE, function(isOpen)
  end)
  Lib.lightSubscribeEvent("FIRE_TOUCH_DOWN", Event.EVENT_FIRE_TOUCH_DOWN, function()
    if self.weapon and isWeaponFireActive then
      self.weapon:openFire()
    end
  end)
  Lib.lightSubscribeEvent("FIRE_TOUCH_UP", Event.EVENT_FIRE_TOUCH_UP, function()
    if self.weapon and isWeaponFireActive then
      self.weapon:closeFire()
    end
  end)
end

function Player:changeWeapon(id)
  Lib.logDebug("----------->change weapon to " .. id)
  if self.weapon then
    self.weapon:release()
    Lib.emitEvent(Event.EVENT_STOP_MELEE_TWINKLE)
  end
  local cfg = WeaponConfig:getCfgById(id)
  if cfg.weaponType == 1 then
    self.weapon = Melee.new(self, id)
  else
    self.weapon = Weapon.new(self, id)
    self:updateBodyYaw()
  end
  if not self.isInitWeaponEvent then
    self.isInitWeaponEvent = true
    self:initWeaponEvent()
  end
  self.isPlayEntityMotionTick = 0
end

function Player:syncFireInHall(touch)
  self:sendPacket({
    pid = "onSyncFireInHall",
    objID = self.objID,
    touch = touch,
    weaponId = self.weapon:getCfgID()
  })
end

function Player:setWeaponData(weaponData)
  self.weaponData = weaponData
end

function Player:getMainBulletCount()
  if not self.selectIndex or not self.handBagData then
    return -1
  end
  local data = self.handBagData
  local index = self.selectIndex - 1
  return data[index] and data[index].bulletCount or 0
end

function Player:getSubBulletCount()
  return self.weaponData[2].bulletCount
end

function Player:cutBullet(num)
  num = num or 1
  local index = self.selectIndex - 1
  local itemData = self.handBagData[index]
  if itemData then
    local count = itemData.bulletCount or 0
    count = count - num
    if count < 0 then
      count = 0
      num = itemData.bulletCount
    end
    itemData.bulletCount = count
    self:sendPacket({
      pid = "cutBullet",
      index = index,
      num = num
    })
    Lib.emitEvent(Event.EVENT_CHANGE_BULLET, count)
  end
end

function Player:setKillEnemy(attackEntity)
  if self.attackEntity then
    self.attackEntity:setEdge(false, {
      1,
      0,
      0,
      1
    })
  end
  attackEntity:setEdge(true, {
    1,
    0,
    0,
    1
  })
  self.attackEntity = attackEntity
end

function Player:removeKillEnemy(killEntity)
  if killEntity == self.attackEntity then
    killEntity:setEdge(false, {
      1,
      0,
      0,
      1
    })
    self.attackEntity = nil
  end
end

function Player:setHurtEnemyName(objID)
  local hurtEntity = World.CurWorld:getEntity(objID)
  self.hurtEnemyID = objID
  self.hurtEnemyName = hurtEntity:getName()
end

function Player:getHurtEnemyName()
  return self.hurtEnemyName, self.hurtEnemyID
end
