local handles = T(Player, "PackageHandlers")
local PassCardConfig = T(Config, "PassCardConfig")
local ClothesConfig = T(Config, "ClothesConfig")
local ItemServer = T(Lib, "ItemServer")

function handles:isPassCardDateC2S(packet)
  return self:isPassCardDate()
end

local function reportGainItem(player, manner, itemType, itemID, deltaAmount, currentAmount)
  if not player:isPassCardDate() then
    return
  end
  local reportData = {}
  reportData.access_type = manner
  reportData.item_type = itemType
  reportData.item_id = itemID
  reportData.gain_amount = deltaAmount
  reportData.current_num = currentAmount
  player:evt_reportEvent(Define.EventTracking.Type.GainItem, reportData)
end

function handles:buyPassGoldCardC2S(packet)
  if not self:isPassCardDate() then
    return
  end
  local cost = World.cfg.goldPassCardPrice or 30
  Lib.payMoneyCube(self, 10200, 0, cost, function(success)
    if success then
      self:buyPlayerPassCard()
      local reportData = {}
      reportData.passcard_class = self:getPlayerPassCard().level
      reportData.passcard_content = Define.EventTracking.PassCardBuy.BuyContent.Gold
      self:evt_reportEvent(Define.EventTracking.Type.PassCardBuy, reportData, true)
    end
    self:sendPacket({
      pid = "buyPassGoldCardResultS2C",
      isSucceed = success
    })
  end, 1, Define.ExchangeItemsReason.BuyShop)
end

function handles:buyPassCardLevelUpC2S(packet)
  if not self:isPassCardDate() then
    return
  end
  if not packet or not packet.level then
    return
  end
  local cfg = PassCardConfig:getCfgById(packet.level)
  if not cfg or not cfg.price then
    return
  end
  local cost = cfg.price
  Lib.payMoneyCube(self, 10300, 0, cost, function(success)
    if success then
      self:playerPassCardAddExp(cfg.exp)
      local reportData = {}
      reportData.passcard_class = self:getPlayerPassCard().level
      reportData.passcard_content = Define.EventTracking.PassCardBuy.BuyContent.Level
      self:evt_reportEvent(Define.EventTracking.Type.PassCardBuy, reportData, true)
    end
    self:sendPacket({
      pid = "buyPassCardLevelUpResultS2C",
      isSucceed = success
    })
  end, 1, Define.ExchangeItemsReason.BuyShop)
end

