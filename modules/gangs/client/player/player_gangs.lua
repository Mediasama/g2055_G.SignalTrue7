local Player = _ENV.Player
Player.firstOpenGangWin = true
Player.gangGreenButtonArrowShowed = false

function Player:setGang(gang)
  self.gang = gang
  if gang == nil then
    self:clearApplyListRed()
  end
  local allTerritoryEntity = self:getAllTerritoryEntity()
  if allTerritoryEntity then
    for i = 1, #allTerritoryEntity do
      local object = World.CurWorld:getObject(allTerritoryEntity[i])
      if object and object:isValid() then
        object:updateTerritoryOwnerEntityEffect()
      end
    end
  end
end

local function toastNameTooLong()
  local str = Lang:getMessage(Define.GangsPacketCodeToastTips[Define.GangsPacketCode.GangNameTooLong])
  local text = string.format(str, World.cfg.gangCfg.gangNameMaxLen)
  Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", text)
end

function Player:createNewGang(logoId, name, cb)
  if name == "" or name == nil then
    Lib.logInfo("===\229\144\141\229\173\151\228\184\141\232\131\189\228\184\186\231\169\186========")
    return
  end
  if Lib.subStringGetTotalIndex(name) > World.cfg.gangCfg.gangNameMaxLen then
    toastNameTooLong()
    return
  end
  self:sendPacket({
    pid = "onCreateNewGang",
    logoId = logoId,
    name = name
  }, function(result)
    if result.code == Define.GangsPacketCode.Success then
      local gang = result.gang
      if gang then
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText("gang.tips.create.gang.success"))
        self:setGang(gang)
        if self.gang then
          Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW, Define.GangScrollIndex.MemberList)
        end
      end
    elseif result.code and Define.GangsPacketCodeToastTips[result.code] then
      if Define.GangsPacketCode.GangNameTooLong == result.code then
        toastNameTooLong()
      elseif Define.GangsPacketCodeToastTips[result.code] then
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.GangsPacketCodeToastTips[result.code]))
      end
    end
    if cb then
      cb(result.code)
    end
  end)
end

function Player:applyJoinGang(gangId, cb)
  self:sendPacket({
    pid = "onApplyJoinGang",
    gangId = gangId
  }, function(result)
    if cb then
      cb(result)
    end
    if result.code and result.code ~= Define.GangsPacketCode.Success and Define.GangsPacketCodeToastTips[result.code] and Define.GangsPacketCodeToastTips[result.code] then
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.GangsPacketCodeToastTips[result.code]))
    end
  end)
end

function Player:refreshPlayerHeadGangInfo(gang)
  if gang then
    local memberList = gang.memberList
    if memberList then
      for k, v in pairs(memberList) do
        local objID = v.objID
        local entity = World.CurWorld:getEntity(objID)
        if entity and entity:isValid() then
          Lib.emitEvent(Event.EVENT_REFRESH_PLAYER_GANG_ICON, objID, entity:getValue("gangIconInfo"))
        end
      end
    end
  end
end

function Player:notifyApplyAccept(packet)
  self:setGang(packet.gang)
  Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW, Define.GangScrollIndex.MemberList)
  Lib.emitEvent(Event.EVENT_REFRESH_GANG_OPEN_VIEW_BUTTON)
  self:refreshPlayerHeadGangInfo(packet.gang)
end

function Player:updateBeChairMan(packet)
  self:setGang(packet.gang)
  Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW, Define.GangScrollIndex.MemberList)
end

function Player:processApplications(userId, action)
  if userId and self:isChairMan() then
    self:sendPacket({
      pid = "onProcessApplications",
      userId = userId,
      action = action
    }, function(result)
      self.gang.applyList[userId] = nil
      Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW)
      if result.code and result.code ~= Define.GangsPacketCode.Success and Define.GangsPacketCodeToastTips[result.code] then
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.GangsPacketCodeToastTips[result.code]))
      end
    end)
  end
end

function Player:getCurGangMEmberNum()
  if self.gang == nil then
    return 0
  end
  return self.gang.memberNumber
end

function Player:isChairMan()
  if self.gang == nil then
    return false
  end
  return self.gang.chairMan == self.platformUserId
end

function Player:getChairMan()
  if self.gang == nil then
    return nil
  end
  return self.gang.chairMan
end

function Player:updateApplyList(list)
  if self.gang then
    self.gang.applyList = list
    self.applyListRed = true
    Lib.emitEvent(Event.EVENT_UPDATE_GANG_APPLY_LIST, true)
  end
