local DoorsConfig = T(Config, "DoorsConfig")
local WinBastionToolkit = M
local HorizontalView = require("ui.widget.widget_virtual_horz_list")

function WinBastionToolkit:initUI()
  self.btnClose = self:child("ButtonClose")
  self.btnConfirm = self:child("ButtonConfirm")
  self.btnConfirm:setText(Lang:toText("bastion.door.manner.buy"))
  self.imgCurrent = self:child("ImageCurrent")
  self.txtCurrent = self:child("TextCurrent")
  local scrollView = self:child("ScrollableView")
  local contentView = self:child("HorizontalLayout")
  self.doorsListView = HorizontalView:init(scrollView, contentView, function(listView, parentWindow)
    local item = UI:openWidget("./UI/bastion/widget_bastion_toolkit_item")
    parentWindow:addChild(item:getWindow())
    item:setClickCallback(function(item)
      self:onToolkitItemClicked(item:getIndex())
    end)
    return item
  end, function(listView, item, data)
    item:setData(data)
  end)
  self.txtCurrent:setText(Lang:toText("bastion.door.current"))
end

function WinBastionToolkit:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  function self.btnConfirm.onMouseClick()
    self:requestOperate()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinBastionToolkit:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  self.items = {}
  self.selectIndex = -1
  self.waitResponse = false
  self.defenseType = Define.Bastion.Defense.Type.Door
  self:updateView(true)
end

function WinBastionToolkit:updateView(reload)
  if not self.isValid then
    return
  end
  self.items = {}
  local player = Me
  local currentDoorData = player:getBastionDefenseItem(self.defenseType)
  if not currentDoorData then
    return
  end
  local availableDoors = {}
  local configs = DoorsConfig:getAllCfgs()
  for i, door in pairs(configs) do
    if door.isHomeDoor then
      availableDoors[i] = door
    end
  end
  local index = 1
  for i, configItem in pairs(availableDoors) do
    if configItem.id ~= currentDoorData.id then
      local item = {}
      item.index = 0
      item.selected = false
      item.value = configItem
      table.insert(self.items, item)
      index = index + 1
    else
      self.imgCurrent:setImage(configItem.icon)
    end
  end
  table.sort(self.items, function(itemA, itemB)
    return itemA.value.id < itemB.value.id
  end)
  for i, item in pairs(self.items) do
    item.index = i
    item.selected = i == self.selectIndex
  end
  self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
  self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option3")
  if 0 < self.selectIndex and self.items[self.selectIndex] and Me:getCurrencyById(Define.Bastion.Currency.Type.Gold) >= self.items[self.selectIndex].value.price then
    self.btnConfirm:setNormalImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
    self.btnConfirm:setPushedImage("gameres|asset/Imageset/g2055_button:btn_0_option1")
  end
  if reload then
    self.doorsListView:clearVirtualChild()
    self.doorsListView:addVirtualChildList(self.items)
  else
    self.doorsListView:refresh(self.items)
  end
end

function WinBastionToolkit:onToolkitItemClicked(index)
  Me:playSoundByKey("g2055_commonButtonSound")
  self.selectIndex = index
  self:updateView()
end

function WinBastionToolkit:requestOperate()
  if self.selectIndex < 0 or self.items[self.selectIndex] == nil then
    local msg = Lang:toText("bastion.toolkit.tip.please.select.item")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  if Me:getCurrencyById(Define.Bastion.Currency.Type.Gold) < self.items[self.selectIndex].value.price then
    local msg = Lang:toText("bastion.toolkit.fetch.no.enough.money")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    return
  end
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  Me:playSoundByKey("g2055_commonButtonSound")
  if self.selectIndex <= 0 then
    return
  end
  local selectItem = self.items[self.selectIndex]
  if not selectItem then
    return
  end
  local player = Me
  local param = Lib.copy(self.info)
  param.operatorId = Me.platformUserId
  param.requestData = {
    id = selectItem.value.id,
    type = self.defenseType
  }
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:updateView(true)
      local player = Me
      local currentDoorData = player:getBastionDefenseItem(self.defenseType)
      if not currentDoorData then
        return
      end
      local config = DoorsConfig:getCfgById(currentDoorData.id)
      if not config then
        return
      end
      Me:playSoundByKey(config.createSound)
    else
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinBastionToolkit:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
end

function WinBastionToolkit:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
end

return WinBastionToolkit
