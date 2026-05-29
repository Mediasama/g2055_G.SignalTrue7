local WeaponConfig = T(Config, "WeaponConfig")
local WinBastionArmory = M
local GridView = require("ui.widget.widget_virtual_grid")
local VerticalView = require("ui.widget.widget_virtual_vert_list")

function WinBastionArmory:initUI()
  self.btnClose = self:child("ButtonClose")
  self.btnFetch = self:child("ButtonFetch")
  self.btnDeposit = self:child("ButtonDeposit")
  self.btnSteal = self:child("ButtonSteal")
  self.btnFetch:setText(Lang:toText("bastion.armory.button.text.fetch"))
  self.btnDeposit:setText(Lang:toText("bastion.armory.button.text.deposit"))
  self.btnSteal:setText(Lang:toText("bastion.armory.button.text.steal"))
  self.armoryGridView = GridView:init(self:child("ScrollableViewArmoryView"), self:child("LayoutArmoryContent"), function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/bastion/widget_bastion_armory_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onArmoryItemClicked(gridItem:getIndex())
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end, 4)
  self.handbagGridView = VerticalView:init(self:child("ScrollableViewHandBagView"), self:child("LayoutHandBagContent"), function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/bastion/widget_bastion_handbag_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onHandBagItemClicked(gridItem:getIndex())
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end)
end

function WinBastionArmory:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  function self.btnFetch.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    self:requestFetch()
    Lib.emitEvent(Event.EVENT_GUIDE_CLOSE_TIPS, Define.GUIDE_TIPS_PUT_WEAPON)
    Lib.emitEvent(Event.EVENT_GUIDE_FINISH, Define.GUIDE_GET_WEAPON)
  end
  
  function self.btnDeposit.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    self:requestDeposit()
  end
  
  function self.btnSteal.onMouseClick()
    Me:playSoundByKey("g2055_commonButtonSound")
    self:requestSteal()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
end

function WinBastionArmory:initView(param)
  Me:pam_C2S_RequestStopMotion()
  self.info = param
  self.armoryArray = {}
  self.armorySelectIndex = 0
  self.handbagArray = {}
  self.handbagSelectIndex = 0
  self.waitResponse = false
  self:setData(nil)
  self:reload()
end

function WinBastionArmory:getSelectArmoryItem()
  return self.armoryArray[self.armorySelectIndex]
end

function WinBastionArmory:getSelectHandBagItem()
  return self.handbagArray[self.handbagSelectIndex]
end

function WinBastionArmory:onArmoryItemClicked(index)
  Me:playSoundByKey("g2055_commonButtonSound")
  if self.armorySelectIndex == index then
    if self.armorySelectIndex and self.armoryArray[self.armorySelectIndex] then
      self.armoryArray[self.armorySelectIndex].selected = false
      self.armorySelectIndex = 0
    end
  else
    if self.armorySelectIndex and self.armoryArray[self.armorySelectIndex] then
      self.armoryArray[self.armorySelectIndex].selected = false
    end
    self.armorySelectIndex = index
    if self.armorySelectIndex and self.armoryArray[self.armorySelectIndex] then
      self.armoryArray[self.armorySelectIndex].selected = true
    end
  end
  self:updateView(false)
end

function WinBastionArmory:onHandBagItemClicked(index)
  Me:playSoundByKey("g2055_commonButtonSound")
  if self.handbagSelectIndex and self.handbagArray[self.handbagSelectIndex] then
    self.handbagArray[self.handbagSelectIndex].selected = false
  end
  self.handbagSelectIndex = index
  if self.handbagSelectIndex and self.handbagArray[self.handbagSelectIndex] then
    self.handbagArray[self.handbagSelectIndex].selected = true
  end
  self:updateView(false)
end

function WinBastionArmory:setData(data)
  if not self.isValid then
    return
  end
  data = data or {}
  self.armoryArray = {}
  local armory = data.armory or {}
  for i, data in pairs(armory) do
    local config = WeaponConfig:getCfgById(data.id)
    if config then
      local item = {}
      item.slotId = data.slotId
      item.weaponId = data.id
      item.bulletCount = data.bulletCount
      item.selected = false
      item.index = -1
      item.config = config
      table.insert(self.armoryArray, item)
    end
  end
  table.sort(self.armoryArray, function(a, b)
    if a.weaponId == b.weaponId then
      return a.bulletCount < b.bulletCount
    else
      return a.weaponId < b.weaponId
    end
  end)
  for i, v in pairs(self.armoryArray) do
    v.index = i
    v.selected = i == self.armorySelectIndex
  end
  if not self.armoryArray[self.armorySelectIndex] then
    self.armorySelectIndex = 0
  end
  self.handbagArray = data.handbag or {}
  if data.handbagSelectIndex then
    self.handbagSelectIndex = data.handbagSelectIndex
  end
  self.handbagArray = {}
  local handbag = data.handbag or {}
  for i, data in pairs(handbag) do
    local item = {}
    item.slotId = data.slotId
    item.weaponId = data.id
    item.bulletCount = data.bulletCount
    item.selected = false
    item.index = i
    item.config = WeaponConfig:getCfgById(data.id)
    table.insert(self.handbagArray, item)
  end
  for i, v in pairs(self.handbagArray) do
    v.index = i
    v.selected = i == self.handbagSelectIndex
  end
  if not self.handbagArray[self.handbagSelectIndex] then
    self.handbagSelectIndex = 0
  end
  self:updateView(true)
