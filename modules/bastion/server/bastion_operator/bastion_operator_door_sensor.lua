local DoorsConfig = T(Config, "DoorsConfig")
local BastionOperatorBase = require("server.bastion_operator.bastion_operator_base")
local BastionOperatorDoorSensor = Lib.class("BastionOperatorDoorSensor", BastionOperatorBase)

function BastionOperatorDoorSensor:ctor(param)
  BastionOperatorBase.ctor(self, param)
  self._type = Define.Bastion.Facility.Type.ToolKit
end

function BastionOperatorDoorSensor:operate(param)
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

function BastionOperatorDoorSensor:query(param)
  local requestData = param.requestData or {}
  local type = requestData.type or Define.Bastion.Defense.Type.Door
  local result = {}
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local home = owner:getBastion()
  if not home then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "owner no bastion"
    result.data = {}
    return result
  end
  local defenseInfo = home:getDefense(type)
  if not defenseInfo then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "owner no defense"
    result.data = {}
    return result
  end
  local doorEntity = defenseInfo.entity
  if not doorEntity or not doorEntity:isValid() then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "owner no defense entity"
    result.data = {}
    return result
  end
  local property = doorEntity:brp_getDefensePropertyCopy()
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = {property = property}
  return result
end

function BastionOperatorDoorSensor:deposit(param)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = {}
  return result
end

function BastionOperatorDoorSensor:fetch(param)
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = {}
  return result
end

function BastionOperatorDoorSensor:steal(param)
  local requestData = param.requestData or {}
  local type = requestData.type or Define.Bastion.Defense.Type.Door
  local owner = Game.GetPlayerByUserId(param.ownerId)
  local operator = Game.GetPlayerByUserId(param.operatorId)
  operator:pam_stopMotion()
  local home = owner:getBastion()
  if not home then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "owner no bastion"
    result.data = {}
    return result
  end
  local defenseInfo = home:getDefense(type)
  if not defenseInfo then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "owner no defense"
    result.data = {}
    return result
  end
  local doorEntity = defenseInfo.entity
  if not doorEntity or not doorEntity:isValid() then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "owner no defense entity"
    result.data = {}
    return result
  end
  if doorEntity:bdp_getStatus() == Define.Bastion.Defense.Status.Hacked then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.door.hacked.already.hacked"
    result.data = {}
    return result
  end
  if doorEntity:bdp_getStatus() == Define.Bastion.Defense.Status.Damaged then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.door.hacked.already.damaged"
    result.data = {}
    return result
  end
  if operator:getCostItemCountByItemID(Define.Bastion.DoorHackItemID) <= 0 then
    local result = {}
    result.status = Define.Bastion.Facility.OperateErrorCode.Failed
    result.msg = "bastion.door.sensor.no.hack.item"
    result.data = {}
    return result
  end
  operator:changeCostItemCount(Define.Bastion.DoorHackItemID, -1)
  doorEntity:brp_addHacker(operator.platformUserId)
  local property = doorEntity:getBastionDefenseProperty()
  local result = {}
  result.status = Define.Bastion.Facility.OperateErrorCode.Succeed
  result.msg = "OK"
  result.data = {
    doorObjId = doorEntity.objID,
    property = property
  }
  return result
end

return BastionOperatorDoorSensor
