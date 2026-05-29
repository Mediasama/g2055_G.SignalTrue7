local PlayerMotionConfig = T(Config, "PlayerMotionConfig")
local WinPlayerMotion = M
local GridView = require("ui.widget.widget_virtual_grid")
M.TAB_TYPE = {TAB_MOTION_FREE = 1, TAB_MOTION_PAID = 2}

function WinPlayerMotion:initUI()
  self.btnClose = self:child("ButtonClose")
  self.txtTitle = self:child("TextTitle")
  self.txtTitle:setText(Lang:toText("player.motion.title"))
  local scrollView = self:child("ScrollableViewClosetView")
  local contentView = self:child("LayoutClosetContent")
  self.gridView = GridView:init(scrollView, contentView, function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/player_motion/widget_player_motion_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onClothesItemClicked(gridItem:getIndex(), gridItem:getIsPaid(), false)
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end, 3)
  local scrollViewPaid = self:child("ScrollableViewClosetViewPaid")
  local contentViewPaid = self:child("LayoutClosetContentPaid")
  self.gridViewPaid = GridView:init(scrollViewPaid, contentViewPaid, function(gridView, parentWindow)
    local gridItem = UI:openWidget("./UI/player_motion/widget_player_motion_item")
    parentWindow:addChild(gridItem:getWindow())
    gridItem:setClickCallback(function(gridItem)
      self:onClothesItemClicked(gridItem:getIndex(), gridItem:getIsPaid(), gridItem:getIsLock())
    end)
    return gridItem
  end, function(gridView, gridItem, data)
    gridItem:setData(data)
  end, 3)
  self.tabList = {}
  self.panelList = {}
  self.tabList[M.TAB_TYPE.TAB_MOTION_FREE] = self:child("PanelTabFree")
  self.tabList[M.TAB_TYPE.TAB_MOTION_PAID] = self:child("PanelTabPaid")
  self.panelList[M.TAB_TYPE.TAB_MOTION_FREE] = self:child("PanelGridFree")
  self.panelList[M.TAB_TYPE.TAB_MOTION_PAID] = self:child("PanelGridPaid")
end

function WinPlayerMotion:initEvent()
  function self.btnClose.onMouseClick()
    Me:playSoundByKey("g2055_commonCloseSound")
    
    self:close()
  end
  
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, function()
    self:close()
  end)
  for i = 1, #self.tabList do
    self.tabList[i].onMouseButtonDown = function()
      self:selectTab(i)
    end
  end
end

function M:selectTab(tabType)
  if self.tabList[tabType] and self.panelList[tabType] then
    for i = 1, #self.tabList do
      self.tabList[i].ImageSelect:setVisible(i == tabType)
      self.tabList[i].ImageUnselected:setVisible(i ~= tabType)
      self.panelList[i]:setVisible(i == tabType)
    end
    Me.lastSelectMotionTab = tabType
  end
end

function WinPlayerMotion:initView(param)
  self:updateView(true)
end

function WinPlayerMotion:getMotionData()
  if not self.motionData then
    self.motionData = {}
    self.motionDataPaid = {}
    local motionConfigs = PlayerMotionConfig:getAllCfgs()
    local index = 1
    local indexPaid = 1
    for i, configItem in pairs(motionConfigs) do
      local item = {}
      item.selected = false
      item.configItem = Lib.copy(configItem)
      if configItem.ifPaidMotion then
        item.index = indexPaid
        table.insert(self.motionDataPaid, item)
        indexPaid = indexPaid + 1
      else
        item.index = index
        table.insert(self.motionData, item)
        index = index + 1
      end
    end
  end
  return self.motionData, self.motionDataPaid
end

function WinPlayerMotion:updateView(reload)
  local itemArray, itemArrayPaid = self:getMotionData()
  if reload then
    self.gridView:clearVirtualChild()
    self.gridView:addVirtualChildList(itemArray)
    self.gridViewPaid:clearVirtualChild()
    self.gridViewPaid:addVirtualChildList(itemArrayPaid)
  else
    self.gridView:refresh(itemArray)
    self.gridViewPaid:refresh(itemArrayPaid)
  end
end

function WinPlayerMotion:onClothesItemClicked(index, isPaidMotion, isLock)
  Me:playSoundByKey("g2055_commonButtonSound")
  if isLock then
    local state = Me:getCurState()
    if state ~= Define.CHARACTER_STATE_TYPE.GROUND and state ~= Define.CHARACTER_STATE_TYPE.DIE then
      Me:sendPacket({
        pid = "isPassCardDateC2S"
      }, function(ret)
        if ret then
          Lib.openWindow("./UI/pass_card/win_pass_card")
        else
          Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("passCard.not.open"))
        end
      end)
    else
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("passCard.cant.open.ui"))
    end
    self:close()
    return
  end
  local motionData, motionDataPaid = self:getMotionData()
  local selectedData = isPaidMotion and motionDataPaid[index] or motionData[index]
  if not selectedData then
    return
  end
  local param = {
    motionId = selectedData.configItem.id
  }
  Me:pam_C2S_RequestActiveMotion(param)
  self:close()
end

function WinPlayerMotion:onOpen(param)
  self:setUsingAutoRenderingSurface(true)
  self.isValid = true
  param = param or {}
  self:initUI()
  self:initEvent()
  self:initView(param)
  if Me.lastSelectMotionTab then
    self:selectTab(Me.lastSelectMotionTab)
  else
    self:selectTab(M.TAB_TYPE.TAB_MOTION_FREE)
  end
end

function WinPlayerMotion:onClose()
  self.isValid = false
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPlayerMotion
