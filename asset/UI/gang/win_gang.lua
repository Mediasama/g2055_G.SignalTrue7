local scrollWidgetHelper = require("modules.helper_common.client.scroll_widget_helper")

function M:init()
  self:initUI()
  self:initButtonEvent()
  self:initEvent()
  self:initText()
  self:initData()
  Lib.emitEvent(Event.EVENT_OPEN_GANG_WIN)
end

function M:initData()
  self.gangCreateIconId = 1
  self.currentScrollType = nil
end

function M:initUI()
  self.scrollableViewGangList = self:child("ScrollableViewGangList")
  self.textScrollViewTitle = self:child("TextScrollViewTitle")
  self.buttonApplyList = self:child("ButtonApplyList")
  self.buttonExitGang = self:child("ButtonExitGang")
  self.imageGangUpdateRedDot = self:child("ImageGangUpdateRedDot")
  self.buttonReturnApply = self:child("ButtonReturnApply")
  self.buttonClearApply = self:child("ButtonClearApply")
  self.panelListEmpty = self:child("PanelListEmpty")
  self.textEmptyList = self:child("TextEmptyList")
  self.textGangMemberNumber = self:child("TextGangMemberNumber")
  self.buttonAutoJoin = self:child("ButtonAutoJoin")
  self.buttonAutoJoin:setEnabled(true)
  self.checkboxAutoJoin = self:child("CheckboxAutoJoin")
  self.checkboxAutoJoin:setVisible(false)
  self:initScroll()
  if Me.firstOpenGangWin then
    Me.firstOpenGangWin = false
    local winTips = UI:openWidget("./UI/gang/win_gang_tips")
    if winTips then
      self:child("PanelTips"):addChild(winTips)
    end
  end
end

function M:setEmptyListVisible(visible, type)
  if self.panelListEmpty then
    self.panelListEmpty:setVisible(visible)
    if visible then
      if type == Define.GangScrollIndex.GangList then
        self.textEmptyList:setText(Lang:toText("gang.tips.empty.gang"))
      else
        self.textEmptyList:setText(Lang:toText("gang.tips.empty.apply.list"))
      end
    end
  end
end

function M:initScroll()
  self.scrollCfg = {
    [Define.GangScrollIndex.GangList] = {
      panel = self:child("PanelGangList"),
      titleTxt = "gang.title.gang.list",
      scrollCfg = {
        scrollableView = self:child("ScrollableViewGangList"),
        verticalLayout = self:child("VerticalLayoutGangList"),
        itemWidget = "./UI/gang/widget_gang_item",
        itemDataFuncName = "onDataChanged",
        layout = 1
      }
    },
    [Define.GangScrollIndex.MemberList] = {
      panel = self:child("PanelGangMember"),
      scrollCfg = {
        scrollableView = self:child("ScrollableViewGangMember"),
        verticalLayout = self:child("VerticalLayoutGangMember"),
        itemWidget = "./UI/gang/widget_gang_member_item",
        itemDataFuncName = "onDataChanged",
        layout = 1
      },
      titleTxt = nil
    },
    [Define.GangScrollIndex.ApplyList] = {
      panel = self:child("PanelGangApply"),
      scrollCfg = {
        scrollableView = self:child("ScrollableViewGangApply"),
        verticalLayout = self:child("VerticalLayoutGangApply"),
        itemWidget = "./UI/gang/widget_gang_apply_item",
        itemDataFuncName = "onDataChanged",
        layout = Define.ScrollWidgetLayout.Vert
      },
      titleTxt = "gang.title.gang.apply.list"
    }
  }
  for i = 1, #self.scrollCfg do
    local scrollHelper = scrollWidgetHelper.new(self.scrollCfg[i].scrollCfg)
    self.scrollCfg[i].scrollHelper = scrollHelper
    self.scrollCfg[i].panel:setVisible(false)
  end
end

function M:selectedCreateGangIconCallBack(data)
  self.gangCreateIconId = data.id
end

function M:initText()
  self.buttonExitGang:setText(Lang:toText("gang.button.exit"))
  self.buttonApplyList:setText(Lang:toText("gang.button.apply.list"))
  self.buttonClearApply:setText(Lang:toText("gang.button.clear.apply.list"))
  self.buttonReturnApply:setText(Lang:toText("gang.button.return"))
  self.buttonAutoJoin:setText(Lang:toText("gang.auto.apply.all"))
  self.checkboxAutoJoin:setText(Lang:toText("gang.auto.join"))
  self:child("ButtonOpenCreateGang"):setText(Lang:toText("gang.button.create.gang"))