end

function WinBastionArmory:updateView(reload)
  if reload then
    self.armoryGridView:clearVirtualChild()
    self.armoryGridView:addVirtualChildList(self.armoryArray)
  else
    self.armoryGridView:refresh(self.armoryArray)
  end
  if reload then
    self.handbagGridView:clearVirtualChild()
    self.handbagGridView:addVirtualChildList(self.handbagArray)
  else
    self.handbagGridView:refresh(self.handbagArray)
  end
  if self.info.manner == Define.Bastion.Facility.OperateType.Fetch then
    self.btnFetch:setVisible(true)
    self.btnDeposit:setVisible(true)
    self.btnSteal:setVisible(false)
  else
    self.btnFetch:setVisible(false)
    self.btnDeposit:setVisible(false)
    self.btnSteal:setVisible(true)
  end
  self.btnFetch:setEnabled(self:getSelectArmoryItem() ~= nil)
  self.btnSteal:setEnabled(self:getSelectArmoryItem() ~= nil)
  local selectHandBagItem = self:getSelectHandBagItem()
  if selectHandBagItem and selectHandBagItem.weaponId ~= -1 then
    self.btnDeposit:setEnabled(true)
  else
    self.btnDeposit:setEnabled(false)
  end
end

function WinBastionArmory:reload()
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
      self:setData(rsp.data)
    else
      Lib.logBastion("C2S_OperateBastionFacility Failed", rsp.status, rsp.msg)
    end
  end)
end

function WinBastionArmory:requestFetch()
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local selectArmoryItem = self:getSelectArmoryItem()
  local selectHandBagItem = self:getSelectHandBagItem()
  local requestData = {}
  if selectArmoryItem then
    requestData.armorySlotID = selectArmoryItem.slotId
  end
  if selectHandBagItem then
    requestData.handBagSlotID = selectHandBagItem.slotId
  end
  local player = Me
  local param = Lib.copy(self.info)
  param.manner = Define.Bastion.Facility.OperateType.Fetch
  param.operatorId = Me.platformUserId
  param.requestData = requestData
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:setData(rsp.data)
      Me:playSoundByKey("g2055_changeWeaponsSound")
    else
      if rsp.data then
        self:setData(rsp.data)
      end
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinBastionArmory:requestDeposit()
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local selectArmoryItem = self:getSelectArmoryItem()
  local selectHandBagItem = self:getSelectHandBagItem()
  local requestData = {}
  if selectArmoryItem then
    requestData.armorySlotID = selectArmoryItem.slotId
  end
  if selectHandBagItem then
    requestData.handBagSlotID = selectHandBagItem.slotId
  end
  local player = Me
  local param = Lib.copy(self.info)
  param.manner = Define.Bastion.Facility.OperateType.Deposit
  param.operatorId = Me.platformUserId
  param.requestData = requestData
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:setData(rsp.data)
      Me:playSoundByKey("g2055_changeWeaponsSound")
    else
      if rsp.data then
        self:setData(rsp.data)
      end
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinBastionArmory:requestSteal()
  if self.waitResponse then
    return
  end
  self.waitResponse = true
  local selectArmoryItem = self:getSelectArmoryItem()
  local selectHandBagItem = self:getSelectHandBagItem()
  local requestData = {}
  if selectArmoryItem then
    requestData.armorySlotID = selectArmoryItem.slotId
  end
  if selectHandBagItem then
    requestData.handBagSlotID = selectHandBagItem.slotId
  end
  local player = Me
  local param = Lib.copy(self.info)
  param.manner = Define.Bastion.Facility.OperateType.Steal
  param.operatorId = Me.platformUserId
  param.requestData = requestData
  player:C2S_OperateBastionFacility(param, function(param)
    self.waitResponse = false
    if not param then
      return
    end
    local rsp = param
    if rsp.status <= 0 then
      self:setData(rsp.data)
      Me:playSoundByKey("g2055_changeWeaponsSound")
    else
      if rsp.data then
        self:setData(rsp.data)
      end
      local msg = Lang:toText(rsp.msg or "")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
    end
  end)
end

function WinBastionArmory:onOpen(param)
  self.isValid = true
  Blockman.instance:control().enable = false
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
  Lib.emitEvent(Event.EVENT_GUIDE_OPEN_TIPS, Define.GUIDE_TIPS_PUT_WEAPON)
end

function WinBastionArmory:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Blockman.instance:control().enable = true
  Lib.emitEvent(Event.EVENT_GUIDE_CLOSE_TIPS, Define.GUIDE_TIPS_PUT_WEAPON)
  Lib.emitEvent(Event.EVENT_GUIDE_FINISH, Define.GUIDE_GET_WEAPON)
end

return WinBastionArmory
