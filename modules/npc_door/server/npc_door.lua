local DoorsConfig = T(Config, "DoorsConfig")
local NPC_Door = Lib.class("NPC_Door")

function NPC_Door:ctor(param)
  local map = World.CurWorld:getMap()
  local door_id = param.door_id or 0
  local configItem = DoorsConfig:getCfgById(door_id)
  if not configItem then
    return
  end
  local entityCfg = configItem.entityCfg
  local position = param.position or Vector3.new(0, 0, 0)
  local rotation = param.rotation or Vector3.new(0, 0, 0)
  local inOffset = Vector3.new(0, 0, -0.5)
  local outOffset = Vector3.new(0, 0, 0.5)
  Lib.rotate(outOffset, Vector3.new(-rotation.x, -rotation.y, -rotation.z))
  Lib.rotate(inOffset, Vector3.new(-rotation.x, -rotation.y, -rotation.z))
  local inPosition = position + inOffset
  local outPosition = position + outOffset
  self.id = param.id
  self.doorEntity = EntityServer.Create({
    cfgName = entityCfg,
    map = map,
    pos = position,
    ry = rotation.y,
    rp = rotation.x,
    rr = rotation.z
  })
  self.doorEntity:ndp_setID(self.id)
  self.doorEntity:ndp_setConfigID(door_id)
  self.doorEntity:ndp_setHoldDoorCount(0)
  self.doorEntity:ndp_setInitRotation(rotation)
  self.doorEntity:ndp_setHp(self.doorEntity:ndp_getMaxHp())
  self.doorEntity:ndp_setStatus(Define.NPCDoor.Status.Normal)
  self.doorEntity:setRotation(rotation.y, rotation.x, rotation.z)
  self.doorEntity:syncPosDelay(1)
  self.inDoorTrigger = EntityServer.Create({
    cfgName = "myplugin/trigger_npc_door_in",
    map = map,
    pos = inPosition,
    ry = rotation.y,
    rp = rotation.x,
    rr = rotation.z
  })
  self.inDoorTrigger:ndp_setID(self.id)
  self.inDoorTrigger:setRotation(rotation.y, rotation.x, rotation.z)
  self.inDoorTrigger:syncPosDelay(1)
  self.outDoorTrigger = EntityServer.Create({
    cfgName = "myplugin/trigger_npc_door_out",
    map = map,
    pos = outPosition,
    ry = rotation.y,
    rp = rotation.x,
    rr = rotation.z
  })
  self.outDoorTrigger:ndp_setID(self.id)
  self.outDoorTrigger:setRotation(rotation.y, rotation.x, rotation.z)
  self.outDoorTrigger:syncPosDelay(1)
end

function NPC_Door:getID()
  return self.id
end

function NPC_Door:getDoorEntity()
  return self.doorEntity
end

function NPC_Door:update(timeDelta)
  self.doorEntity:ndp_update(timeDelta)
end

function NPC_Door:onPlayerDie(playerId)
  self.doorEntity:ndp_onPlayerDie(playerId)
end

return NPC_Door
