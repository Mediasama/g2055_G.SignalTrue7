local WinGoodsShelfIconBullet = M
local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local GoodsShelfClient = T(Lib, "GoodsShelfClient")

function WinGoodsShelfIconBullet:initUI()
  local buttonBuy = self:child("ButtonBuy")
  self.textPrice = self:child("TextPrice")
  self.imagePriceBg = self:child("ImagePriceBg")
  self.buttonBuy = self:child("ButtonBuy")
  self.textBulletCount = self:child("TextBulletCount")
end

function WinGoodsShelfIconBullet:closeSelf()
  if self.info and self.info.shelfID then
    Me:hideGoodsShelfIcon(nil, self.info.shelfID, nil)
  end
end

function WinGoodsShelfIconBullet:initEvent()
  function self.buttonBuy.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    
    self:buyBullet()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GOODS_SHELF_UPDATE_WEAPON_SWITCH, function(data)
    local weaponId = data.weaponId
    local isBulletFull = data.isBulletFull
    local isCanBuyBullet = data.isCanBuyBullet
    if not isCanBuyBullet or not not isBulletFull then
      self.price = 0
    else
      self:updateWeaponCfg(weaponId, data.bulletCount)
    end
    self:updateView()
  end)
end

function WinGoodsShelfIconBullet:initView(param)
  self.info = param
  self.objID = param.objID
  if not param.isCanFillBullet then
    self.price = 0
  end
  local id = param.shelfID or 0
  local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
  if shelfConfigItem then
    self.type = shelfConfigItem.type or Define.GoodsShelf.Type.None
    self:updateWeaponCfg(param.triggerParam.weaponId)
    self:child("ImageIcon"):setImage(shelfConfigItem.buttonIcon)
    self:child("Text"):setText(Lang:toText(shelfConfigItem.buttonText))
  end
  self:updateView()
end

function WinGoodsShelfIconBullet:updateWeaponCfg(weaponId, bulletCount)
  local goodsId = weaponId
  local config = GoodsShelfClient:export_getGoodsConfig(self.type, goodsId)
  if config then
    self.currencyType = config.bulletCurrencyType
    self.weaponId = config.id
    local totalBullet = config.bulletCount
    local bulletPrice = config.bulletPrice
    local curBulletCount = bulletCount or Me:getMainBulletCount()
    local curCoin = Me:getCurrencyById(config.bulletCurrencyType)
    local buyBulletCount = totalBullet - curBulletCount
    if bulletPrice > curCoin then
      self.price = 0
      self.buyBulletCount = 0
      self.noEnoughMoney = false
    else
      local cnt = math.floor(curCoin / bulletPrice)
      if buyBulletCount < cnt then
        cnt = buyBulletCount
      end
      self.price = cnt * bulletPrice
      self.buyBulletCount = cnt
      self.noEnoughMoney = true
    end
  end
end

function WinGoodsShelfIconBullet:buyBullet()
  if self.waitResponse then
    return
  end
  Me:playSoundByKey("g2055_commonButtonSound")
  if not self.noEnoughMoney then
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("tips.no.money"))
    return
  end
  if self.buyBulletCount == 0 then
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("bullet.shop.buy.no.need"))
    return
  end
  self.waitResponse = true
  local param = {
    shelfType = self.info.shelfType,
    shelfID = self.info.shelfID,
    type = self.type,
    id = self.weaponId
  }
  Me:C2S_RequestPurchaseGoods(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status == Define.GoodsShelf.PurchaseErrorCode.Succeed then
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("bullet.shop.buy.success"))
      self:closeSelf()
      Me:playSoundByKey("g2055_commonBuySound")
    else
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(rsp.msg))
    end
  end)
end

function WinGoodsShelfIconBullet:updateView()
  self.imagePriceBg:setVisible(false)
  if self.price == 0 then
    self.imagePriceBg:setVisible(false)
    return
  end
  if self.price then
    self.textPrice:setText(self.price)
    self.imagePriceBg:setVisible(true)
    self.textBulletCount:setText(string.format("X%d", self.buyBulletCount))
  end
end

function WinGoodsShelfIconBullet:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfIconBullet:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinGoodsShelfIconBullet
