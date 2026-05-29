local NPCDoorManager = require("server.npc_door_manager")
local PlayerNpcDoorServer = Player

function PlayerNpcDoorServer:ndp_OperateNpcDoor(operateType, doorId, operatorId, from, triggerParam)
  local npcDoor = NPCDoorManager.Instance():getDoor(doorId)
  if not npcDoor then
    return
  end
  local doorEntity = npcDoor:getDoorEntity()
  if not doorEntity then
    return
  end
  local status = doorEntity:ndp_getStatus()
  if status == Define.NPCDoor.Status.Normal then
    if from == "InDoor" then
      if operateType == "Open" then
        doorEntity:ndp_addHoldDoorCount(1)
      elseif operateType == "Close" then
        doorEntity:ndp_delHoldDoorCount(1)
      end
    elseif from == "OutDoor" then
      if operateType == "Close" then
        doorEntity:ndp_delHoldDoorCount(1)
        self:ndp_S2C_TriggerHackNpcDoorUI("Exit", doorEntity.objID, triggerParam)
      elseif operateType == "Open" then
        self:ndp_S2C_TriggerHackNpcDoorUI("Enter", doorEntity.objID, triggerParam)
      end
    end
  elseif status == Define.NPCDoor.Status.Hacked then
    if operateType == "Open" then
      doorEntity:ndp_addHoldDoorCount(1)
    elseif operateType == "Close" then
      doorEntity:ndp_delHoldDoorCount(1)
      self:ndp_S2C_TriggerHackNpcDoorUI("Exit", doorEntity.objID, triggerParam)
    end
  elseif operateType == "Close" then
    self:ndp_S2C_TriggerHackNpcDoorUI("Exit", doorEntity.objID, triggerParam)
  end
end

function PlayerNpcDoorServer:ndp_S2C_TriggerHackNpcDoorUI(operateType, objID, triggerParam)
  local packet = {
    pid = "ndp_S2C_TriggerHackNpcDoorUI",
    operateType = operateType,
    objID = objID,
    triggerParam = triggerParam
  }
  self:sendPacket(packet)
end

function PlayerNpcDoorServer:ndp_RSP_HackNpcDoor(param)
  local type = param.type
  if type == "Start" then
    return self:ndp_StartHackNpcDoor(param)
  elseif type == "Cancel" then
    return self:ndp_CancelHackNpcDoor(param)
  elseif type == "Confirm" then
    return self:ndp_ConfirmHackNpcDoor()
  end
end

function PlayerNpcDoorServer:ndp_StartHackNpcDoor(param)
  local targetObjID = param.objID or 0
  local door = World.CurWorld:getObject(targetObjID)
  if not door or not door:isValid() then
    local result = {}
    result.status = Define.NPCDoor.Operate.Error.Failed
    result.msg = "owner no defense entity"
    result.data = {}
    return result
  end
  if door:ndp_getStatus() == Define.NPCDoor.Status.Hacked then
    local result = {}
    result.status = Define.NPCDoor.Operate.Error.Failed
    result.msg = "bastion.door.hacked.already.hacked"
    result.data = {}
    return result
  end
  if door:bdp_getStatus() == Define.Bastion.Defense.Status.Damaged then
    local result = {}
    result.status = Define.NPCDoor.Operate.Error.Failed
    result.msg = "bastion.door.hacked.already.damaged"
    result.data = {}
    return result
  end
  if 0 >= self:getCostItemCountByItemID(Define.Bastion.DoorHackItemID) then
    local result = {}
    result.status = Define.NPCDoor.Operate.Error.Failed
    result.msg = "bastion.door.sensor.no.hack.item"
    result.data = {}
    return result
  end
  self:changeCostItemCount(Define.Bastion.DoorHackItemID, -1)
  door:ndp_addHacker(self.platformUserId)
  local result = {}
  result.status = Define.NPCDoor.Operate.Error.Succeed
  result.msg = "OK"
  return result
end

function PlayerNpcDoorServer:ndp_CancelHackNpcDoor(param)
  local hackObjID = self:bhp_getHackObjID()
  if hackObjID then
    local door = World.CurWorld:getObject(hackObjID)
    if door and door:isValid() then
      door:ndp_cancelHack(self.platformUserId)
    end
  end
end

function PlayerNpcDoorServer:ndp_ConfirmHackNpcDoor(param)
  local hackObjID = self:bhp_getHackObjID()
  if hackObjID then
    local door = World.CurWorld:getObject(hackObjID)
    if door and door:isValid() then
      door:ndp_confirmHack(self.platformUserId)
    end
  end
end
