local GangsManager = require("server.gangs_manager_server")
local Player = _ENV.Player

function Player:getGangId()
  return self.gangId
end

function Player:hasGang()
  return self.gangId ~= nil
end

function Player:getGangMemberList()
  local gangId = self:getGangId()
  if gangId then
    local gangMgr = GangsManager:getInstance()
    local gang = gangMgr:getGang(gangId)
    if gang then
      return gang.memberList
    end
  end
  return {}
end

function Player:setGangId(id)
  if id == nil then
    self:setValue("gangIconInfo", nil)
  else
    local gangMgr = GangsManager:getInstance()
    local gang = gangMgr:getGang(id)
    if gang == nil then
      self:setValue("gangIconInfo", nil)
    else
      self:setValue("gangIconInfo", {
        id = gang.logoId,
        name = gang.name,
        gangId = id
      })
    end
  end
  self.gangId = id
end

function Player:createNewGang(packet)
  local gangMgr = GangsManager:getInstance()
  local gangId = gangMgr:createNewGang(self, packet)
  if gangId then
    self:setGangId(gangId)
  end
  return gangId
end

function Player:applyJoinGang(packet)
  local gangMgr = GangsManager:getInstance()
  return gangMgr:applyJoinGang(packet.gangId, self)
end

function Player:leaveGang()
  local gangMgr = GangsManager:getInstance()
  gangMgr:leaveGangs(self)
  self:setGangId(nil)
end

function Player:processApplications(packet)
  local applyPlayerUserId = packet.userId
  local action = packet.action
  local gangMgr = GangsManager:getInstance()
  if gangMgr:playerIsChairMan(self) then
    local code = gangMgr:processApplications(self:getGangId(), applyPlayerUserId, action)
    if code == Define.GangsPacketCode.Success then
      self:sendPacket({
        pid = "onUpdateGang",
        gang = gangMgr:getGang(self:getGangId())
      })
    end
    return code
  end
end

function Player:updateApplyList(applyList)
  self:sendPacket({
    pid = "onUpdateApplyList",
    applyList = applyList
  })
end

function Player:updateBeChairMan(gang)
  self:setGangId(gang.gangId)
  self:sendPacket({
    pid = "onUpdateBeChairMan",
    gang = gang
  })
end

function Player:updateApplyResult(gang)
  self:setGangId(gang.gangId)
  self:sendPacket({
    pid = "onNotifyApplyAccept",
    gang = gang
  })
end

function Player:onExitClearGangInfo()
  self:leaveGang()
  return true
end

function Player:autoJoinGang()
  return GangsManager:getInstance():autoJoinGang(self)
end

function Player:autoJoinOneGang(packet)
  return GangsManager:getInstance():autoJoinOneGang(self, packet.gangId)
end
