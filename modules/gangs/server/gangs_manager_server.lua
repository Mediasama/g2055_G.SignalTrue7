local uuid = require("common.uuid")
local TerritoryServer = T(Lib, "TerritoryServer")
local GangsManager = Lib.class("GangsManager")
local instance

function GangsManager:getInstance()
  if instance == nil then
    instance = GangsManager.new()
  end
  return instance
end

function GangsManager:ctor()
  self.gangsList = {}
  self:init()
end

function GangsManager:init()
end

function GangsManager:getGangsList()
  return self.gangsList
end

function GangsManager:getGang(gangId)
  return self.gangsList[gangId]
end

function GangsManager:playerIsChairMan(player)
  local gangId = player:getGangId()
  local gang = self:getGang(gangId)
  if gang == nil then
    return false
  end
  return gang.chairMan == player.platformUserId
end

function GangsManager:checkGangNameExist(name)
  for k, v in pairs(self.gangsList) do
    if name == v.name then
      return true
    end
  end
  return false
end

function GangsManager:report_team_info_territory_change(gangId, isAdd)
  local gang = self:getGang(gangId)
  if gang == nil then
    return
  end
  local team_info_type = Define.GangTeamInfoType.TerritoryAdd
  if not isAdd then
    team_info_type = Define.GangTeamInfoType.TerritoryMinus
  end
  self:report_team_info(team_info_type, gang)
end

function GangsManager:report_team_info(team_info_type, gang)
  if gang == nil then
    return
  end
  local chairManUserId = gang.chairMan
  local player = Game.GetPlayerByUserId(chairManUserId)
  if player and player:isValid() then
    local team_member_id = ""
    for k, v in pairs(gang.memberList) do
      team_member_id = team_member_id .. k .. ","
    end
    local reportData = {
      team_id = gang.gangId,
      team_player_num = gang.memberNumber,
      team_member_id = team_member_id,
      team_territory_id = TerritoryServer:export_getGangTerritoryIds(gang.gangId),
      team_logo_id = gang.logoId,
      team_leader_id = gang.chairMan,
      team_info_type = team_info_type,
      server_id = player:getValue("game_id"),
      create_user_id = gang.create_user_id,
      create_time = gang.create_time,
      game_time = os.time() - gang.create_time,
      total_game_time = World.Now() / 20
    }
    player:evt_reportEvent("team_info", reportData, false)
  end
end

function GangsManager:createNewGang(player, packet)
  if not player or not player:isValid() then
    return nil
  end
  local gangId = uuid()
  local chairManUserId = player.platformUserId
  local gang = {
    nextProfitsTime = os.time() + World.cfg.gangCfg.profitsTime,
    create_time = os.time(),
    create_user_id = chairManUserId,
    gangId = gangId,
    chairMan = chairManUserId,
    logoId = packet.logoId,
    name = packet.name,
    memberList = {
      [chairManUserId] = self:genNewGangMemberData(player, Define.GangsPosition.ChairMan)
    },
    applyList = {},
    memberNumber = 1,
    isAutoJoin = World.cfg.gangAutoJoin == nil or World.cfg.gangAutoJoin,
    territoryList = {}
  }
  self.gangsList[gangId] = gang
  TerritoryServer:export_enterGang(chairManUserId, gangId)
  player:evt_player_team_operation(Define.GangOperationType.Create)
  self:report_team_info(Define.GangTeamInfoType.Create, gang)
  return gangId
end

function GangsManager:clearGangApplyInfo(gangId, player)
  if self:playerIsChairMan(player) then
    local gang = self:getGang(gangId)
    gang.applyList = {}
  end
end

function GangsManager:genNewGangMemberData(player, pos)
  return {
    position = pos,
    userId = player.platformUserId,
    name = player.name,
    objID = player.objID,
    enterTime = os.time(),
    pts = 0
  }
end

function GangsManager:addPlayer(gang, player)
  local userId = player.platformUserId
  local memberList = gang.memberList
  if memberList[userId] == nil then
    memberList[userId] = self:genNewGangMemberData(player, Define.GangsPosition.Member)
    gang.memberNumber = gang.memberNumber + 1
  end
  TerritoryServer:export_enterGang(userId, gang.gangId)
  player:evt_player_team_operation(Define.GangOperationType.Join)
  self:report_team_info(Define.GangTeamInfoType.Join, gang)
end

