local ClothesConfig = T(Config, "ClothesConfig")
local BastionOperatorBase = require("server.bastion_operator.bastion_operator_base")
local BastionOperatorCloset = Lib.class("BastionOperatorCloset", BastionOperatorBase)

function BastionOperatorCloset:ctor(param)
  BastionOperatorBase.ctor(self, param)
  self._type = Define.Bastion.Facility.Type.Closet
end

function BastionOperatorCloset:operate(param)
  local result = {}
  local ownerId = param.ownerId
  local owner = Game.GetPlayerByUserId(ownerId)
  if not owner or not owner:isValid() then
    result.status = Define.Bastion.Facility.OperateErrorCode.InvalidOwner
    result.msg = "InvalidOwner userId:" .. (ownerId or "unknown")
    return result
  end
  local operatorId = param.operatorId
  local operator = Game.GetPlayerByUserId(operatorId)
  if not operator or not operator:isValid() then
    result.status = Define.Bastion.Facility.OperateErrorCode.InvalidOperator
    result.msg = "InvalidOperator userId:" .. (operatorId or "unknown")
    return result
  end
  local manner = param.manner
  if manner == Define.Bastion.Facility.OperateType.Query then
    return self:query(param)
  elseif manner == Define.Bastion.Facility.OperateType.Deposit then
    return self:deposit(param)
  elseif manner == Define.Bastion.Facility.OperateType.Fetch then
    return self:fetch(param)
  elseif manner == Define.Bastion.Facility.OperateType.Steal then
    return self:steal(param)
  else
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.UnknownManner
    result.msg = "unknown manner:" .. (manner or "unknown")
    return result
  end
end

function BastionOperatorCloset:query(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner, operator)
  return result
end

function BastionOperatorCloset:deposit(param)
end

function BastionOperatorCloset:fetch(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local data = param.requestData or {}
  local id = data.id or 0
  if owner:getBastionClothesItem(id) == nil then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.closet.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local configItem = ClothesConfig:getCfgById(id)
  if not configItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.closet.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local type = configItem.part
  local item = {
    id = configItem.id
  }
  if param.ownerId == param.operatorId then
    local wearItem = operator:getModelClothesItem(type)
    if wearItem and wearItem.id == item.id then
      operator:takeOffClothesItem(type, wearItem)
      operator:bst_ReportLoseItem(Define.EventTracking.Item.Lose.Deposit, Define.EventTracking.Item.Type.Clothes, item.id, 1, 1)
      GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Clothes, item.id, 1, false, Define.ItemFlowReason.Fetch)
    else
      operator:wearClothesItem(type, item)
      operator:bst_ReportGainItem(Define.EventTracking.Item.Gain.Fetch, Define.EventTracking.Item.Type.Clothes, item.id, 1, 1)
      GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Clothes, item.id, 1, true, Define.ItemFlowReason.Fetch)
    end
  end
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Closet.Fetch)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner, operator)
  return result
end

function BastionOperatorCloset:steal(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local data = param.requestData or {}
  local id = data.id or 0
  if owner:getBastionClothesItem(id) == nil then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.closet.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  if owner:isWearingClothesItem(id) then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.closet.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local configItem = ClothesConfig:getCfgById(id)
  if not configItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.closet.no.select.item"
    result.data = self:getResponseData(owner, operator)
    return result
  end
  local type = configItem.part
  local item = {
    id = configItem.id
  }
  if param.ownerId ~= param.operatorId then
    owner:deleteBastionClosetItem(id)
    owner:bst_ReportLoseItem(Define.EventTracking.Item.Lose.Steal, Define.EventTracking.Item.Type.Clothes, item.id, 1, 0)
    GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Clothes, item.id, 1, false, Define.ItemFlowReason.Steal)
    operator:addBastionClothesItem({id = id})
    operator:wearClothesItem(type, item)
    operator:bst_ReportGainItem(Define.EventTracking.Item.Gain.Steal, Define.EventTracking.Item.Type.Clothes, item.id, 1, 1)
    GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Clothes, item.id, 1, true, Define.ItemFlowReason.Steal)
  end
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner, operator)
  return result
end

function BastionOperatorCloset:getResponseData(owner, operator)
  local data = {}
  if not owner or not owner:isValid() then
    return data
  end
  if not operator or not operator:isValid() then
    return data
  end
  local clothesDict = {}
  if owner.platformUserId == operator.platformUserId then
    clothesDict = owner:getBastionClothesDict()
    local wearDict = owner:getModelClothesWearDict()
    for type, item in pairs(wearDict) do
      clothesDict[item.id] = item
    end
  else
    local ownerClothesDict = owner:getBastionClothesDict()
    for ownerId, ownerItem in pairs(ownerClothesDict) do
      if operator:getBastionClothesItem(ownerItem.id) == nil and not owner:isWearingClothesItem(ownerItem.id) then
        clothesDict[ownerId] = ownerItem
      end
    end
  end
  data.clothesDict = clothesDict
  return data
end

return BastionOperatorCloset
