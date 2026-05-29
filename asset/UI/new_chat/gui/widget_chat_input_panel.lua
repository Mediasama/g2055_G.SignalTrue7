local chatSetting = World.cfg.chatSetting
local ChatHelper = T(World, "ChatHelper")
local ChatUIHelper = T(World, "ChatUIHelper")
M.InputState = {
  InputText = 1,
  InputVoice = 2,
  InputDisable = 3
}

function M:init()
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:setInputState(M.InputState.InputText)
end

function M:initUI()
  self.panelInputText = self.PanelInputText
  self.textTipsText = self.PanelInputText.EditboxInput.TextTipsText
  self.textVoiceTips = self.PanelInputVoice.ImageMic.TextVoiceTips
  self.editbox = self.PanelInputText.EditboxInput
  self.buttonEmoji = self.ButtonEmoji
  self.buttonMic = self.PanelInputText.ButtonMic
  self.panelInputVoice = self.PanelInputVoice
  self.buttonKeyboard = self.PanelInputVoice.ButtonKeyboard
  self.imageVoiceInput = self.PanelInputVoice.ImageVoiceInput
  self.imageVoiceInputSize = self.imageVoiceInput:getPixelSize()
  self.panelInputDisable = self.PanelInputDisable
  self.buttonSend = self.ButtonSend
  self.textSoundNum = self.PanelInputText.ButtonMic.TextSoundNum
  self.editbox:setMaxTextLength(chatSetting.maxMsgSize or 150)
  self.textTipsText:setText(Lang:toText("new_chat_input_tips"))
  self.textVoiceTips:setText(Lang:toText("new_chat_input_tips_voice"))
  self:resetSoundNum()
end

function M:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHAT_MAIN_CLOSE, function()
  end)
  
  function self.editbox.onMouseButtonDown()
    self.textTipsText:setText("")
  end
  
  function self.editbox.onMouseButtonUp()
  end
  
  function self.editbox.onTextAccepted()
  end
  
  function self.buttonSend.onMouseButtonUp()
    local inputText = self.editbox:getText()
    if inputText and 0 < #inputText then
      self:sendTextMsg(inputText)
    end
    self.editbox:setProperty("Text", "")
    self.textTipsText:setText(Lang:toText("new_chat_input_tips"))
  end
  
  function self.buttonEmoji.onMouseButtonUp()
    Lib.openWindow("./UI/new_chat/gui/win_chat_emoji")
  end
  
  function self.buttonMic.onMouseButtonUp()
    if not Me:getCanSendSound() then
      ChatUIHelper:openCardShop()
      return
    end
    self:setInputState(M.InputState.InputVoice)
  end
  
  function self.buttonKeyboard.onMouseButtonUp()
    self:setInputState(M.InputState.InputText)
  end
  
  function self.imageVoiceInput.onMouseButtonDown()
    if not Me:getCanSendSound() then
      ChatUIHelper:openCardShop()
      return
    end
    Lib.openWindow("./UI/new_chat/gui/win_chat_voice_record")
  end
  
  function self.imageVoiceInput.onMouseButtonUp()
    Lib.closeWindow("./UI/new_chat/gui/win_chat_voice_record")
  end
  
  function self.imageVoiceInput.onMouseMove(instance, window, x, y)
    if UI:isOpenWindow("./UI/new_chat/gui/win_chat_voice_record") then
      local nodeX = CEGUICoordConverter.screenToWindowX1(self.imageVoiceInput:getWindow(), x)
      local nodeY = CEGUICoordConverter.screenToWindowY1(self.imageVoiceInput:getWindow(), y)
      if nodeY < 0 or nodeX < 0 or nodeX > self.imageVoiceInputSize.width then
        Lib.emitEvent(Event.EVENT_VOICE_TOUCH_OUT_AREA)
      else
        Lib.emitEvent(Event.EVENT_VOICE_TOUCH_IN_AREA)
      end
    end
  end
  
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

function M:sendVoiceMsg(time, url)
  local chatPage = ChatHelper:getCurPage()
  local chatTarget = ChatHelper:getCurChatTarget()
  if not ChatHelper:canSend(chatPage) then
    Client.ShowTip(1, Lang:toText("new.chat.can.not.send"), Define.TipsShowTime)
    return
  end
  print("M:sendVoiceMsg(inputText) ", chatPage, chatTarget)
  ChatHelper:sendChatMsg(chatPage, {
    fromId = Me.platformUserId,
    msg = {uri = url, voiceTime = time},
    msgType = Define.MsgType.Voice,
    targetUserId = chatTarget
  })
end

function M:sendTextMsg(inputText)
  local chatPage = ChatHelper:getCurPage()
  local chatTarget = ChatHelper:getCurChatTarget()
  if not ChatHelper:canSend(chatPage) then
    Client.ShowTip(1, Lang:toText("new.chat.can.not.send"), Define.TipsShowTime)
    return
  end
  print("M:sendTextMsg(inputText) ", chatPage, chatTarget)
  ChatHelper:sendChatMsg(chatPage, {
    fromId = Me.platformUserId,
    msg = inputText,
    msgType = Define.MsgType.Text,
    targetUserId = chatTarget
  })
end

function M:setInputState(state)
  self.panelInputText:setVisible(state == M.InputState.InputText)
  self.panelInputVoice:setVisible(state == M.InputState.InputVoice)
  self.panelInputDisable:setVisible(state == M.InputState.InputDisable)
end

function M:resetSoundNum()
  self.textSoundNum:setText(Me:getSoundTimesString())
end

function M:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

M:init()
