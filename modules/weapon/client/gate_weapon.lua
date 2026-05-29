local WeaponClient = T(Lib, "WeaponClient")
local SoundConfig = T(Config, "SoundConfig")

function WeaponClient:export_handlePlayerDead(hurtInfo)
  if not hurtInfo then
    return
  end
  local hurtObjID = hurtInfo.hurtObjID
  local attackObjID = hurtInfo.attackObjID
  local hurtEntity = World.CurWorld:getEntity(hurtInfo.hurtObjID)
  if attackObjID == Me.objID then
    Lib.emitEvent(Event.EVENT_ROGUELIKE_ENEMY_HURT, 4)
    Me:playSound(SoundConfig:getSound("kill_sound"))
    Me:playSoundByKey("g2055_battle_kill")
    Lib.emitEvent(Event.EVENT_KILL_ICON)
    Me:removeKillEnemy(hurtEntity)
  end
  local name1 = hurtInfo.deadTips.fromName
  local name2 = hurtInfo.deadTips.weaponName
  Lib.emitEvent(Event.EVENT_KILL_TEXT, string.format("%s \229\135\187\230\157\128\228\186\134 %s", name1, name2))
end

return WeaponClient
