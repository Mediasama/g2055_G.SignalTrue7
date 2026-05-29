local HitBoxHelper = T(Lib, "HitBoxHelper")
HitBoxHelper.hitBoxMap = {}

function HitBoxHelper:addPlayerHitBox(entity)
  local parent = World.CurMap:getScene():getRoot()
  local hitBoxList = entity:cfg().hitbox
  if not hitBoxList then
    return
  end
  local nodeList = {}
  for i, boxConf in ipairs(hitBoxList) do
    local collider = Instance.Create("CollisionObject")
    collider:setCanBlockCamera(false)
    collider:setShape(boxConf.collider)
    local pos = boxConf.colliderOffset
    collider:setLocalPosition(pos)
    collider.boxType = Define.COLLIDER_BOX_TYPE.HIT_BOX
    collider.parentObjID = entity.objID
    collider.hitBoxType = tonumber(boxConf.type)
    collider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
    local node = EntitySocketNode.Create(boxConf.bone)
    entity:addChild(node)
    node:addChild(collider)
    table.insert(nodeList, node)
  end
  self.hitBoxMap[entity] = nodeList
end

function HitBoxHelper:removePlayerHitBox(entity)
  local nodeList = self.hitBoxMap[entity]
  if nodeList then
    local parent = World.CurMap:getScene():getRoot()
    for i, v in ipairs(nodeList) do
      parent:removeChild(v)
    end
  end
  self.hitBoxMap[entity] = nil
end

return HitBoxHelper
