local LineObjectHelper = require("client.effect.line_object_helper")
local BulletNode = require("client.effect.bullet_node")
local MissileNode = require("client.effect.missile_node")
local WeaponEffectHelper = T(Lib, "WeaponEffectHelper")

function WeaponEffectHelper:showHitEffect(hitEffect, pos, time)
  Blockman.instance:playEffectByPos(hitEffect, pos, 0, time)
end

function WeaponEffectHelper:showHoleEffect(holeEffect, pos, time, scale)
end

function WeaponEffectHelper:showBulletEffect(effectName, bulletConf, weaponPos, endPos, rotation)
  local parent = World.CurMap:getScene():getRoot()
  self.lineObjectId = (self.lineObjectId and self.lineObjectId + 1 or 1) % 1000000
  if World.cfg.isShowBulletPos then
    Blockman.instance:playEffectByPos("g2049_effect_sp_03.effect", weaponPos, 0, 50000, Lib.v3(0.15, 0.15, 0.15))
    Blockman.instance:playEffectByPos("g2049_effect_sp_03.effect", endPos, 0, 50000, Lib.v3(0.15, 0.15, 0.15))
  end
  local timeCount = 0
  local dt = Lib.tickToTime(1) / 1000
  if effectName then
    local lineObj = BulletNode.new()
    World.LightTimer("BulletNode", 1, function()
      timeCount = timeCount + dt
      if timeCount <= bulletConf.lineTime then
        lineObj:setEffect(dt, parent, effectName, weaponPos, endPos, bulletConf.lineTime, rotation)
        return true
      else
        lineObj:destroy()
      end
    end)
  else
    local lineObj = LineObjectHelper.new(bulletConf, parent, self.lineObjectId)
    World.LightTimer("LineObjectHelper", 1, function()
      timeCount = timeCount + dt
      if timeCount <= bulletConf.lineTime then
        lineObj:updateStraightLineDraw(dt, true, weaponPos, endPos, bulletConf.width)
        return true
      else
        lineObj:destroy()
      end
    end)
  end
end

function WeaponEffectHelper:createMissile(missileInfo)
  local ViewDistance = 40
  local startPos = missileInfo.startPos
  local endPos = missileInfo.endPos
  local time = missileInfo.time
  local gravity = missileInfo.gravity
  local myPos = Me:getPosition()
  if ViewDistance < Lib.getPosDistance(myPos, startPos) and ViewDistance < Lib.getPosDistance(myPos, endPos) then
    return
  end
  local missile = MissileNode.new(missileInfo.missileConf, missileInfo.attackObjID)
  missile:startMissile(startPos, endPos, time, gravity, missileInfo.lockObjID)
end

return WeaponEffectHelper
