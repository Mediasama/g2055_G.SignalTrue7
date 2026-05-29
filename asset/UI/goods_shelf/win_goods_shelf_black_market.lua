local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local GoodsShelfClient = T(Lib, "GoodsShelfClient")
local BlackMarketGoodsConfig = T(Config, "BlackMarketGoodsConfig")
local WinGoodsShelfMarket = M
local GridView = require("ui.widget.widget_virtual_grid")

function WinGoodsShelfMarket:initUI()
  self.btnClose = self:child("ButtonClose")
  self.actorWindow = self:child("ActorWindow")
  self.actorWindow:setActorName(self:getPreviewActorName())
  local scrollView = self:child("ScrollableViewClosetView")
  local contentView = self:child("LayoutClosetContent")
  self.goodsGridView = GridView:init(scrollView, contentView, function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/goods_shelf/widget_goods_shelf_black_market_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onItemClicked(gridItem:getIndex())
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end, 3)
  self.btnBuy = self:child("ButtonBuy")
end

function WinGoodsShelfMarket:getPreviewActorName()
  local sex = Me.userDetailData.sex or 1
  if sex == 1 then
    local actorName = Me:cfg().actorName or "g2055_boy.actor"
    return "asset/necessary/player/" .. actorName
  else
    local actorName = Me:cfg().actorGirlName or "g2055_girl.actor"
    return "asset/necessary/player/" .. actorName
  end
end

function WinGoodsShelfMarket:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  function self.btnBuy.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    self:requestPurchase()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinGoodsShelfMarket:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  self.selectIndex = 0
  self:updateView(true)
  self.freshTimer = World.Timer(20, function()
    self:updateView(false)
  end)
end

function WinGoodsShelfMarket:getGoodsArray()
  if not self.goodsArray then
    local goodsArray = {}
    local id = self.info.shelfID or 0
    local goods = Me:bmc_getGoods(id)
    for index, goodID in pairs(goods) do
      local config = BlackMarketGoodsConfig:getCfgById(goodID)
      local item = {}
      item.selected = false
      item.index = index
      item.value = Lib.copy(config)
      table.insert(goodsArray, item)
    end
    self.goodsArray = goodsArray
  end
  return self.goodsArray
end

function WinGoodsShelfMarket:getSelectGoodsItem()
  local itemArray = self:getGoodsArray()
  local item = itemArray[self.selectIndex]
  return item
end

function WinGoodsShelfMarket:updateView(reload)
  local itemArray = self:getGoodsArray()
  if reload then
    self.goodsGridView:clearVirtualChild()
    self.goodsGridView:addVirtualChildList(itemArray)
  else
    self.goodsGridView:refresh(itemArray)
  end
  self.btnBuy:setText(Lang:toText("goods_shelf.closet.buy"))
  self.btnBuy:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
  self.btnBuy:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
  local actorName = Me:getActorName()
  local previewSkinData = EntityClient.processSkin(actorName, Me:data("skins"))
  local selectItem = self:getSelectGoodsItem()
  local alreadyOwned = true
  if selectItem then
    local goodsList = selectItem.value.goods or {}
    for i, goods in pairs(goodsList) do
      if goods.type == Define.GoodsShelf.Type.Clothes then
        local ownItem = Me:getBastionClothesItem(goods.id)
        if ownItem == nil then
          alreadyOwned = false
        end
        local goodsConfig = GoodsShelfClient:export_getGoodsConfig(goods.type, goods.id)
        if goodsConfig then
          local skinData = goodsConfig.skin_data
          for key, v in pairs(skinData) do
            previewSkinData[key] = v
          end
        end
      else
        alreadyOwned = false
      end
    end
    local cash = Me:getCurrencyById(Define.Bastion.Currency.Type.Gold)
    if not alreadyOwned and cash > selectItem.value.price then
      self.btnBuy:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
      self.btnBuy:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
    end
  end
  for k, v in pairs(previewSkinData) do
    if v == "" then
      self.actorWindow:unloadBodyPart(k)
    else
      self.actorWindow:useBodyPart(k, v)
    end
  end
end

function WinGoodsShelfMarket:onItemClicked(index)
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

function WinGoodsShelfMarket:requestPurchase()
  local selectItem = self:getSelectGoodsItem()
  if not selectItem then
    local msg = Lang:toText("goods_shelf.tip.select.goods")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  local cash = Me:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if cash < selectItem.value.price then
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
  param.type = Define.GoodsShelf.Type.BlackMarket
  param.id = selectItem.value.id
  local player = Me
  player:C2S_RequestPurchaseGoods(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      local msg = Lang:toText("goods_shelf.purchase.succeed")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      Me:playSoundByKey("g2055_commonBuySound")
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinGoodsShelfMarket:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinGoodsShelfMarket:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
end

return WinGoodsShelfMarket
