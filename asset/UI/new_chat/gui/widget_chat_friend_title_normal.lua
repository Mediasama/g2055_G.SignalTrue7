local chatSetting = World.cfg.chatSetting
local widget_virtual_vert_list = require("ui.widget.widget_virtual_vert_list")
M.PanelState = {Expand = 1, Collapse = 2}
M.ArrowImageList = {
  "set:chat.json image:btn_0_hide02",
  "set:chat.json image:btn_0_hide01"
}

function M:init()
  self.friendData = nil
  self.friendType = nil
  self.panelState = nil
  self.lastRequestDataTime = 0
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imageBG = self.ImageBG
  self.imageArrow = self.ImageBG.ImageArrow
  self.textTitle = self.ImageBG.TextTitle
  self.textNum = self.ImageBG.TextNum
  self.panelFriendList = self.PanelFriendList
  self.scrollView = self.PanelFriendList.ScrollableView
  self.rootInitHeight = self:getHeight()[2]
  self.rootCurHeight = self.rootInitHeight
  self.friendInfoItemHeight = 100
  self.isScrollDown = true
  self.friendListView = widget_virtual_vert_list:init(self.scrollView, self.scrollView.VerticalLayout, function(target, parentWindow)
    local item = UI:openWidget("./UI/new_chat/gui/widget_chat_friend_info_item")
    self.friendInfoItemHeight = item:getHeight()[2]
    parentWindow:addChild(item:getWindow())
    return item
  end, function(self, childWindow, data)
    childWindow:initData(data)
  end)
end

function M:initEvent()
  function self.imageBG.onWindowTouchDown()
    if self.panelState == M.PanelState.Collapse then
      self:setPanelState(M.PanelState.Expand)
    else
      self:setPanelState(M.PanelState.Collapse)
    end
  end
  
  function self.scrollView.onScrolled()
    if not self.friendData or not self.friendData.pageNo then
      return
    end
    if not self:canRequestNextPageData() then
      return
    end
    local scrollPos = tonumber(self.scrollView:getWindow():getProperty("VertScrollPosition"))
    if scrollPos <= 0 and self.friendData.pageNo > 0 then
      self:requestNextPageData(self.friendData.pageNo - 1, false)
    elseif 1 <= scrollPos and self.friendData.pageNo < self.friendData.totalPage - 1 then
      self:requestNextPageData(self.friendData.pageNo + 1, true)
    end
  end
  
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_FRIEND_LIST_EXPAND, function(friendType)
    if self.friendType ~= friendType then
      self:setPanelState(M.PanelState.Collapse)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_FRIEND_LIST_SHOW, function(type)
    if self.friendType ~= type then
      return
    end
    self:resetData(Me.allFriendData[self.friendType])
    self.scrollView:getWindow():setProperty("VertScrollPosition", self.isScrollDown and 0 or 1)
  end)
end

function M:onOpen(friendType)
  self.friendType = friendType
  local titleText = self.friendType == Define.chatFriendType.platform and "new.chat.friend.platformFriend" or "new.chat.friend.gameFriend"
  self.textTitle:setText(Lang:toText(titleText))
  self:resetData(Me.allFriendData[friendType])
  self:setPanelState(M.PanelState.Collapse)
end

function M:resetData(data)
  if not data then
    return
  end
  self.friendData = data
  self.friendListView:clearVirtualChild()
  local onlineNum = 0
  local totalFriendNum = self.friendData.totalSize or 0
  local dataList = self.friendData.dataList
  for key = 1, #dataList do
    if dataList[key].status ~= Define.onlineStatus.offline then
      onlineNum = onlineNum + 1
    end
    local friendInfoData = {
      friendType = self.friendType,
      friendData = dataList[key]
    }
    self.friendListView:addVirtualChild(friendInfoData)
  end
  self.textNum:setText(onlineNum .. "/" .. totalFriendNum)
  self:adjustHeight(#dataList)
end

function M:adjustHeight(dataNum)
  local showCellNumMax = chatSetting.friendPanelCfg.showCellNum
  local showCellNum = math.min(showCellNumMax, dataNum)
  local panelListHeight = showCellNum * self.friendInfoItemHeight
  self.panelFriendList:setHeight({0, panelListHeight})
  self.rootCurHeight = panelListHeight + self.rootInitHeight
  if self.panelState == M.PanelState.Expand then
    self:setHeight({
      0,
      self.rootCurHeight
    })
  end
end

function M:setPanelState(state)
  self.panelState = state
  self.panelFriendList:setVisible(state == M.PanelState.Expand)
  self.imageArrow:setImage(M.ArrowImageList[state])
  if state == M.PanelState.Collapse then
    self:setHeight({
      0,
      self.rootInitHeight
    })
  elseif state == M.PanelState.Expand then
    self:setHeight({
      0,
      self.rootCurHeight
    })
    Lib.emitEvent(Event.EVENT_CHAT_FRIEND_LIST_EXPAND, self.friendType)
  end
end

function M:canRequestNextPageData()
  return os.time() - self.lastRequestDataTime >= Define.requestDataTimeInterval
end

function M:requestNextPageData(page, isDown)
  print("-------------- M:requestNextPageData:", page)
  self.isScrollDown = isDown
  self.lastRequestDataTime = os.time()
  Me:doRequestServerFriendInfo(self.friendType, page)
end

function M:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.friendListView then
    self.friendListView:clearVirtualChild()
  end
end

M:init()
