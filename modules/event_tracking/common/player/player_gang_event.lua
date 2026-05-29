local Player = _ENV.Player

function Player:evt_player_team_operation(type, time)
  self:evt_reportEvent("player_team_operation", {gang_operation_name = type, team_stay_time = time})
end

function Player:evt_territory_occupied(status, territory_id, territoryData)
  local team_id, name
  if territoryData.owner then
    if territoryData.ownerType == Define.TerritoryOwnerType.Player then
      local player = Game.GetPlayerByUserId(territoryData.owner)
      if player and player:isValid() then
        name = player.name
      end
    else
      team_id = territoryData.owner
    end
  else
  end
  self:evt_reportEvent("territory_occupied", {
    status = status,
    territory_id = territory_id,
    team_id = team_id,
    name = name
  })
end

function Player:evt_skin_set(status, skin_target_id)
  local tattooItem = self:getModelClothesItem(Define.ModelClothes.Type.Tattoo)
  local skin_id_before
  if tattooItem then
    skin_id_before = tattooItem.id
  end
  if skin_id_before == nil then
    skin_id_before = -1
  end
  self:evt_reportEvent("skin_set", {
    status = status,
    skin_target_id = skin_target_id,
    skin_id_before = skin_id_before
  })
end

function Player:evt_recordPlayerActive(time)
  local playerActive = self:getValue("playerActive")
  if playerActive.initialTime then
    local isSameDay = Lib.isSameDay(playerActive.initialTime, time)
    if isSameDay then
      return
    end
    if playerActive.activeType < 30 then
      playerActive.activeType = playerActive.activeType + 1
    else
      return
    end
  else
    playerActive.activeType = 1
  end
  playerActive.initialTime = time
  self:setValue("playerActive", playerActive)
end
