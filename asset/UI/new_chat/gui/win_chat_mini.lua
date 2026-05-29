local chatSetting = World.cfg.chatSetting
local widget_virtual_vert_list = require("ui.widget.widget_virtual_vert_list")
local ChatHelper = T(World, "ChatHelper")
local ChatUIHelper = T(World, "ChatUIHelper")

function M:init()
  self.bg = self:child("ImageBg")
  self.scrollViewMsg = self:child("ScrollViewMsg")
  self.msgList = self:child("VerticalMsgList")
  self.txtNewMsg = self:child("TextNewMsg")
  self.btnVoice = self:child("ButtonVoice")
  self.btnVoicePack = self:child("ButtonVoicePack")
  self.btnVoicePack:setVisible(World.cfg.useVoicePack)
  self.btnEmoji = self:child("ButtonEmoji")
  self.imageNewMsgBg = self:child("ImageNewMsgBg")
  self.isOpenMode = false
  self.bgHeight = self.bg:getHeight()
  self.bgWidth = self.bg:getWidth()
  self.cacheShowMsgList = {}
  self.newMsgNum = 0
  self.imageVoiceInputSize = self.btnVoice:getPixelSize()
  self.textSoundNum = self.ImageBg.WndFunction.ButtonVoice.TextSoundNum
  self:resetSoundNum()
  self.openHeight = self.bgHeight[2] + chatSetting.miniWndExtraHeight
  self:setNewMsgTips()
  self:setEmojiBtnAndVoiceDisplay()
  self:child("ButtonOpen").onMouseButtonUp = function()
    self.isOpenMode = not self.isOpenMode
    if self.isOpenMode then
      self.bg:setHeight({
        0,
        self.openHeight
      })
    else
      self.bg:setHeight(self.bgHeight)
      self.messageView:setVirtualBarPosition(1)
    end
  end
  
  function self.txtNewMsg.onWindowTouchUp()
    self.imageNewMsgBg:setVisible(false)
    self:popCacheNewMsg()
  end
  
  function self.scrollViewMsg.onWindowTouchUp(window, instance, x, y)
    if (Lib.v2(x, y) - self.touchPos):len() < 5 then
      Lib.openWindow("./UI/new_chat/gui/win_chat_main")
      self:close()
    end
  end
  
  function self.scrollViewMsg.onWindowTouchDown(window, instance, x, y)
    self.touchPos = Lib.v2(x, y)
  end
  
  self.messageView = widget_virtual_vert_list:init(self.scrollViewMsg, self.msgList, function(self, parentWindow)
    local item = UI:openWidget("./UI/new_chat/gui/widget_chat_mini_item")
    parentWindow:addChild(item:getWindow())
    item:setWidth({1, 0})
    return item
  end, function(self, childWindow, msg)
    childWindow:initData(msg)
  end)
  self.messageView:addVirtualChildList(ChatHelper:getMiniMsgList())
  World.Timer(1, function()
    self.messageView:setVirtualBarPosition(1)
  end)
  self.checkNewTipsTimer = World.Timer(5, function()
    if tonumber(self.msgList:getProperty("endOffset")) > 10 then
      self.isBottom = false
    else
      self.isBottom = true
      self:popCacheNewMsg()
    end
    self:setNewMsgTips()
    return true
  end)
  
  function self.btnVoice.onMouseButtonDown()
    if not Me:getCanSendSound() then
      ChatUIHelper:openCardShop()
      return
    end
    Lib.openWindow("./UI/new_chat/gui/win_chat_voice_record")
  end
  
  function self.btnVoice.onMouseButtonUp(instance, window, x, y)
    Lib.closeWindow("./UI/new_chat/gui/win_chat_voice_record")
  end
  
  function self.btnVoice.onMouseMove(instance, window, x, y)
    if UI:isOpenWindow("./UI/new_chat/gui/win_chat_voice_record") then
      local nodeX = CEGUICoordConverter.screenToWindowX1(self.btnVoice:getWindow(), x)
      local nodeY = CEGUICoordConverter.screenToWindowY1(self.btnVoice:getWindow(), y)
      if nodeY < -chatSetting.voiceCancelEdge or nodeX < -chatSetting.voiceCancelEdge or nodeX > self.imageVoiceInputSize.width + chatSetting.voiceCancelEdge or nodeY > self.imageVoiceInputSize.height + chatSetting.voiceCancelEdge then
        Lib.emitEvent(Event.EVENT_VOICE_TOUCH_OUT_AREA)
      else
        Lib.emitEvent(Event.EVENT_VOICE_TOUCH_IN_AREA)
      end
    end
  end
  
  function self.btnEmoji.onMouseButtonUp()
    if UI:isOpenWindow("./UI/new_chat/gui/win_chat_emoji") then
      Lib.closeWindow("./UI/new_chat/gui/win_chat_emoji")
    else
      Lib.openWindow("./UI/new_chat/gui/win_chat_emoji")
    end
  end
  
  function self.btnVoicePack.onMouseButtonDown()
    Plugins.CallTargetPluginFunc("voice_pack", "openVoicePack")
  end
  
  self:initEvent()
