local MissileNode = Lib.class("MissileNode")
local Gravity = -12.8
local HitEffectTime = 2

function MissileNode:ctor(missileConf, ownerID)
  self.missileConf = missileConf
  self.effect = EffectNode.Load(missileConf.throwEffect)
  self.effect:setViewRange({
    x = 2,
    y = 2,
    z = 2
  })
  World.CurMap:getScene():getRoot():addChild(self.effect)
  self.hitEffect = true
  self.ownerID = ownerID
end

function MissileNode:destroy()
  World.CurMap:getScene():getRoot():removeChild(self.effect)
end

function MissileNode:startMissile(startPos, endPos, t, gravity, lockObjID)
  print("============ endPos=", endPos.x, endPos.y, endPos.z, lockObjID)
  Gravity = gravity
  self.lockObjID = lockObjID
  self.vx = (endPos.x - startPos.x) / t
  self.vz = (endPos.z - startPos.z) / t
  self.vy = (endPos.y - startPos.y - Gravity * t * t / 2) / t
  self.t = t
  self.curPos = startPos
  self.startPos = startPos
  self.endPos = endPos
  local curTime = 0
  local dt = Lib.tickToTime(1) / 1000
  World.LightTimer("MissileNode", 1, function()
    curTime = curTime + dt
    if curTime <= t then
      self:updatePos(curTime, dt)
    elseif curTime <= t + HitEffectTime then
      if self.hitEffect then
        World.CurMap:getScene():getRoot():removeChild(self.effect)
        if lockObjID then
          self.effect = EffectNode.Load(self.missileConf.throwHitEffect)
          local scale = self.missileConf.throwHitEffectScale
          self.effect:setLocalScale(Lib.v3(scale, scale, scale))
        else
          self.effect = EffectNode.Load(self.missileConf.throwGround)
          local scale = self.missileConf.throwGroundScale
          self.effect:setLocalScale(Lib.v3(scale, scale, scale))
        end
        self.effect:setViewRange({
          x = 2,
          y = 2,
          z = 2
        })
        self.effect:setLocalPosition(endPos)
        World.CurMap:getScene():getRoot():addChild(self.effect)
        self.hitEffect = false
        if self.missileConf.hitSound and self.ownerID == Me.objID then
          Me:playSoundByKey(self.missileConf.hitSound)
        end
      end
    else
      self:destroy()
      return false
    end
    return true
  end)
end

function MissileNode:getTestPos()
  self.endPos.x = self.endPos.x + 0.25
  return self.endPos
end

function MissileNode:getTargetPosition(entity)
  local pos = entity:getPosition()
  local offset
  if entity.isPlayer then
    local conf = self.missileConf.hitPlayerOffset
    offset = Vector3.new(conf[1], conf[2], conf[3])
  elseif entity:cfg().isTrolley then
    local conf = self.missileConf.hitCarOffset
    offset = Vector3.new(conf[1], conf[2], conf[3])
  elseif entity.getBastionDefenseType and entity:getBastionDefenseType() == Define.Bastion.Defense.Type.Door then
    local conf = self.missileConf.hitDoorOffset
    offset = Vector3.new(conf[1], conf[2], conf[3])
  else
    return pos
  end
  local rotation = Vector3.new(0, -entity:getRotationYaw(), 0)
  Lib.rotate(offset, rotation)
  pos = pos + offset
  return pos
end

function MissileNode:updatePos(curTime, dt)
  local nextPos = Lib.copy(self.curPos)
  if self.lockObjID then
    local entity = World.CurWorld:getEntity(self.lockObjID)
    if entity and entity:isValid() then
      local endPos = self:getTargetPosition(entity)
      local vx = (endPos.x - self.curPos.x) / (self.t - curTime)
      local vz = (endPos.z - self.curPos.z) / (self.t - curTime)
      nextPos.x = nextPos.x + vx * dt
      nextPos.z = nextPos.z + vz * dt
    else
      nextPos.x = self.vx * curTime + self.startPos.x
      nextPos.z = self.vz * curTime + self.startPos.z
    end
  else
    nextPos.x = self.vx * curTime + self.startPos.x
    nextPos.z = self.vz * curTime + self.startPos.z
  end
  nextPos.y = self.vy * curTime + Gravity * curTime * curTime / 2 + self.startPos.y
  self.effect:setLocalPosition(nextPos)
  self.curPos = nextPos
end

return MissileNode