function GangsManager:isGangMaxMember(gang)
  if gang.memberNumber >= World.cfg.gangCfg.gangMaxMember then
    gang.applyList = {}
    return true
  end
  return false
end

function GangsManager:leaveGangs(player)
  local userId = player.platformUserId
  self:clearPlayerApplyInfo(userId)
  local gangId = player:getGangId()
  if gangId then
    local gang = self:getGang(gangId)
    if gang == nil then
      return nil
    end
    local memberList = gang.memberList
    if memberList[userId] == nil then
      return nil
    end
    player:evt_player_team_operation(Define.GangOperationType.Leave, os.time() - gang.create_time)
    self:report_team_info(Define.GangTeamInfoType.Exit, gang)
    memberList[userId] = nil
    gang.memberNumber = gang.memberNumber - 1
    if gang.memberNumber == 0 then
      self.gangsList[gangId] = nil
      self:updateTopGang()
      TerritoryServer:export_onGangDismiss(gangId)
      player:evt_player_team_operation(Define.GangOperationType.Dismiss)
      self:report_team_info(Define.GangTeamInfoType.AllPlayerLeave, gang)
      return
    end
    if gang.chairMan == player.platformUserId then
      player:evt_player_team_operation(Define.GangOperationType.Transfer)
      self:report_team_info(Define.GangTeamInfoType.ChairManChange, gang)
      self:resetChairMan(gang)
    end
  end
end

function GangsManager:applyJoinGang(gangId, player)
  if player == nil or not player:isValid() then
    return Define.GangsPacketCode.Other
  end
  local gang = self:getGang(gangId)
  if gang == nil then
    return Define.GangsPacketCode.Other
  end
  if self:isGangMaxMember(gang) then
    return Define.GangsPacketCode.MaxMember
  end
  gang.applyList[player.platformUserId] = {
    userId = player.platformUserId,
    name = player.name
  }
  local chairManUserId = gang.chairMan
  local chairMan = Game.GetPlayerByUserId(chairManUserId)
  if chairMan and chairMan:isValid() then
    chairMan:updateApplyList(gang.applyList)
    return Define.GangsPacketCode.Success
  end
  return Define.GangsPacketCode.Other
end

function GangsManager:clearPlayerApplyInfo(applyPlayerUserId)
  for k, v in pairs(self.gangsList) do
    local applyList = v.applyList
    if applyList then
      applyList[applyPlayerUserId] = nil
    end
  end
end

function GangsManager:processApplications(gangId, applyPlayerUserId, action, dontCheckApplyList)
  local player = Game.GetPlayerByUserId(applyPlayerUserId)
  if player == nil or not player:isValid() then
    return Define.GangsPacketCode.Other
  end
  if player:hasGang() then
    return Define.GangsPacketCode.AlreadyEnterOtherGang
  end
  local gang = self:getGang(gangId)
  if gang == nil then
    return Define.GangsPacketCode.Other
  end
  if self:isGangMaxMember(gang) then
    return Define.GangsPacketCode.MaxMember
  end
  if not gang.applyList[applyPlayerUserId] and not dontCheckApplyList then
    return Define.GangsPacketCode.Other
  end
  self:clearPlayerApplyInfo(applyPlayerUserId)
  if action == Define.ProcessApplication.Access then
    self:addPlayer(gang, player)
    player:updateApplyResult(gang)
    return Define.GangsPacketCode.Success
  end
  return Define.GangsPacketCode.Other
end

