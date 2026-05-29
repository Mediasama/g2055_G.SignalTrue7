local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
local BastionOperatorBase = require("server.bastion_operator.bastion_operator_base")
local BastionOperatorGarage = Lib.class("BastionOperatorGarage", BastionOperatorBase)

function BastionOperatorGarage:ctor(param)
  BastionOperatorBase.ctor(self, param)
  self._type = Define.Bastion.Facility.Type.Garage
end

function BastionOperatorGarage:operate(param)
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
  elseif manner == Define.Bastion.Facility.OperateType.Buy then
    return self:buy(param)
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

function BastionOperatorGarage:query(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local level = owner:getBastionGarageLevel()
  local carDict = owner:getBastionCarDict()
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = {carDict = carDict, level = level}
  return result
end

function BastionOperatorGarage:buy(param)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local level = operator:getBastionGarageLevel()
  if 0 < level then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.buy.error.had.unlock"
    return result
  end
  local config = World.cfg.bastionSetting or {}
  local garage = config.garage or {}
  local unlockPrice = garage.unlockPrice or 100
  local cash = operator:getCurrencyById(Define.Bastion.Currency.Type.Gold)
  if unlockPrice > cash then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.buy.error.no.enough.money"
    return result
  end
  operator:payCurrencyById(Define.Bastion.Currency.Type.Gold, unlockPrice, Define.CurrencyReason.Garage)
  operator:setBastionGarageLevel(1)
  local bastion = operator:getBastion()
  if bastion then
    bastion:reloadFacility()
  end
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Garage.Buy)
  local bastion = operator:getBastion()
  if bastion then
    local parkInfo = bastion:getFacility(Define.Bastion.Facility.Type.Park)
    local park = config.park or {}
    local parkEffectName = park.effectName or "g2055_parking_effect.effect"
    local parkOffset = park.offset or Vector3.new(0, 0, 0)
    local cloneHoneOffset = Lib.copy(parkOffset)
    Lib.rotate(cloneHoneOffset, parkInfo.rotation)
    local parkParam = {}
    parkParam.effectName = parkEffectName
    parkParam.position = parkInfo.position + cloneHoneOffset
    parkParam.rotation = parkInfo.rotation
    operator:S2C_CreateParkMark(parkParam)
  end
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(operator)
  return result
end

function BastionOperatorGarage:deposit(param)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Failed
  result.msg = "can not deposit car from garage"
  return result
end

function BastionOperatorGarage:fetch(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local data = param.requestData or {}
  local index = data.index or 1
  local item = owner:getBastionCarItem(index)
  if not item then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.fetch.error.no.car"
    return result
  end
  local configItem = VehicleBaseConfig:getCfgById(item.id)
  if not configItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.fetch.error.no.car"
    return result
  end
  operator:fetchCarFromGarage(item.id)
  owner:deleteBastionCarItem(index)
  operator:bst_ReportGainItem(Define.EventTracking.Item.Gain.Fetch, Define.EventTracking.Item.Type.Car, item.id, 1, 1)
  GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Car, item.id, 1, true, Define.ItemFlowReason.Fetch)
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Garage.Fetch)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(operator)
  return result
end

function BastionOperatorGarage:steal(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local data = param.requestData or {}
  local index = data.index or 1
  local item = owner:getBastionCarItem(index)
  if not item then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.fetch.error.no.car"
    return result
  end
  local configItem = VehicleBaseConfig:getCfgById(item.id)
  if not configItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.fetch.error.no.car"
    return result
  end
  operator:stealCarFromGarage(item.id, param.ownerId)
  operator:bst_ReportGainItem(Define.EventTracking.Item.Gain.Steal, Define.EventTracking.Item.Type.Car, item.id, 1, 1)
  GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Car, item.id, 1, true, Define.ItemFlowReason.Steal)
  owner:deleteBastionCarItem(index)
  owner:bst_ReportLoseItem(Define.EventTracking.Item.Lose.Steal, Define.EventTracking.Item.Type.Car, item.id, 1, 0)
  GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Car, item.id, 1, false, Define.ItemFlowReason.Steal)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(owner)
  return result
end

function BastionOperatorGarage:getResponseData(owner)
  local level = owner:getBastionGarageLevel()
  local carDict = owner:getBastionCarDict()
  local data = {carDict = carDict, level = level}
  return data
end

return BastionOperatorGarage
