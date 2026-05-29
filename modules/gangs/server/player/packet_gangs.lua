local GangsManager = require("server.gangs_manager_server")
local handles = T(Player, "PackageHandlers")

function handles:onCreateNewGang(packet)
  if packet.name == "" then
    return {
      code = Define.GangsPacketCode.GangNameNull
    }
  end
  if Lib.subStringGetTotalIndex(packet.name) > World.cfg.gangCfg.gangNameMaxLen then
    return {
      code = Define.GangsPacketCode.GangNameTooLong
    }
  end
  if self:hasGang() then
    return {
      code = Define.GangsPacketCode.HasGangs
    }
  end
  local name = packet.name
  local content = World.CurWorld:filterWord(name)
  if content ~= name then
    return {
      code = Define.GangsPacketCode.SensitiveWord
    }
  end
  local gangMgr = GangsManager:getInstance()
  if gangMgr:checkGangNameExist(name) then
    return {
      code = Define.GangsPacketCode.GangNameExist
    }
  end
  local gangId = self:createNewGang(packet)
  local code = Define.GangsPacketCode.Success
  local gang
  if gangId == nil then
    code = Define.GangsPacketCode.CreateFail
  else
    gang = gangMgr:getGang(gangId)
  end
  return {code = code, gang = gang}
end

function handles:onProcessApplications(packet)
  return {
    code = self:processApplications(packet)
  }
end

function handles:onClearApplyList(packet)
  local gangMgr = GangsManager:getInstance()
  gangMgr:clearGangApplyInfo(self:getGangId(), self)
end

function handles:onApplyJoinGang(packet)
  local code = self:applyJoinGang(packet)
  return {code = code}
end

function handles:onRequestGangsData()
  local gangMgr = GangsManager:getInstance()
  return {
    gangList = gangMgr:getGangsList()
  }
end

function handles:onRequestMyGangData(packet)
  local gangMgr = GangsManager:getInstance()
  return {
    gang = gangMgr:getGang(self:getGangId())
  }
end

function handles:onExitGang(packet)
  self:leaveGang()
  return true
end

function handles:onGetTerritoryAward(packet)
  local gangMgr = GangsManager:getInstance()
  gangMgr:getTerritoryAward(self)
end

function handles:autoJoinGangC2S(packet)
  local code, resultList = self:autoJoinGang(packet)
  return {code = code, resultList = resultList}
end

function handles:autoJoinOneGangC2S(packet)
  local code = self:autoJoinOneGang(packet)
  return {code = code}
end

function handles:setGangAutoJoinC2S(packet)
  if not packet then
    return
  end
  local gang = GangsManager:getInstance():getGang(self:getGangId())
  if gang and GangsManager:getInstance():playerIsChairMan(self) then
    gang.isAutoJoin = packet.auto
  end
  return gang
end
