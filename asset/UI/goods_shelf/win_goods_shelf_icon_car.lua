local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local GoodsShelfClient = T(Lib, "GoodsShelfClient")
local WinGoodsShelfIconCar = M

function WinGoodsShelfIconCar:initUI()
  self.btnBuy = self:child("ButtonBuy")
  self.txtPrice = self:child("TextPrice")
  self.imgPriceBg = self:child("ImagePriceBg")
end

function WinGoodsShelfIconCar:initEvent()
  function self.btnBuy.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    
    local goodsInfo = self:getGoodsInfo()
    if #goodsInfo.goodsList > 1 then
      self:openDetailShop()
    else
      self:requestPurchase()
    end
  end
end

function WinGoodsShelfIconCar:initView(param)
  self.info = param
  local id = param.shelfID or 0
  local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
  if shelfConfigItem then
    self:child("ImageIcon"):setImage(shelfConfigItem.buttonIcon)
    self:child("Text"):setText(Lang:toText(shelfConfigItem.buttonText))
  end
  self:updateView()
end

function WinGoodsShelfIconCar:getGoodsInfo()
  if not self.info.goodsInfo then
    local result = {
      shelfType = Define.GoodsShelf.Type.None,
      shelfID = 0,
      type = Define.GoodsShelf.Type.None,
      id = 0,
      goodsList = {},
      price = 0
    }
    local id = self.info.shelfID or 0
    local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
    if shelfConfigItem then
      result.shelfType = self.info.shelfType
      result.shelfID = self.info.shelfID
      result.type = shelfConfigItem.type or Define.GoodsShelf.Type.None
      result.goodsList = shelfConfigItem.goodsList
      result.id = shelfConfigItem.goodsList[1] or 0
      local config = GoodsShelfClient:export_getGoodsConfig(result.type, result.id)
      if config then
        result.price = config.vehicle_price
      end
    end
    self.info.goodsInfo = result
  end
  return self.info.goodsInfo
end

function WinGoodsShelfIconCar:updateView()
  local goodsInfo = self:getGoodsInfo()
  if #goodsInfo.goodsList > 1 then
    self.txtPrice:setVisible(false)
    self.imgPriceBg:setVisible(false)
  else
    self.txtPrice:setText(goodsInfo.price)
    self.txtPrice:setVisible(true)
    self.imgPriceBg:setVisible(true)
  end
end

function WinGoodsShelfIconCar:requestPurchase()
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local goodsInfo = self:getGoodsInfo() or {}
  local param = Lib.copy(goodsInfo)
  player:C2S_RequestPurchaseGoods(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local msg = Lang:toText("goods_shelf.purchase.succeed")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      Me:playSoundByKey("g2055_changeCarsSound")
      Me:playSoundByKey("g2055_commonBuySound")
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinGoodsShelfIconCar:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfIconCar:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinGoodsShelfIconCar:openDetailShop()
  local param = Lib.copy(self.info)
  UI:openCustomWindow("./UI/goods_shelf/win_goods_shelf_car", "", param)
end

return WinGoodsShelfIconCar
