local WinGoodsShelfIconWeapon = M
local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local GoodsShelfClient = T(Lib, "GoodsShelfClient")

function WinGoodsShelfIconWeapon:initUI()
  local buttonBuy = self:child("ButtonBuy")
  self.textPrice = self:child("TextPrice")
  self.imagePriceBg = self:child("ImagePriceBg")
  self.buttonBuy = self:child("ButtonBuy")
end

function WinGoodsShelfIconWeapon:initEvent()
  function self.buttonBuy.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    
    self:openDetailShop()
  end
end

function WinGoodsShelfIconWeapon:initView(param)
  self.info = param or {}
  self.price = nil
  self.objID = param.objID
  local id = param.shelfID or 0
  local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
  if shelfConfigItem then
    self.type = shelfConfigItem.type or Define.GoodsShelf.Type.None
    self.info.goodsList = shelfConfigItem.goodsList or {}
    self.textPrice:setVisible(false)
    self.imagePriceBg:setVisible(false)
    self:child("ImageIcon"):setImage(shelfConfigItem.buttonIcon)
    self:child("Text"):setText(Lang:toText(shelfConfigItem.buttonText))
  end
end

function WinGoodsShelfIconWeapon:buyWeapon()
  if self.waitResponse then
    return
  end
  Me:playSoundByKey("g2055_commonButtonSound")
  if Me:getCurrencyById(self.currencyType) < self.price then
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("tips.no.money"))
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
      local msg = Lang:toText("goods_shelf.purchase.succeed")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      Me:playSoundByKey("g2055_commonBuySound")
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinGoodsShelfIconWeapon:updateView()
  self.imagePriceBg:setVisible(false)
  if self.price then
    self.textPrice:setText(self.price)
    self.imagePriceBg:setVisible(true)
  end
end

function WinGoodsShelfIconWeapon:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfIconWeapon:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinGoodsShelfIconWeapon:openDetailShop()
  local param = Lib.copy(self.info)
  UI:openCustomWindow("./UI/goods_shelf/win_goods_shelf_armory", "", param)
end

return WinGoodsShelfIconWeapon
