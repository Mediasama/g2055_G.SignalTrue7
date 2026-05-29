local ClothesConfig = T(Config, "ClothesConfig")
local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local GoodsShelfClient = T(Lib, "GoodsShelfClient")
local WinGoodsShelfCloset = M
local GridView = require("ui.widget.widget_virtual_grid")

function WinGoodsShelfCloset:initUI()
  self.btnClose = self:child("ButtonClose")
  self.txtClothesAmount = self:child("TextClothesAmount")
  self.imageRedDot = self:child("ImageRedDot")
  self.txtTotalPrice = self:child("TextTotalPrice")
  self.panelCart = self:child("PanelCart")
  self.actorWindow = self:child("ActorWindow")
  self.actorWindow:setActorName(self:getPreviewActorName())
  local scrollView = self:child("ScrollableViewClosetView")
  local contentView = self:child("LayoutClosetContent")
  self.clothesGridView = GridView:init(scrollView, contentView, function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/goods_shelf/widget_goods_shelf_closet_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onClothesItemClicked(gridItem:getIndex())
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end, 3)
  self.btnBuy = self:child("ButtonBuy")
end

function WinGoodsShelfCloset:getPreviewActorName()
  local sex = Me.userDetailData.sex or 1
  if sex == 1 then
    local actorName = Me:cfg().actorName or "g2055_boy.actor"
    return "asset/necessary/player/" .. actorName
  else
    local actorName = Me:cfg().actorGirlName or "g2055_girl.actor"
    return "asset/necessary/player/" .. actorName
  end
end

function WinGoodsShelfCloset:initEvent()
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

function WinGoodsShelfCloset:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  self.itemArray = {}
  self.selectClothesDict = {}
  self.selectIndex = 0
  self:updateView(true)
  self.freshTimer = World.Timer(20, function()
    self:updateView(false)
  end)
end

function WinGoodsShelfCloset:getGoodsArray()
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

function WinGoodsShelfCloset:getSelectGoodsItems()
  local itemArray = self:getGoodsArray()
  local items = {}
  for i, index in pairs(self.selectClothesDict) do
    local item = itemArray[index]
    table.insert(items, item)
  end
  return items
end

function WinGoodsShelfCloset:isSelectIndex(index)
  for i, selectIndex in pairs(self.selectClothesDict) do
    if selectIndex == index then
      return true
    end
  end
  return false
end

function WinGoodsShelfCloset:addSelectItem(index)
  local itemArray = self:getGoodsArray()
  if not itemArray then
    return
  end
  local newData = itemArray[index]
  local part = newData.value.part
  local oldIndex = self.selectClothesDict[part]
  local oldData = itemArray[oldIndex]
  if oldData then
    oldData.selected = false
  end
  if newData then
    newData.selected = true
  end
  self.selectClothesDict[part] = index
end

function WinGoodsShelfCloset:deleteSelectItem(index)
  local itemArray = self:getGoodsArray()
  if not itemArray then
    return
  end
  local newData = itemArray[index]
  local part = newData.value.part
  local oldIndex = self.selectClothesDict[part]
  local oldData = itemArray[oldIndex]
  if oldData then
    oldData.selected = false
  end
  self.selectClothesDict[part] = nil
end

function WinGoodsShelfCloset:clearPossessItem()
  local itemArray = self:getGoodsArray()
  if not itemArray then
    return
  end
  local player = Me
  local deletePart = {}
  for part, selectIndex in pairs(self.selectClothesDict) do
    local oldData = itemArray[selectIndex]
    if player:getBastionClothesItem(oldData.value.id) ~= nil then
      oldData.selected = false
      table.insert(deletePart, part)
    end
  end
  for i, part in pairs(deletePart) do
    self.selectClothesDict[part] = nil
  end
end

function WinGoodsShelfCloset:onClothesItemClicked(index)
  Me:playSoundByKey("g2055_commonButtonSound")
  local itemArray = self:getGoodsArray()
  if not itemArray then
    return
  end
  local newData = itemArray[index]
  local player = Me
  if player:getBastionClothesItem(newData.value.id) ~= nil then
    local msg = Lang:toText("goods_shelf.closet.already.possess")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  if self:isSelectIndex(index) then
    self:deleteSelectItem(index)
  else
    self:addSelectItem(index)
  end
  self:updateView(false)
end

function WinGoodsShelfCloset:updateView(reload)
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
  local actorName = Me:getActorName()
  local skin = EntityClient.processSkin(actorName, Me:data("skins"))
  local selectItems = self:getSelectGoodsItems()
  local totalPrice = 0
  local clothesCount = 0
  for i, selectItem in pairs(selectItems) do
    totalPrice = totalPrice + selectItem.value.price
    for k, v in pairs(selectItem.value.skin_data) do
      skin[k] = v
    end
    clothesCount = clothesCount + 1
  end
  self.txtClothesAmount:setText(tostring(clothesCount))
  self.imageRedDot:setVisible(0 < clothesCount)
  self.txtTotalPrice:setText(tostring(totalPrice))
  self.panelCart:setVisible(0 < clothesCount)
  local cash = Me:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if 0 < totalPrice and totalPrice <= cash then
    self.btnBuy:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
    self.btnBuy:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
  end
  for k, v in pairs(skin) do
    if v == "" then
      self.actorWindow:unloadBodyPart(k)
    else
      self.actorWindow:useBodyPart(k, v)
    end
  end
end

function WinGoodsShelfCloset:requestPurchase()
  local selectItems = self:getSelectGoodsItems()
  local totalPrice = 0
  local clothesCount = 0
  for i, selectItem in pairs(selectItems) do
    totalPrice = totalPrice + selectItem.value.price
    clothesCount = clothesCount + 1
  end
  if clothesCount < 1 then
    local msg = Lang:toText("goods_shelf.tip.select.goods")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  local cash = Me:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if totalPrice > cash then
    local msg = Lang:toText("goods_shelf.no.enough.currency")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local selectItems = self:getSelectGoodsItems()
  local ids = {}
  for i, item in pairs(selectItems) do
    table.insert(ids, item.value.id)
  end
  local param = {}
  param.shelfType = self.info.shelfType
  param.shelfID = self.info.shelfID
  param.type = Define.GoodsShelf.Type.Clothes
  param.ids = ids
  local player = Me
  player:C2S_RequestPurchaseGoods(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:clearPossessItem()
      self:updateView(false)
      local msg = Lang:toText("goods_shelf.purchase.succeed")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      Me:playSoundByKey("g2055_changeClothesSound")
      Me:playSoundByKey("g2055_commonBuySound")
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinGoodsShelfCloset:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfCloset:onClose()
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

return WinGoodsShelfCloset
