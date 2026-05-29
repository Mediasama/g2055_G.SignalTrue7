local WeaponConfig = require("common.config.weapon_config")
local Player = _ENV.Player

function Player:getCurWeaponFiredBullet()
  local curWeaponId = self:getCurWeaponID()
  if curWeaponId == nil then
    return 0
  end
  local b = self:isCanFillBullet(curWeaponId)
  if not b then
    return 0
  end
  local conf = WeaponConfig:getCfgById(curWeaponId)
  return conf.bulletCount - self.weapon:getBulletCount()
end

function Player:buyBullet(weaponId)
  local conf = WeaponConfig:getCfgById(weaponId)
  if self:isCanFillBullet(weaponId) then
    local curCoin = self:getCurrencyById(conf.bulletCurrencyType)
    local buyBulletCount = self:getCurWeaponFiredBullet()
    local cnt = math.floor(curCoin / conf.bulletPrice)
    if buyBulletCount < cnt then
      cnt = buyBulletCount
    end
    if cnt == 0 then
      return "bullet.shop.buy.no.need"
    end
    local price = cnt * conf.bulletPrice
    if self:payCurrencyById(conf.bulletCurrencyType, price, Define.CurrencyReason.Bullet) then
      self:fillWeaponBullet(weaponId, cnt)
      return nil
    else
      return "tips.no.money"
    end
  else
    return "bullet.shop.buy.fail"
  end
end

function Player:getCurWeaponID()
  if not self.weapon or self.weapon.id == World.cfg.defaultWeaponID then
    return nil
  end
  return self.weapon.id
end

function Player:isCanFillBullet(itemID)
  if not self.handSelectIndex then
    return
  end
  if not self.weapon or self.weapon.id == World.cfg.defaultWeaponID then
    return
  end
  if self.weapon.isMelee then
    return
  end
  return self.weapon.id == itemID
end

function Player:fillWeaponBullet(itemID, fillBulletCount)
  local b = self:isCanFillBullet(itemID)
  if b then
    local inventory = self:getInventory(Define.InventoryType.HandBag)
    local conf = WeaponConfig:getCfgById(itemID)
    local addBullet = fillBulletCount or conf.bulletCount
    local newBullet = addBullet + inventory[self.handSelectIndex].bulletCount
    if newBullet > conf.bulletCount then
      newBullet = conf.bulletCount
    end
    local d = {}
    d.access_type = Define.ReportGetAccessType.Shop
    d.item_type = Define.ReportItemType.Bullet
    d.item_id = itemID
    d.gain_amount = addBullet
    d.current_num = conf.bulletCount
    self:reportItemGet(d)
    inventory[self.handSelectIndex].bulletCount = newBullet
    self.weapon.bulletCount = newBullet
    self:saveInventory(Define.InventoryType.HandBag, inventory)
  end
end

function Player:resetDefaultWeapon()
  if not self.weapon or self.weapon.id == World.cfg.defaultWeaponID then
    return
  end
  self.handSelectIndex = 0
  self:changeWeapon(World.cfg.defaultWeaponID)
  self:sendPacket({
    pid = "changeSelectWeapon",
    index = self.handSelectIndex
  })
end

function Player:destroyMeleeWeapon(dropIndex)
  local index = 0
  local itemID
  local inventory = self:getInventory(Define.InventoryType.HandBag)
  for i = 1, 3 do
    local data = inventory[i]
    if data and i ~= dropIndex then
      index = i
      itemID = data.itemID
      break
    end
  end
  self.handSelectIndex = index
  local weaponID = itemID or World.cfg.defaultWeaponID
  self:changeWeapon(weaponID)
  self:deleteHandBag(dropIndex)
  self:sendPacket({
    pid = "onMeleeDestroy",
    index = dropIndex,
    newIndex = self.handSelectIndex
  })
end
