local TattooConfig = T(Config, "TattooConfig")
local TattooObjectBase = Lib.class("TattooObjectBase")
local ClothesConfig = T(Config, "ClothesConfig")

function TattooObjectBase:ctor(entity, id)
  self:init(entity)
  self.cfg = TattooConfig:getCfgById(id)
  self.triggerPlayer = {}
end

function TattooObjectBase:init(entity)
  self.entity = entity
end

function TattooObjectBase:getTattooData(player)
  local tattooId = {}
  local clothes_id = self.cfg.clothes_id
  for i = 1, #clothes_id do
    if player:getBastionClothesItem(clothes_id[i]) == nil then
      tattooId[#tattooId + 1] = clothes_id[i]
    end
  end
  if #tattooId == 0 then
    return {}
  end
  local index = math.random(1, #tattooId)
  local data = {
    id = tattooId[index]
  }
  return data
end

function TattooObjectBase:recordTriggerPlayer(player, operateType)
  if operateType == Define.TerritoryTriggerType.Enter then
    self.triggerPlayer[player.platformUserId] = true
  else
    self:interruptTattoo(player)
    self.triggerPlayer[player.platformUserId] = nil
  end
end

function TattooObjectBase:requestTattoo(player, tattooId)
  if not self.triggerPlayer[player.platformUserId] then
    return Define.TattooPacketCode.ErrorRequest
  end
  if player:getBastionClothesItem(tattooId) ~= nil then
    return Define.TattooPacketCode.ExistTattoo
  end
  if self.tattooingData then
    if self.tattooingData.userId == player.platformUserId then
      return
    end
    local tattooingPlayer = Game.GetPlayerByUserId(self.tattooingData.userId)
    if tattooingPlayer and tattooingPlayer:isValid() then
      return Define.TattooPacketCode.OtherPlayerTattooing
    else
      self.tattooingData = nil
    end
  end
  local tattooCfg = ClothesConfig:getCfgById(tattooId)
  if tattooCfg then
    local price = tattooCfg.price
    if price > player:getCurrencyById(tattooCfg.currencyType) then
      return Define.TattooPacketCode.NoEnoughMoney
    elseif player:payCurrencyById(tattooCfg.currencyType, price, Define.CurrencyReason.Tattoo) then
      self.tattooingData = {
        userId = player.platformUserId,
        tattooId = tattooId,
        tattooingSuccessTime = World.Now() + self.cfg.tattoo_time
      }
      player:pam_stopMotion()
      player:rideOn(self.entity, false)
      player:evt_skin_set(Define.TattooOperationType.Start, tattooId)
      return Define.TerritoryPacketCode.Success
    else
      return Define.TattooPacketCode.NoEnoughMoney
    end
  end
end

function TattooObjectBase:provideTattoo(player)
  local item = {
    id = self.tattooingData.tattooId
  }
  player:addBastionClothesItem(item)
  player:wearClothesItem(Define.ModelClothes.Type.Tattoo, item)
  local data = {
    objID = self.entity.objID,
    successTattooID = self.tattooingData.tattooId,
    newTattooData = self:getTattooData(player)
  }
  player:tattooSuccess(data)
  player:rideOn(nil)
end

function TattooObjectBase:tattooSuccess()
  local player = Game.GetPlayerByUserId(self.tattooingData.userId)
  if player and player:isValid() then
    player:evt_skin_set(Define.TattooOperationType.Success, self.tattooingData.tattooId)
    self:provideTattoo(player)
  end
  self.tattooingData = nil
end

function TattooObjectBase:updateStatus()
  if self.tattooingData and self.tattooingData.tattooingSuccessTime <= World.Now() then
    self:tattooSuccess()
  end
end

function TattooObjectBase:interruptTattoo(player)
  if self.tattooingData and self.tattooingData.userId == player.platformUserId then
    player:evt_skin_set(Define.TattooOperationType.Interrupt, self.tattooingData.tattooId)
    player:interruptTattoo(self.entity.objID)
    self.tattooingData = nil
    player:rideOn(nil)
  end
end

function TattooObjectBase:onPlayerLogout(player)
  self:recordTriggerPlayer(player, Define.TerritoryTriggerType.Exit)
  self:interruptTattoo(player)
end

return TattooObjectBase
