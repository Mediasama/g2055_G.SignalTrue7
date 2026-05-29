local EntityColliderHelper = T(Lib, "EntityColliderHelper")

function EntityColliderHelper:addEntityCollisionBox(entity, collider, boneName, offset)
  local parent = World.CurMap:getScene():getRoot()
  local node = EntitySocketNode.Create(boneName)
  collider.bindEntity = entity
  entity.bindColliderList = entity.bindColliderList or {}
  table.insert(entity.bindColliderList, node)
  if offset then
    collider:setLocalPosition(offset)
  end
  entity:addChild(node)
  node:addChild(collider)
end

function EntityColliderHelper:addEntityCollisionBoxStatic(entity, collider, pos)
  local parent = World.CurMap:getScene():getRoot()
  collider.bindEntity = entity
  entity.bindColliderList = entity.bindColliderList or {}
  table.insert(entity.bindColliderList, collider)
  if pos then
    collider:setLocalPosition(pos)
  end
  parent:addChild(collider)
end

function EntityColliderHelper:removeEntityCollisionBox(entity)
  if entity.bindColliderList then
    local parent = World.CurMap:getScene():getRoot()
    for i, collider in ipairs(entity.bindColliderList) do
      if collider.isValid and collider:isValid() then
        parent:removeChild(collider)
      end
    end
    entity.bindColliderList = nil
  end
end

return EntityColliderHelper