end

function M:getScrollData()
  local data = {}
  if self.currentScrollType == Define.GangScrollIndex.MemberList then
    local tmpData = Me:getGangMemberList()
    local chairMan = Me:getChairMan()
    if chairMan ~= Me.platformUserId then
      data[1] = tmpData[Me.platformUserId]
      data[2] = tmpData[chairMan]
    else
      data[1] = tmpData[Me.platformUserId]
    end
    for k, v in pairs(tmpData) do
      if k ~= Me.platformUserId and k ~= chairMan then
        data[#data + 1] = v
      end
    end
    local str = Lang:getMessage("gang.member.number")
    self.textGangMemberNumber:setText(string.format(str, Me:getCurGangMEmberNum(), World.cfg.gangCfg.gangMaxMember))
  elseif self.currentScrollType == Define.GangScrollIndex.ApplyList then
    data = Me:getApplyList()
  elseif self.currentScrollType == Define.GangScrollIndex.GangList then
    data = Me:getGangList()
  end
  return data
end

function M:updateScrollView()
  local type = self.currentScrollType
  if type == nil or not self:isVisible() then
    return
  end
  local data = self:getScrollData()
  for k, v in pairs(self.scrollCfg) do
    v.panel:setVisible(false)
  end
  if Lib.table_is_empty(data) then
    self.scrollCfg[type].scrollHelper:clearScrollData()
    self:setEmptyListVisible(true, type)
  else
    self.scrollCfg[type].scrollHelper:resetData(data)
    self:setEmptyListVisible(false)
  end
  self.scrollCfg[type].panel:setVisible(true)
  if type ~= Define.GangScrollIndex.MemberList then
    self.textScrollViewTitle:setText(Lang:toText(self.scrollCfg[type].titleTxt))
  else
    local gangName = Me:getMyGangName()
    self.textScrollViewTitle:setText(gangName)
    self.buttonApplyList:setVisible(Me:isChairMan())
  end
  Lib.emitEvent(Event.EVENT_REFRESH_GANG_OPEN_VIEW_BUTTON)
  if Me.gang then
    self.checkboxAutoJoin:setVisible(true)
    self.checkboxAutoJoin:setSelected(Me.gang.isAutoJoin)
  end
end

function M:setScrollType(type)
  self.currentScrollType = type
end

function M:initButtonEvent()
  function self.buttonClearApply.onMouseClick()
    Me:clearApplyList()
  end
  
  function self.buttonReturnApply.onMouseClick()
    self:setScrollType(Define.GangScrollIndex.MemberList)
    self:updateScrollView()
  end
  
  function self.buttonApplyList.onMouseClick()
    self:setScrollType(Define.GangScrollIndex.ApplyList)
    self:updateScrollView()
    Me:clearApplyListRed()
  end
  
  self:child("ButtonClosePanelGang").onMouseClick = function()
    self:close()
  end
  self:child("ButtonOpenCreateGang").onMouseClick = function()
    Lib.openWindow("./UI/gang/win_create_gang")
  end
  
  function self.buttonExitGang.onMouseClick()
    Me:exitGang(function()
      self:close()
      Lib.emitEvent(Event.EVENT_REFRESH_GANG_OPEN_VIEW_BUTTON)
      Lib.emitEvent(Event.EVENT_EXIT_GANG)
    end)
  end
  
  function self.buttonAutoJoin.onMouseClick()
    Me:autoJoinGangClient()
    self.buttonAutoJoin:setEnabled(false)
  end
  
  function self.checkboxAutoJoin.onMouseClick()
    Me:sendPacket({
      pid = "setGangAutoJoinC2S",
      auto = self.checkboxAutoJoin:isSelected()
    }, function(result)
      if result then
        Me:setGang(result)
      end
    end)
  end
end

function M:close()
  self:initData()
  Lib.closeWindow("./UI/gang/win_gang")
end

function M:onOpen()
  self:setUsingAutoRenderingSurface(true)
  M:init()
end

function M:initEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_REFRESH_GANG_VIEW, function(type)
    if type then
      self.currentScrollType = type
    end
    self:updateScrollView()
  end)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end
