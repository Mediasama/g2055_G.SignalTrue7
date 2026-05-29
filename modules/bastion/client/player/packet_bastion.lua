local handles = T(Player, "PackageHandlers")

function handles:S2C_TriggerBastionFacility(packet)
  local param = packet
  local operateType = param.operateType
  local facilityType = param.facilityType
  local ownerId = param.ownerId
  local operatorId = param.operatorId
  local objID = param.objID
  local triggerParam = param.triggerParam
  local player = Me
  if operateType == Define.Bastion.Facility.TriggerType.Open then
    player:showFacilityIcon(objID, facilityType, ownerId, operatorId, triggerParam)
  elseif operateType == Define.Bastion.Facility.TriggerType.Close then
    player:hideFacilityIcon(objID, facilityType, ownerId, operatorId, triggerParam)
  end
end

function handles:S2C_TriggerBastionPark(packet)
  local param = packet
  local operateType = param.operateType
  local facilityType = param.facilityType
  local ownerId = param.ownerId
  local operatorId = param.operatorId
  local objID = param.objID
  local triggerParam = param.triggerParam
  local player = Me
  if operateType == Define.Bastion.Facility.TriggerType.Open then
    player:showParkDialog(objID, facilityType, ownerId, operatorId, triggerParam)
  elseif operateType == Define.Bastion.Facility.TriggerType.Close then
    player:hideParkDialog(objID, facilityType, ownerId, operatorId, triggerParam)
  end
end

function handles:S2C_PlayBastionEffect(packet)
  local effectName = packet.effectName or ""
  local position = packet.position or Vector3.new(0, 0, 0)
  local timeScale = packet.timeScale or 1
  local bodyScale = packet.bodyScale or Vector3.new(1, 1, 1)
  local yaw = packet.yaw or 0
  local duration = packet.duration or 10000
  Blockman.instance:playPluginEffectByPos(effectName, position, timeScale, yaw, duration, bodyScale)
end

function handles:S2C_CreateHomeMark(packet)
  self:createHomeMark(packet)
end

function handles:S2C_RemoveHomeMark(packet)
  self:removeHomeMark(packet)
end

function handles:S2C_CreateParkMark(packet)
  self:createParkMark(packet)
end

function handles:S2C_RemoveParkMark(packet)
  self:removeParkMark(packet)
end

function handles:S2C_CreateDoorMark(packet)
  self:createDoorMark(packet)
end

function handles:S2C_RemoveDoorMark(packet)
  self:removeDoorMark(packet)
end

function handles:S2C_NotifyPlayDie(packet)
  if packet.userId == Me.platformUserId then
    Lib.emitEvent(Event.EVENT_BASTION_NOTIFY_SELF_DIE, packet)
  else
    Lib.emitEvent(Event.EVENT_BASTION_NOTIFY_OTHER_DIE, packet)
  end
end

function handles:S2C_ShowBastionDefenseTips(packet)
  local type = packet.type or 0
  local attackerName = packet.attackerName or ""
  if type == Define.Bastion.Defense.Tips.Type.Damaged then
    local msg = attackerName .. Lang:toText("bastion.door.damaged.tip")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  elseif type == Define.Bastion.Defense.Tips.Type.StartHacked then
    local msg = attackerName .. Lang:toText("bastion.door.start.hacked.tip")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  elseif type == Define.Bastion.Defense.Tips.Type.Hacked then
    local msg = attackerName .. Lang:toText("bastion.door.hacked.tip")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  elseif type == Define.Bastion.Defense.Tips.Type.HackedSucceed then
    local msg = Lang:toText("bastion.door.hacked.succeed")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  elseif type == Define.Bastion.Defense.Tips.Type.HackedFailed then
    local msg = Lang:toText("bastion.door.hacked.failed")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  elseif type == Define.Bastion.Defense.Tips.Type.OwnerUpdate then
    local msg = Lang:toText("bastion.door.hacked.owner.update")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  elseif type == Define.Bastion.Defense.Tips.Type.AttackDoor then
    local msg = attackerName .. Lang:toText("bastion.door.attack.tip")
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
  end
end

function handles:S2C_HideBastionIcon(packet)
  local ownerId = packet.userId
  if ownerId then
    for _, v in pairs(Define.Bastion.Facility.Type) do
      Me:hideFacilityIcon(nil, v, ownerId)
    end
  end
end

function handles:S2C_UpdateArmoryEffect(packet)
  if packet and packet.objID then
    local entity = World.CurWorld:getEntity(packet.objID)
    if entity and entity:isValid() then
      entity:updateFacilityEffect()
    end
  end
end
