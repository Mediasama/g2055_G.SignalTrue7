local BulletNode = Lib.class("Weapon")

function BulletNode:ctor()
  self.timeCount = 0
end

function BulletNode:destroy()
  local parent = self.owner
  if parent then
    parent:removeChild(self.effect)
  end
end

function BulletNode:setEffect(dt, parent, effectName, beginPos, endPos, lineTime, rotation)
  self.timeCount = self.timeCount + dt
  self.owner = parent
  if not self.effect then
    local effect = EffectNode.Load(effectName)
    effect:setViewRange({
      x = 2,
      y = 2,
      z = 2
    })
    if effect then
      if self.effect then
        self:removeChild(self.effect)
        self.effect = nil
      end
      self.effect = effect
      self.owner:addChild(self.effect)
    end
  end
  local posX = (endPos.x - beginPos.x) * self.timeCount / lineTime + beginPos.x
  local posY = (endPos.y - beginPos.y) * self.timeCount / lineTime + beginPos.y
  local posZ = (endPos.z - beginPos.z) * self.timeCount / lineTime + beginPos.z
  self.effect:setLocalQuaternion(Quaternion.fromEulerAngle(rotation.x, rotation.y, rotation.z))
  self.effect:setLocalPosition(Lib.v3(posX, posY, posZ))
end

return BulletNode
