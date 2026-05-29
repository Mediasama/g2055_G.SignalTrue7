local handles = T(Player, "PackageHandlers")
local LuaTimer = T(Lib, "LuaTimer")

function handles:cutBullet(packet)
  if self.weapon then
    self.weapon:cutBullet(packet.num, packet.index)
  end
end

function handles:BulletDoDamage(packet)
  if not packet then
    return
  end
  self:BulletDoDamage(packet)
end

function handles:changeWeapon2s(packet)
  if not packet then
    return
  end
  self.handSelectIndex = packet.index
  self:changeWeapon(packet.weaponId)
end

function handles:fillBullet(packet)
  self:fillBullet(packet.count)
end

function handles:pickWeapon(packet)
  local objID = packet.objID
  local battleField = self.battleField
  if battleField then
    battleField:onPickDrop(objID)
  end
end

function handles:playerAction(packet)
  local actionName = packet.actionName
  local time = packet.time
  local objID = self.objID
  local isOnce = packet.isOnce
  self:sendClientPlayerAction(actionName, time, objID, isOnce)
end

function handles:playerFireAction(packet)
  local actionName = packet.actionName
  local data = {}
  data.actionName = packet.actionName
  data.time = packet.time
  data.objID = self.objID
  local p = {
    pid = "playerAction",
    data = data
  }
  self:broadcastDungeonPacket(p)
  self:setActionRun(actionName)
end

function handles:initPlayerAction(packet)
  local actionName = packet.actionName
  self:setActionIdle(packet.idle)
  self:setActionRun(packet.run)
end

function handles:BulletEffect(packet)
  local battleField = self.battleField
  if battleField then
    battleField:addBulletEffect(packet.hitEffectData, packet.bulletEffectData)
  end
end

function handles:syncTargetForward(packet)
  self:setForceMove(packet.pos, 2)
end

function handles:MissileDoDamage(packet)
  local missileInfo = packet.missileInfo
  if missileInfo.objID then
    local entity = World.CurWorld:getEntity(missileInfo.objID)
    if entity and entity:isValid() then
      local pos = entity:getPosition()
      local dis = Lib.getPosDistance(pos, missileInfo.targetPos)
      if 2 < dis then
        print("error \230\138\149\230\142\183\230\173\166\229\153\168\231\155\174\230\160\135\228\184\141\229\144\136\230\179\149", dis)
        self:sendPacket({
          pid = "showMyMissileEffect",
          missileInfo = missileInfo
        })
        return
      else
        missileInfo.lockObjID = missileInfo.objID
        self.battleField:addMissileInfo(missileInfo)
        packet.skillJsonConf = self.skillJsonConf
        LuaTimer:scheduleTimer(function()
          self:BulletDoDamage(packet)
        end, missileInfo.time * 1000, 1)
      end
    end
  else
    self.battleField:addMissileInfo(missileInfo)
    self.weapon:cutMeleeCount()
  end
end
