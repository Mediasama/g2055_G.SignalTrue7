local VehicleBaseConfig = T(Config, "VehicleBaseConfig")
local BastionOperatorBase = require("server.bastion_operator.bastion_operator_base")
local BastionOperatorPark = Lib.class("BastionOperatorPark", BastionOperatorBase)

function BastionOperatorPark:ctor(param)
  BastionOperatorBase.ctor(self, param)
  self._type = Define.Bastion.Facility.Type.Garage
end

function BastionOperatorPark:operate(param)
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

function BastionOperatorPark:query(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local level = owner:getBastionGarageLevel()
  local carDict = owner:getBastionCarDict()
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = {carDict = carDict, level = level}
  return result
end

function BastionOperatorPark:buy(param)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Failed
  result.msg = "can not buy garage from park"
  return result
end

function BastionOperatorPark:deposit(param)
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local data = param.requestData or {}
  local id = data.id or 0
  local index = data.index or 1
  local level = operator:getBastionGarageLevel()
  if level <= 0 then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.deposit.error.no.garage"
    return result
  end
  local configItem = VehicleBaseConfig:getCfgById(id)
  if not configItem then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.garage.fetch.error.no.car"
    return result
  end
  local oldItem = operator:getBastionCarItem(index)
  if oldItem then
    local newItem = {
      id = configItem.id
    }
    operator:depositCarToGarage(id)
    operator:setBastionCarItem(index, newItem)
    operator:fetchOldCarFromGarage(oldItem.id)
    operator:bst_ReportGainItem(Define.EventTracking.Item.Gain.Fetch, Define.EventTracking.Item.Type.Car, id, 1, 1)
    GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Car, id, 1, true, Define.ItemFlowReason.Fetch)
  else
    local newItem = {
      id = configItem.id
    }
    operator:depositCarToGarage(id)
    operator:setBastionCarItem(index, newItem)
    operator:bst_ReportLoseItem(Define.EventTracking.Item.Lose.Deposit, Define.EventTracking.Item.Type.Car, id, 1, 0)
    GameAnalytics.ItemFlow(owner, Define.EventTracking.Item.Type.Car, id, 1, false, Define.ItemFlowReason.Deposit)
  end
  operator:bst_ReportOperateFacility(Define.EventTracking.Facility.Garage.Deposit)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = self:getResponseData(operator)
  return result
end

function BastionOperatorPark:fetch(param)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Failed
  result.msg = "can not fetch car from park"
  return result
end

function BastionOperatorPark:steal(param)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Failed
  result.msg = "can not steal car from park"
  return result
end

function BastionOperatorPark:getResponseData(owner)
  local level = owner:getBastionGarageLevel()
  local carDict = owner:getBastionCarDict()
  local data = {carDict = carDict, level = level}
  return data
end

return BastionOperatorPark
