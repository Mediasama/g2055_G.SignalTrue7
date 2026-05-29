local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local GoodsShelfClient = T(Lib, "GoodsShelfClient")
local WinGoodsShelfCar = M
local GridView = require("ui.widget.widget_virtual_grid")

function WinGoodsShelfCar:initUI()
  self.btnClose = self:child("ButtonClose")
  local scrollView = self:child("ScrollableViewClosetView")
  local contentView = self:child("LayoutClosetContent")
  self.clothesGridView = GridView:init(scrollView, contentView, function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/goods_shelf/widget_goods_shelf_car_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onClothesItemClicked(gridItem:getIndex())
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end, 4)
  self.btnBuy = self:child("ButtonBuy")
end

function WinGoodsShelfCar:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  function self.btnBuy.onMouseClick()
    self:requestPurchase()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinGoodsShelfCar:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  self.itemArray = {}
  self.selectIndex = 0
  self:updateView(true)
  self.freshTimer = World.Timer(20, function()
    self:updateView(false)
  end)
end

function WinGoodsShelfCar:getGoodsArray()
  if not self.info.goodsArray then
    local goodsArray = {}
    local id = self.info.shelfID or 0
    local shelfConfigItem = GoodsShelfConfig:getCfgById(id)
    if shelfConfigItem then
      local type = shelfConfigItem.type or Define.GoodsShelf.Type.None
      local goodsIds = shelfConfigItem.goodsList
      for i, id in pairs(goodsIds) do
        local config = GoodsShelfClient:export_getGoodsConfig(type, id)
        if config then
          local item = {}
          item.selected = false
          item.index = i
          item.value = Lib.copy(config)
          table.insert(goodsArray, item)
        end
      end
    end
    self.info.goodsArray = goodsArray
  end
  return self.info.goodsArray
end

function WinGoodsShelfCar:getSelectGoodsItem()
  local itemArray = self:getGoodsArray()
  local item = itemArray[self.selectIndex]
  return item
end

function WinGoodsShelfCar:updateView(reload)
  local itemArray = self:getGoodsArray()
  if reload then
    self.clothesGridView:clearVirtualChild()
    self.clothesGridView:addVirtualChildList(itemArray)
  else
    self.clothesGridView:refresh(itemArray)
  end
  self.btnBuy:setText(Lang:toText("goods_shelf.closet.buy"))
  self.btnBuy:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
  self.btnBuy:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
  local selectItem = self:getSelectGoodsItem()
  if selectItem then
    local ownItem = Me:getBastionClothesItem(selectItem.value.id)
    if ownItem == nil then
      local cash = Me:getCurrencyById(Define.Bastion.Currency.Type.Gold)
      if cash >= selectItem.value.vehicle_price then
        self.btnBuy:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
        self.btnBuy:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
      end
    end
  end
end

function WinGoodsShelfCar:onClothesItemClicked(index)
  Me:playSoundByKey("g2055_commonButtonSound")
  local itemArray = self:getGoodsArray()
  if not itemArray then
    return
  end
  local oldData = itemArray[self.selectIndex]
  if oldData then
    oldData.selected = false
  end
  local newData = itemArray[index]
  if newData then
    self.selectIndex = index
    newData.selected = true
  end
  self:updateView(false)
end

function WinGoodsShelfCar:requestPurchase()
  local selectItem = self:getSelectGoodsItem()
  if not selectItem then
    local msg = Lang:toText("goods_shelf.tip.select.goods")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  local cash = Me:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if cash < selectItem.value.vehicle_price then
    local msg = Lang:toText("goods_shelf.no.enough.currency")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local selectItem = self:getSelectGoodsItem()
  if not selectItem then
    return
  end
  local param = {}
  param.shelfType = self.info.shelfType
  param.shelfID = self.info.shelfID
  param.index = self.selectIndex
  param.type = Define.GoodsShelf.Type.Cars
  param.id = selectItem.value.id
  local player = Me
  player:C2S_RequestPurchaseGoods(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:updateView(false)
      local msg = Lang:toText("goods_shelf.purchase.succeed")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      Me:playSoundByKey("g2055_commonBuySound")
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinGoodsShelfCar:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfCar:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.freshTimer then
    self.freshTimer()
    self.freshTimer = nil
  end
  Blockman.instance:control().enable = true
end

return WinGoodsShelfCar
