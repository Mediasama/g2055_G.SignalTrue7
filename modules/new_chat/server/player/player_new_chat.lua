local Player = _ENV.Player

function Player:sendChatMsg(packet)
  if packet.msgData.msgType == Define.MsgType.Voice then
    if self:checkCanSendVoice() then
      self:updateVoiceCounts()
    else
      print(">>>>>>>>>>>>>>>>>>>  can not send voice!")
      return
    end
  end
  local pageType = packet.msgData.pageType
  if pageType == Define.ChatPage.Gang then
    self:sendChatMsgGang(packet)
  else
    WorldServer.BroadcastPacket(packet)
  end
end

function Player:sendChatMsgGang(packet)
  local memberList = Plugins.CallTargetPluginFunc("gangs", "getPlayerGangMemberList", self)
  if not memberList then
    return
  end
  for k, _ in pairs(memberList) do
    local member = Game.GetPlayerByUserId(k)
    if member and member:isValid() then
      member:sendPacket(packet)
    end
  end
end

function Player:checkVoiceMoonEnable()
  local mac = self:getSoundMoonCardMac()
  if mac == 0 then
    return false
  elseif 0 > mac - os.time() then
    self:setSoundMoonCardMac(0)
    return false
  else
    return true
  end
end

function Player:addMoonCard(reward)
  print(">>>>>>>>>>>>>>>>>>>>>>>> Player:addMoonCard:", reward, self:getSoundMoonCardMac())
  if self:getSoundMoonCardMac() == 0 then
    self:setSoundMoonCardMac(reward * 30 * 24 * 3600 + os.time())
  else
    self:setSoundMoonCardMac(reward * 30 * 24 * 3600 + self:getSoundMoonCardMac())
  end
end

function Player:addVoiceCnt(reward)
  print(">>>>>>>>>>>>>>>>>>>>>>>> Player:addVoiceCnt:", reward, self:getSoundTimes())
  self:setValue("soundTimes", self:getSoundTimes() + reward)
end

function Player:getVoiceCardTime()
  local mac = self:getSoundMoonCardMac()
  if mac == 0 then
    return -1
  else
    return math.max(-1, mac - os.time())
  end
end

function Player:initVoiceInfo(info)
  if info.expiryDateLong and tonumber(info.expiryDateLong) > 0 then
    self:setSoundMoonCardMac(tonumber(info.expiryDateLong))
  end
  if info.times and 0 < tonumber(info.times) then
    self:setValue("soundTimes", tonumber(info.times))
  end
  if info.freeTimes and 0 < tonumber(info.times) then
    self:setValue("freeSoundTimes", tonumber(info.times))
  end
end

function Player:updateVoiceCounts()
  if not self:checkVoiceMoonEnable() then
    if self:getFreeSoundTimes() > 0 then
      self:useFreeSoundTimes()
    elseif 0 < self:getSoundTimes() then
      self:useSoundTimes()
    end
  end
end

function Player:checkCanSendVoice()
  if not self:checkVoiceMoonEnable() and self:getSoundTimes() < 1 and 1 > self:getFreeSoundTimes() then
    return false
  end
  return true
end
