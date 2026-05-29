local VehicleServer = T(Lib, "VehicleServer")
local VehicleBaseConfig = T(Config, "VehicleBaseConfig")

function VehicleServer:export_getVehicleHurtValue(id, hurtType)
  local hurtValue = 1
  local level = 1
  local jsonCfg = VehicleBaseConfig:getCfgById(id)
  if not jsonCfg then
    return hurtValue, level
  end
  hurtValue = jsonCfg.vehicle_attack or 1
  level = jsonCfg.vehicle_damage_lv or 1
  local rate = 1
  if hurtType == Define.HIT_BOX_TYPE.HEAD or hurtType == Define.HIT_BOX_TYPE.BODY or hurtType == Define.HIT_BOX_TYPE.LIMB then
    rate = World.cfg.hitboxRate[hurtType]
    hurtValue = hurtValue * rate
  end
  hurtValue = math.floor(hurtValue)
  return hurtValue, level
end

return VehicleServer
