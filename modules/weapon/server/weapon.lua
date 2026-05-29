local Weapon = Lib.class("Weapon")
local WeaponConfig = T(Config, "WeaponConfig")

function Weapon:ctor(owner, id)
  self.id = id
  self.owner = owner
  self.cfg = WeaponConfig:getCfgById(id)
  self.jsonCfg = WeaponConfig:getWeaponJsonById(id)
  if not self.jsonCfg.launcher then
    self.isMelee = true
  end
  self:init()
  if owner then
    self.owner:changeWeapon2C(self.cfg.id)
  end
  Lib.logDebug("prop== = ", Lib.v2s(owner.prop, 4))
end

function Weapon:init()
  self:initWeaponSkin()
  if not self.isMelee then
    self.moveSpeed = self.jsonCfg.launcher.moveSpeed or 0.2
    self.moveAcc = self.jsonCfg.launcher.moveAcc or 2
  else
    self.moveSpeed = self.jsonCfg.moveSpeed or 0.2
    self.moveAcc = self.jsonCfg.moveAcc or 2
  end
  World.Timer(1, function()
    self:checkMeleeUseCount()
  end)
end

function Weapon:release()
  self:clearSkin()
  self:saveBulletCount()
  self.owner:recoverMoveSpeed()
end

function Weapon:saveBulletCount()
  if not self.bulletCount then
    return
  end
  local list = self.owner:getInventory(Define.InventoryType.HandBag)
  local itemData = list[self.slotIndex]
  if itemData then
    itemData.bulletCount = self.bulletCount
    self.owner:saveInventory(Define.InventoryType.HandBag, list)
  end
end

function Weapon:initWeaponSkin()
  if not self.cfg.part then
    return
  end
  self.owner:changeSkinPart(self.cfg.part)
  local action = self.jsonCfg.action or self.jsonCfg.launcher.action
  if not action then
    return
  end
  self.owner:setActionIdle(action.idle)
  self.owner:setActionRun(action.run)
end

function Weapon:clearSkin()
  if not self.cfg.part then
    return
  end
  local t = Lib.copy(self.cfg.part)
  for k, v in pairs(t) do
    t[k] = ""
  end
  self.owner:changeSkinPart(t)
end

function Weapon:getCfgID()
  return self.cfg.id
end

function Weapon:getBulletConfig()
  return self.jsonCfg and self.jsonCfg.bullet
end

function Weapon:getName()
  return self.cfg.name
end

function Weapon:cutBullet(num, index)
  if not self.bulletCount then
    local list = self.owner:getInventory(Define.InventoryType.HandBag)
    local itemData = list[index]
    if not itemData then
      return
    end
    self.bulletCount = itemData.bulletCount
    self.firstBulletCount = self.bulletCount
  end
  self.bulletCount = self.bulletCount - num
  self.owner:recordUseBullet(self.id, num)
  self.slotIndex = index
  if self.bulletCount <= 0 then
    self.bulletCount = 0
    local d = {}
    d.access_type_drop = Define.ReportCostAccessType.Self
    d.item_type = Define.ReportItemType.Bullet
    d.item_id = self.id
    d.drop_amount = self.firstBulletCount
    d.current_num = 0
    self.owner:reportItemCost(d)
  end
  self:saveBulletCount()
end

function Weapon:getBulletCount()
  if self.isMelee then
    return -1
  end
  if not self.bulletCount then
    local list = self.owner:getInventory(Define.InventoryType.HandBag)
    local index = self.owner.handSelectIndex or 0
    local itemData = list[index]
    if not itemData then
      return -1
    end
    self.bulletCount = itemData.bulletCount
  end
  return self.bulletCount
end

function Weapon:getHitBackDistance()
  return self.jsonCfg.hurtDistance or 1, self.jsonCfg.hurtTime or 0
end

function Weapon:cutMeleeCount()
  local index = self.owner.handSelectIndex
  local list = self.owner:getInventory(Define.InventoryType.HandBag)
  local itemData = list[index]
  if not itemData then
    return
  end
  itemData.bulletCount = itemData.bulletCount - 1
  self.owner:saveInventory(Define.InventoryType.HandBag, list)
  self:checkMeleeUseCount()
end

function Weapon:checkMeleeUseCount()
  if not self.isMelee then
    return
  end
  local index = self.owner.handSelectIndex
  local list = self.owner:getInventory(Define.InventoryType.HandBag)
  local itemData = list[index]
  if not itemData then
    return
  end
  if itemData.bulletCount == 0 then
    self.owner:destroyMeleeWeapon(index)
  elseif itemData.bulletCount <= self.cfg.bulletCount / 10 then
    self.owner:sendPacket({
      pid = "onMeleeTwinkle",
      index = index,
      guid = itemData.guid
    })
  end
end

return Weapon
