local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local WinGoodsShelfIconClothes = M

function WinGoodsShelfIconClothes:initUI()
  self.btnBuy = self:child("ButtonBuy")
end

function WinGoodsShelfIconClothes:initEvent()
  function self.btnBuy.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    
    self:openClosetShop()
  end
end

function WinGoodsShelfIconClothes:initView(param)
  self.info = param
  local id = param.shelfID or 0
  local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
  if shelfConfigItem then
    self:child("ImageIcon"):setImage(shelfConfigItem.buttonIcon)
    self:child("Text"):setText(Lang:toText(shelfConfigItem.buttonText))
  end
  self:updateView()
end

function WinGoodsShelfIconClothes:updateView()
end

function WinGoodsShelfIconClothes:openClosetShop()
  local param = Lib.copy(self.info)
  UI:openCustomWindow("./UI/goods_shelf/win_goods_shelf_closet", "", param)
end

function WinGoodsShelfIconClothes:onOpen(param)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfIconClothes:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinGoodsShelfIconClothes
