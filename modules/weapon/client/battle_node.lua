defineNode("BattleNode")

function BattleNode:init(owner)
  self.owner = owner
  self.effect = nil
  self.collider = nil
  self.timeEffect = nil
  self.actor = nil
end

function BattleNode:getOwner()
  return self.owner
end

function BattleNode:setOwner(owner)
  self.owner = owner
end

function BattleNode:removeFromParent()
  local parent = self:getParent()
  if parent then
    parent:removeChild(self)
  end
end

function BattleNode:setActor(actorName)
  local actor = ActorNode.Load(actorName)
  if actor then
    if self.actor then
      self:removeChild(self.actor)
      self.actor = nil
    end
    self.actor = actor
    self:addChild(actor)
  end
end

function BattleNode:getActorPos()
  if self.actor then
    return self.actor:getLocalPosition()
  end
  return
end

function BattleNode:setActorPos(pos)
  if self.actor then
    self.actor:setLocalPosition(pos)
  end
end

function BattleNode:playSkill(skillName)
  if self.actor then
    self.actor:playSkill(skillName)
  end
end

function BattleNode:onUpdate(dt)
  self.rotation = self.rotation and self.rotation + 3 or 3
  if self.rotation > 360 then
    self.rotation = self.rotation - 360
  end
  self:setLocalQuaternion(Quaternion.fromEulerAngle(0, self.rotation, 0))
end

function BattleNode:removeFromParent()
  if not self.isRemove then
    local parent = World.CurMap:getScene():getRoot()
    parent:removeChild(self)
  end
  self.isRemove = true
end

function BattleNode:getIsRemove()
  return self.isRemove
end

function BattleNode:setObjID(Id)
  self.objID = Id
end

return BattleNode
