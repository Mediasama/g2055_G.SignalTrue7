local WeaponServer = T(Lib, "WeaponServer")
local WeaponConfig = T(Config, "WeaponConfig")
local handles = T(Player, "PackageHandlers")

function WeaponServer:export_getWeaponHurtValue(id, distance, hurtType, hurtCount, attackEntity, skillJsonConf)
  local hurtValue = 0
  local jsonCfg = WeaponConfig:getWeaponJsonById(id)
  local isMelee
  local level = 1
  if not jsonCfg.launcher then
    isMelee = true
    hurtValue = attackEntity.skillJsonConf and attackEntity.skillJsonConf.damage or 0
    if skillJsonConf then
      hurtValue = skillJsonConf.damage or 0
    end
    level = jsonCfg.damageLevel or 1
  else
    local conf = jsonCfg.bullet
    local s = distance
    if s < conf.damageDecayStartDis then
      hurtValue = conf.damage
    elseif s < conf.damageDecayMaxDis then
      hurtValue = conf.damage - (s - conf.damageDecayStartDis) * conf.damageDecayFactor1
    else
      hurtValue = conf.damage - (conf.damageDecayMaxDis - conf.damageDecayStartDis) * conf.damageDecayFactor1 - (s - conf.damageDecayMaxDis) * conf.damageDecayFactor2
    end
    if hurtValue < conf.minDamage then
      hurtValue = conf.minDamage
    end
    level = conf.damageLevel or 1
  end
  local rate = 1
  if hurtType == Define.HIT_BOX_TYPE.HEAD or hurtType == Define.HIT_BOX_TYPE.BODY or hurtType == Define.HIT_BOX_TYPE.LIMB then
    rate = World.cfg.hitboxRate[hurtType]
    hurtValue = hurtValue * rate
  end
  hurtValue = math.floor(hurtValue * hurtCount)
  return hurtValue, level, isMelee
end

function WeaponServer:export_doDamage(packet)
  if packet then
    local attackObjID = packet.damageInfo.attackObjID
    local player = World.CurWorld:getEntity(attackObjID)
    if player and player:isValid() then
      handles.BulletDoDamage(player, packet)
    end
  end
end

return WeaponServer