end

function Player:clearApplyListRed()
  self.applyListRed = false
  Lib.emitEvent(Event.EVENT_UPDATE_GANG_APPLY_LIST, false)
end

function Player:getApplyList()
  if self:isChairMan() then
    return self.gang.applyList
  end
  return {}
end

function Player:clearApplyList()
  if self.gang == nil or Lib.table_is_empty(self.gang) or self.gang.applyList and Lib.table_is_empty(self.gang.applyList) then
    return
  end
  self:sendPacket({
    pid = "onClearApplyList"
  }, function()
    self.gang.applyList = {}
    Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW)
  end)
end

function Player:requestGangsData(cb)
  if self.gang then
    self:requestMyGangData(cb)
  else
    self:requestAllGangData()
  end
end

function Player:requestMyGangData(cb)
  self:sendPacket({
    pid = "onRequestMyGangData"
  }, function(result)
    self:setGang(result.gang)
    if self.applyListRed then
      Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW, Define.GangScrollIndex.ApplyList)
      self.applyListRed = false
    else
      Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW, Define.GangScrollIndex.MemberList)
    end
    if cb then
      cb()
    end
  end)
end

function Player:requestAllGangData(cb)
  self:sendPacket({
    pid = "onRequestGangsData"
  }, function(result)
    local gangList = result.gangList or {}
    self.gangList = {}
    for k, v in pairs(gangList) do
      if v.memberNumber < World.cfg.gangCfg.gangMaxMember then
        self.gangList[#self.gangList + 1] = v
      end
    end
    Lib.emitEvent(Event.EVENT_REFRESH_GANG_VIEW, Define.GangScrollIndex.GangList)
    if cb then
      cb()
    end
  end)
end

function Player:getGangList()
  return self.gangList
end

function Player:exitGang(cb)
  self:sendPacket({pid = "onExitGang"}, function(result)
    local gang = self.gang
    self:setGang(nil)
    self:refreshPlayerHeadGangInfo(gang)
    if cb then
      cb()
    end
  end)
end

function Player:getMyGangName()
  if self.gang then
    return self.gang.name
  end
  return ""
end

function Player:getGangId()
  if self.gang then
    return self.gang.gangId
  end
  return nil
end

function Player:isSameGang(entity)
  if not (entity ~= nil and entity:isValid()) or not entity.isPlayer then
    return false
  end
  local gangData = entity:getValue("gangIconInfo")
  if gangData == nil then
    return false
  end
  local gangId = gangData.gangId
  return self:isMyGang(gangId)
end

function Player:isMyGang(gangId)
  if self.gang and self.gang.gangId then
    return self.gang.gangId == gangId
  end
  return false
end

function Player:isSameGang2(entity)
  if not (entity ~= nil and entity:isValid()) or not entity.isPlayer then
    return false
  end
  local gangData = entity:getValue("gangIconInfo")
  if gangData == nil then
    return false
  end
  local gangDataMine = self:getValue("gangIconInfo")
  if gangDataMine == nil then
    return false
  end
  return gangData.gangId == gangDataMine.gangId
end

local GangIconConfig = T(Config, "GangIconConfig")

function Player:getGangButtonIcon()
  if self.gang then
    return GangIconConfig:getGangButtonIcon(self.gang.logoId)
  else
    return "gameres|asset/Imageset/g2055_icon:icon_0_gang05"
  end
end

function Player:getGangMemberList()
  if self.gang then
    return self.gang.memberList
  end
  return {}
end

function Player:hasGang()
  return self.gang ~= nil
end

function Player:getTerritoryAward()
  self:sendPacket({
    pid = "onGetTerritoryAward"
  })
end

function Player:autoJoinGangClient()
  self:sendPacket({
    pid = "autoJoinGangC2S"
  }, function(result)
    if result then
      Lib.emitEvent(Event.EVENT_UPDATE_ALL_APPLY_BUTTON, result.resultList)
    end
  end)
end

function Player:autoJoinOneGangClient(gangId, cb)
  if not gangId then
    return
  end
  self:sendPacket({
    pid = "autoJoinOneGangC2S",
    gangId = gangId
  }, function(result)
    if result then
      if result.code and result.code ~= Define.GangsPacketCode.Success and result.code ~= Define.GangsPacketCode.SuccessApply and Define.GangsPacketCodeToastTips[result.code] then
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.GangsPacketCodeToastTips[result.code]))
      end
      if cb then
        cb(result)
      end
    end
  end)
end