function GangsManager:resetChairMan(gang)
  if gang == nil then
    return nil
  end
  local memberList = gang.memberList
  local unValidPlayer = {}
  for userId, v in pairs(memberList) do
    local player = Game.GetPlayerByUserId(userId)
    if player == nil or not player:isValid() then
      unValidPlayer[#unValidPlayer + 1] = player.platformUserId
    else
      v.position = Define.GangsPosition.ChairMan
      gang.chairMan = userId
      player:updateBeChairMan(gang)
      break
    end
  end
  for i = 1, #unValidPlayer do
    memberList[unValidPlayer[i]] = nil
    gang.memberNumber = gang.memberNumber - 1
  end
end

function GangsManager:getTerritoryAward(player)
  local gangId = player:getGangId()
  if gangId == nil then
    return
  end
  local gang = self:getGang(gangId)
  if gang == nil then
    return
  end
  local data = TerritoryServer:export_getAward(player, gangId)
  if data == nil then
    return
  end
  local coins = data.coins
  if coins <= 0 then
    return
  end
  local occupyUserId = data.userId
  local getAwardUserId = player.platformUserId
  local num = 3 + gang.memberNumber
  local coin = math.ceil(coins / num)
  coins = coin * num
  for k, v in pairs(gang.memberList) do
    local player = Game.GetPlayerByUserId(k)
    if player and player:isValid() then
      local awardNum = 1
      if v.position == Define.GangsPosition.ChairMan then
        awardNum = awardNum + 1
      end
      if v.userId == occupyUserId then
        awardNum = awardNum + 1
      end
      if v.userId == getAwardUserId then
        awardNum = awardNum + 1
      end
      player:addOccupyAward(coin * awardNum, data.id)
    end
  end
end

function GangsManager:autoJoinGang(player)
  if player == nil or not player:isValid() then
    return Define.GangsPacketCode.Other
  end
  if player:hasGang() then
    return Define.GangsPacketCode.AlreadyEnterOtherGang
  end
  local autoJoinGangList = {}
  local otherGangList = {}
  for _, v in pairs(self.gangsList) do
    if v.isAutoJoin then
      table.insert(autoJoinGangList, v)
    else
      table.insert(otherGangList, v)
    end
  end
  while 0 < #autoJoinGangList do
    local randomIndex = math.random(1, #autoJoinGangList)
    local gang = autoJoinGangList[randomIndex]
    table.remove(autoJoinGangList, randomIndex)
    local result = self:processApplications(gang.gangId, player.platformUserId, Define.ProcessApplication.Access, true)
    if result == Define.GangsPacketCode.Success then
      return result
    end
  end
  local resultList = {}
  for _, v in pairs(otherGangList) do
    local result = self:applyJoinGang(v.gangId, player)
    if result == Define.GangsPacketCode.Success then
      resultList[v.gangId] = {code = result}
    end
  end
  return Define.GangsPacketCode.Other, resultList
end

function GangsManager:autoJoinOneGang(player, gangId)
  if not (player ~= nil and player:isValid()) or not gangId then
    return Define.GangsPacketCode.Other
  end
  if player:hasGang() then
    return Define.GangsPacketCode.AlreadyEnterOtherGang
  end
  local gang = self:getGang(gangId)
  if not gang then
    return Define.GangsPacketCode.Other
  end
  if gang.isAutoJoin then
    local result = self:processApplications(gangId, player.platformUserId, Define.ProcessApplication.Access, true)
    if result == Define.GangsPacketCode.Success then
      return result
    end
  else
    local result = self:applyJoinGang(gangId, player)
    if result == Define.GangsPacketCode.Success then
      result = Define.GangsPacketCode.SuccessApply
    end
    return result
  end
end

function GangsManager:gangTerritoryChange(gangId, territoryId, isAdd)
  if not gangId or not territoryId then
    return
  end
  local gang = self:getGang(gangId)
  if not gang then
    return
  end
  if isAdd then
    gang.territoryList[territoryId] = 1
    self:updateTopGang()
  else
    gang.territoryList[territoryId] = nil
  end
end

function GangsManager:updateTopGang()
  local firstGang
  local firstGangTerritoryNum = 0
  local secondGang
  local secondGangTerritoryNum = 0
  for _, v in pairs(self.gangsList) do
    local gang = v
    local num = 0
    for _, _ in pairs(gang.territoryList) do
      num = num + 1
    end
    if firstGangTerritoryNum < num then
      firstGang = gang
      firstGangTerritoryNum = num
    elseif secondGangTerritoryNum < num then
      secondGang = gang
      secondGangTerritoryNum = num
    end
  end
  if firstGang and firstGangTerritoryNum > secondGangTerritoryNum then
    local data = {}
    data.gangId = firstGang.gangId
    data.gangName = firstGang.name
    data.territoryList = firstGang.territoryList
    if not self.topGang or self.topGang.gangId ~= firstGang.gangId then
      data.time = os.time()
    else
      data.time = self.topGang.time
    end
    self.topGang = data
    self:broadcastTopGang(data)
  else
    self.topGang = nil
    self:broadcastTopGang(nil)
  end
end

function GangsManager:broadcastTopGang(data)
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() and player.isPlayer and player.login_time_ then
      self:sendTopGang(player, data)
    end
  end
end

function GangsManager:sendTopGang(player, data)
  if player and player:isValid() then
    player:sendPacket({
      pid = "updateToGang",
      data = data
    })
  end
end

return GangsManager
