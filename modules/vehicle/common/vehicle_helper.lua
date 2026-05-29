local VehicleHelper = T(Lib, "VehicleHelper")
local SoundConfig = T(Config, "SoundConfig")

function VehicleHelper:vehicleExplode(hurtInfo)
  if not hurtInfo then
    return
  end
  local sound = SoundConfig:getSound("vehicle_explode")
  local volume = sound.volume or 1
  local id = TdAudioEngine.Instance():play3dSound(sound.sound, hurtInfo.hurtEntityPos, false, 1, 1.0, 100.0)
  TdAudioEngine.Instance():setSoundsVolume(id, volume)
  TdAudioEngine.Instance():set3DMinMaxDistance(id, 1, 20)
  local timeScale = World.cfg.vehicle.vehicleExplodeTimeScale or 1
  local scale = hurtInfo.vehicleExplodeScale or 1
  Blockman.instance:playPluginEffectByPos("g2055_vehical_blast_effect.effect", hurtInfo.hurtEntityPos, timeScale, 0, 10000, Lib.v3(scale, scale, scale))
end

function VehicleHelper:vehicleHurt(hurtInfo)
  if not hurtInfo or not hurtInfo.isVehicle then
    return
  end
  local hurtObjID = hurtInfo.hurtObjID
  local attackObjID = hurtInfo.attackObjID
  local hitSound = hurtInfo.hitSound
  local hurtVehicle = World.CurWorld:getEntity(hurtObjID)
  if not hurtVehicle or not hurtVehicle:isValid() then
    return
  end
  local k, hurtVehiclePassengerId = next(hurtVehicle:data("passengers"))
  if hurtVehiclePassengerId == Me.objID then
    Lib.emitEvent(Event.EVENT_ON_HURT, hurtInfo.sourcePos)
    Me:playSoundByKey(hitSound)
  else
    local hurt = hurtInfo.hurt
    Me:showHurtEffect(hurtVehicle, hurt, attackObjID)
  end
  if attackObjID == Me.objID then
    Me:playSoundByKey(hitSound)
    Lib.emitEvent(Event.EVENT_ROGUELIKE_ENEMY_HURT, 3)
  end
end

return VehicleHelper