function handles:passCardGetRewardC2S(packet)
  local result = -1
  local isSuccess = false
  if not (packet and packet.level) or not self:isPassCardDate() then
    return false, -1
  end
  local cfg = PassCardConfig:getCfgById(packet.level)
  if not cfg then
    return false, -1
  end
  local passCardData = self:getPlayerPassCard()
  if packet.level > passCardData.level or self:playerGotPassCardReward(packet.isGold, packet.level) then
    return false, -1
  end
  local reward = packet.isGold and cfg.reward_gold or cfg.reward_free
  if reward.type == Define.PassCardRewardType.RewardMoney then
    if reward.num > 0 then
      self:addCurrencyByName(Define.CURRENCY_TYPE.gold, reward.num, Define.CurrencyReason.PassCardReward, Define.CurrencyType.FromSystem)
      isSuccess = true
    end
  elseif reward.type == Define.PassCardRewardType.RewardItem then
    if reward.num > 0 and 0 < reward.id then
      self:changeCostItemCount(reward.id, reward.num)
      reportGainItem(self, Define.EventTracking.Item.Gain.PassCard, Define.EventTracking.Item.Type.Item, reward.id, reward.num, self:getCostItemCountByItemID(reward.id))
      isSuccess = true
    end
  elseif reward.type == Define.PassCardRewardType.RewardVehicle then
    if 0 < reward.id then
      isSuccess = true
      if self:isDriving() then
        result = Define.PassCardGetRewardRespond.GetOffToCarShop
      else
        result = Define.PassCardGetRewardRespond.ToCarShop
      end
    end
  elseif reward.type == Define.PassCardRewardType.RewardCloth then
    if 0 < reward.id then
      isSuccess = true
      local haveSameCloth = self:getBastionClothesItem(reward.id)
      if haveSameCloth then
        result = Define.PassCardGetRewardRespond.HaveSameCloth
      else
        self:addBastionClothesItem({
          id = reward.id
        })
        reportGainItem(self, Define.EventTracking.Item.Gain.PassCard, Define.EventTracking.Item.Type.Clothes, reward.id, reward.num, 1)
      end
    end
  elseif reward.type == Define.PassCardRewardType.RewardWeapon then
    if 0 < reward.id then
      isSuccess = true
      local isFull = ItemServer:export_hadBagIsFull(self)
      if isFull then
        result = Define.PassCardGetRewardRespond.WeaponBagFull
      else
        ItemServer:export_addHadBagItem(self, reward.id, Define.ReportGetAccessType.PassCard)
      end
    end
  elseif reward.type == Define.PassCardRewardType.RewardMotion and 0 < reward.id then
    self:addPlayerMotionPaid(reward.id)
    isSuccess = true
  end
  if isSuccess and result == -1 then
    self:playerPassCardGetReward(packet.isGold, packet.level)
    self:sendPacket({
      pid = "passCardGetRewardResultS2C"
    })
    local reportData = {}
    reportData.passcard_award_type = packet.isGold and Define.EventTracking.PassCardAwardGet.AwardType.Gold or Define.EventTracking.PassCardAwardGet.AwardType.Free
    reportData.passcard_award_id = reward.id
    self:evt_reportEvent(Define.EventTracking.Type.PassCardAwardGet, reportData, true)
  end
  return isSuccess, result
end

function handles:passCardGetRewardSureC2S(packet)
  if not (packet and packet.level) or not self:isPassCardDate() then
    return false
  end
  local cfg = PassCardConfig:getCfgById(packet.level)
  if not cfg then
    return false
  end
  local passCardData = self:getPlayerPassCard()
  if packet.level > passCardData.level or self:playerGotPassCardReward(packet.isGold, packet.level) then
    return false
  end
  local isSuccess = false
  local reward = packet.isGold and cfg.reward_gold or cfg.reward_free
  if reward.type == Define.PassCardRewardType.RewardVehicle then
    local state = self:getCurState()
    if state ~= Define.CHARACTER_STATE_TYPE.GROUND and state ~= Define.CHARACTER_STATE_TYPE.DIE and reward.id > 0 then
      self:getPassCardRewardCar(reward.id)
      isSuccess = true
    end
  elseif reward.type == Define.PassCardRewardType.RewardCloth then
    if reward.id > 0 then
      isSuccess = true
      local price = ClothesConfig:getCfgById(reward.id).price
      self:addCurrencyByName(Define.CURRENCY_TYPE.gold, price, Define.CurrencyReason.PassCardReward, Define.CurrencyType.FromSystem)
    end
  elseif reward.type == Define.PassCardRewardType.RewardWeapon and reward.id > 0 then
    isSuccess = true
    ItemServer:export_addHadBagItem(self, reward.id, Define.ReportGetAccessType.PassCard)
  end
  if isSuccess then
    self:playerPassCardGetReward(packet.isGold, packet.level)
    self:sendPacket({
      pid = "passCardGetRewardResultS2C"
    })
    local reportData = {}
    reportData.passcard_award_type = packet.isGold and Define.EventTracking.PassCardAwardGet.AwardType.Gold or Define.EventTracking.PassCardAwardGet.AwardType.Free
    reportData.passcard_award_id = reward.id
    self:evt_reportEvent(Define.EventTracking.Type.PassCardAwardGet, reportData, true)
  end
  return isSuccess
end