end

function M:initEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("", Event.EVENT_PUSH_CHAT_MSG, function(msgData)
    if chatSetting.miniChatCfg.showPageType[msgData.pageType] then
      self:pushNewCacheMsg(msgData)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_SEND_VOICE, function(time, url)
    self:sendVoiceMsg(time, url)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_VOICE_FILE_ERROR, function(errorType)
    Client.ShowTip(1, Lang:toText("new.chat.voice.fail"), Define.TipsShowTime)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SOUND_TIME_CHANGE, function(value)
    self:resetSoundNum()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SOUND_MOON_CHANGE, function(value)
    self:resetSoundNum()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_FREE_SOUND_TIME_CHANGE, function(value)
    self:resetSoundNum()
  end)
end

function M:setEmojiBtnAndVoiceDisplay()
  local showEmojiBtn = chatSetting.miniChatCfg.showEmojiBtn
  local showVoiceBtn = chatSetting.miniChatCfg.showVoiceBtn
  self.btnEmoji:setVisible(showEmojiBtn)
  self.btnVoice:setVisible(showVoiceBtn)
  if showVoiceBtn then
    self.btnVoice:setXPosition(showEmojiBtn and {
      0,
      -(self.btnEmoji:getWidth()[2] + 10)
    } or {0, 0})
  end
end

function M:sendVoiceMsg(time, url)
  ChatHelper:sendChatMsg(Define.ChatPage.World, {
    fromId = Me.platformUserId,
    msg = {uri = url, voiceTime = time},
    msgType = Define.MsgType.Voice
  })
end

function M:pushNewCacheMsg(msgData)
  if #self.cacheShowMsgList >= chatSetting.pageMsgMaxCount then
    table.remove(self.cacheShowMsgList, 1)
  end
  table.insert(self.cacheShowMsgList, msgData)
  self.newMsgNum = self.newMsgNum + 1
end

function M:popCacheNewMsg()
  if #self.cacheShowMsgList > 0 then
    self.messageView:addVirtualChildList(self.cacheShowMsgList)
    local delCount = self.messageView:getVirtualChildCount() - chatSetting.pageMsgMaxCount
    if 0 < delCount then
      for i = 1, delCount do
        self.messageView:delVirtualChild(1)
      end
    end
    self.cacheShowMsgList = {}
    self.messageView:setVirtualBarPosition(1)
  end
  self.newMsgNum = 0
end

function M:setNewMsgTips()
  if #self.cacheShowMsgList > 0 then
    self.imageNewMsgBg:setVisible(true)
    self.txtNewMsg:setText(Lang:toText({
      "new_chat_new_msg_tips",
      self.newMsgNum > 99 and "99+" or self.newMsgNum
    }))
  else
    self.imageNewMsgBg:setVisible(false)
  end
end

function M:resetSoundNum()
  self.textSoundNum:setText(Me:getSoundTimesString())
end

function M:onClose()
  for _, v in pairs(self._allEvent) do
    v()
  end
  self._allEvent = {}
  self.cacheShowMsgList = {}
  self.isBottom = false
  self.newMsgNum = 0
  self.messageView:clearVirtualChild()
  if self.checkNewTipsTimer then
    self.checkNewTipsTimer()
    self.checkNewTipsTimer = nil
  end
end

M:init()
