local handles = T(Player, "PackageHandlers")

function handles:showRechargeFull(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  local chargeAction = packet.chargeAction
  if entity and entity:isValid() and entity.isPlayer then
    print("showRechargeFull(packet)")
    local effect = EffectNode.Load("g2055_melee_charge.effect")
    local node = EntitySocketNode.Create("BuSuiFu")
    local parent = World.CurMap:getScene():getRoot()
    entity:addChild(node)
    node:addChild(effect)
    self.rechargeEffectNode = effect
    self.rechargeNode = node
    effect:setLocalPosition(chargeAction.offset)
    local rotation = chargeAction.rotation
    effect:setLocalQuaternion(Quaternion.fromEulerAngle(rotation.x, rotation.y, rotation.z))
    local scale = chargeAction.scale
    effect:setLocalScale(Lib.v3(scale, scale, scale))
    effect:setViewRange({
      x = 5,
      y = 1,
      z = 5
    })
  end
end

function handles:hideRechargeFull(packet)
  print("handles:hideRechargeFull(packet)")
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity and entity:isValid() and entity.isPlayer then
    print("======================= in here")
    local parent = World.CurMap:getScene():getRoot()
    if self.rechargeNode and self.rechargeEffectNode then
      self.rechargeNode:removeChild(self.rechargeEffectNode)
      parent:removeChild(self.rechargeNode)
      self.rechargeEffectNode = nil
    end
  end
end
