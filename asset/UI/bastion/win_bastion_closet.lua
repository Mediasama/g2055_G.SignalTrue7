local ClothesConfig = T(Config, "ClothesConfig")
local WinBastionCloset = M
local GridView = require("ui.widget.widget_virtual_grid")

function WinBastionCloset:initUI()
  self.btnClose = self:child("ButtonClose")
  self.btnTabDict = {}
  self.btnTabDict[Define.ModelClothes.Type.Hat] = self:child("ButtonHat")
  self.btnTabDict[Define.ModelClothes.Type.Mask] = self:child("ButtonMask")
  self.btnTabDict[Define.ModelClothes.Type.Coat] = self:child("ButtonCoat")
  self.btnTabDict[Define.ModelClothes.Type.Trousers] = self:child("ButtonTrousers")
  self.btnTabDict[Define.ModelClothes.Type.Shoes] = self:child("ButtonShoes")
  self.btnTabDict[Define.ModelClothes.Type.Tattoo] = self:child("ButtonTattoo")
  self.actorWindow = self:child("ActorWindow")
  self.actorWindow:setActorName(self:getPreviewActorName())
  local scrollView = self:child("ScrollableViewClosetView")
  local contentView = self:child("LayoutClosetContent")
  self.clothesGridView = GridView:init(scrollView, contentView, function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/bastion/widget_bastion_closet_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onClothesItemClicked(gridItem:getIndex())
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end, 3)
end

function WinBastionCloset:getPreviewActorName()
  local sex = Me.userDetailData.sex or 1
  if sex == 1 then
    local actorName = Me:cfg().actorName or "g2055_boy.actor"
    return "asset/necessary/player/" .. actorName
  else
    local actorName = Me:cfg().actorGirlName or "g2055_girl.actor"
    return "asset/necessary/player/" .. actorName
  end
end

function WinBastionCloset:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  for key, button in pairs(self.btnTabDict) do
    function button.onMouseClick()
      Me:playSoundByKey("g2055_commonButtonSound")
      
      self:setTabType(key)
    end
  end
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinBastionCloset:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  self.pageDataDict = {}
  self.tabType = Define.ModelClothes.Type.None
  self.waitResponse = false
  self:setTabType(Define.ModelClothes.Type.Hat)
  self:reload()
end

function WinBastionCloset:getTabType()
  return self.tabType
end

function WinBastionCloset:setTabType(type)
  self.tabType = type
  for i, button in pairs(self.btnTabDict) do
    button:setEnabled(i ~= type)
  end
  self:updateView(true)
end

function WinBastionCloset:getPageData(type)
  return self.pageDataDict[type]
end

function WinBastionCloset:clearPageData()
  self.pageDataDict = {}
  self.pageDataDict[Define.ModelClothes.Type.Hat] = {
    selectedIndex = -1,
    items = {}
  }
  self.pageDataDict[Define.ModelClothes.Type.Mask] = {
    selectedIndex = -1,
    items = {}
  }
  self.pageDataDict[Define.ModelClothes.Type.Coat] = {
    selectedIndex = -1,
    items = {}
  }
  self.pageDataDict[Define.ModelClothes.Type.Trousers] = {
    selectedIndex = -1,
    items = {}
  }
  self.pageDataDict[Define.ModelClothes.Type.Shoes] = {
    selectedIndex = -1,
    items = {}
  }
  self.pageDataDict[Define.ModelClothes.Type.Tattoo] = {
    selectedIndex = -1,
    items = {}
  }
end

function WinBastionCloset:setPageData(data)
  if not self.isValid then
    return
  end
  self:clearPageData()
  local closetData = data or {}
  local clothesArray = closetData.clothesDict or {}
  for i, item in pairs(clothesArray) do
    local id = item.id
    local configItem = ClothesConfig:getCfgById(id)
    if configItem then
      local type = configItem.part
      local item = {}
      item.selected = false
      item.index = -1
      item.value = configItem
      local itemArray = self:getClothesItemArray(type)
      table.insert(itemArray, item)
    end
  end
  for type, pageData in pairs(self.pageDataDict) do
    table.sort(pageData.items, function(itemA, itemB)
      return itemA.value.id < itemB.value.id
    end)
    local player = Me
    local wearItem = player:getModelClothesItem(type)
    for i, item in pairs(pageData.items) do
      item.index = i
      if wearItem and wearItem.id == item.value.id then
        item.selected = true
      else
        item.selected = false
      end
    end
  end
  self:updateView(true)
end

function WinBastionCloset:getClothesItemArray(type)
  local pageData = self:getPageData(type)
  if not pageData then
    return
  end
  local itemArray = pageData.items
  if not itemArray then
    itemArray = {}
    pageData.items = itemArray
  end
  return itemArray
end

function WinBastionCloset:setPageIndex(type, index)
  local pageData = self:getPageData(type)
  local itemArray = pageData.items
  local lastSelectIndex = pageData.selectedIndex
  if lastSelectIndex then
    local itemData = itemArray[lastSelectIndex]
    if itemData then
      itemData.selected = false
    end
  end
  if lastSelectIndex == index then
    pageData.selectedIndex = -1
  else
    pageData.selectedIndex = index
  end
  local currentSelectIndex = pageData.selectedIndex
  if currentSelectIndex then
    local itemData = itemArray[currentSelectIndex]
    if itemData then
      itemData.selected = true
    end
  end
end

function WinBastionCloset:updateView(reload)
  if not self.isValid then
    return
  end
  local itemArray = self:getClothesItemArray(self:getTabType())
  if reload then
    self.clothesGridView:clearVirtualChild()
    self.clothesGridView:addVirtualChildList(itemArray)
  else
    self.clothesGridView:refresh(itemArray)
  end
  local actorName = Me:getActorName()
  local skin = EntityClient.processSkin(actorName, Me:data("skins"))
  for k, v in pairs(skin) do
    if v == "" then
      self.actorWindow:unloadBodyPart(k)
    else
      self.actorWindow:useBodyPart(k, v)
    end
  end
end

function WinBastionCloset:onClothesItemClicked(index)
  local itemArray = self:getClothesItemArray(self:getTabType())
  if not itemArray then
    return
  end
  local itemData = itemArray[index]
  if not itemData then
    return
  end
  local id = itemData.value.id
  self:requestOperate(id)
end

function WinBastionCloset:reload()
  local player = Me
  local param = Lib.copy(self.info)
  param.manner = Define.Bastion.Facility.OperateType.Query
  param.operatorId = Me.platformUserId
  player:C2S_OperateBastionFacility(param, function(param)
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:setPageData(rsp.data)
    else
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

function WinBastionCloset:requestOperate(id)
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local player = Me
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.requestData = {id = id}
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:setPageData(rsp.data)
      Me:playSoundByKey("g2055_changeClothesSound")
    else
      if rsp.data then
        self:setPageData(rsp.data)
      end
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinBastionCloset:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionCloset:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
end

return WinBastionCloset
