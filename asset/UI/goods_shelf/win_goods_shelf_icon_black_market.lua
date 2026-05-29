local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local WinGoodsShelfIconBlackMarket = M

function WinGoodsShelfIconBlackMarket:initUI()
  self.btnBuy = self:child("ButtonBuy")
end

function WinGoodsShelfIconBlackMarket:initEvent()
  function self.btnBuy.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    
    self:openBlackMarket()
  end
end

function WinGoodsShelfIconBlackMarket:initView(param)
  self.info = param
  local id = param.shelfID or 0
  local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
  if shelfConfigItem then
    self:child("ImageIcon"):setImage(shelfConfigItem.buttonIcon)
    self:child("Text"):setText(Lang:toText(shelfConfigItem.buttonText))
  end
  self:updateView()
end

function WinGoodsShelfIconBlackMarket:updateView()
end

function WinGoodsShelfIconBlackMarket:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfIconBlackMarket:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinGoodsShelfIconBlackMarket:openBlackMarket()
  local param = Lib.copy(self.info)
  UI:openCustomWindow("./UI/goods_shelf/win_goods_shelf_black_market", "", param)
end

return WinGoodsShelfIconBlackMarket
