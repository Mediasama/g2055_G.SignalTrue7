local AimHelper = T(Lib, "AimHelper")
AimHelper.ainBoxMap = {}
AimHelper.fireBoxMap = {}

local function getOffsetPos(entity, clonePosition)
  local rotation = Vector3.new(-entity:getRotationPitch(), -entity:getRotationYaw(), -entity:getRotationRoll())
  Lib.rotate(clonePosition, rotation)
  local pos = entity:getPosition() + clonePosition
  return pos
end

local function addToBone(entity, collider)
  local parent = World.CurMap:getScene():getRoot()
  local node = EntitySocketNode.Create("s_back")
  collider.bindEntity = entity
  entity:addChild(node)
  node:addChild(collider)
end

function AimHelper:addPlayerCollisionBox(entity)
  local aimRect = entity:cfg().autoAim
  local collideShape = {
    type = "Box",
    extent = {
      x = aimRect.x,
      y = aimRect.y,
      z = aimRect.z
    }
  }
  local collider = Instance.Create("CollisionObject")
  collider:setShape(collideShape)
  collider:setCanBlockCamera(false)
  collider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
  local pos = entity:cfg().autoAimOffset
  collider:setLocalPosition(pos)
  addToBone(entity, collider)
  collider.boxType = Define.COLLIDER_BOX_TYPE.AUTO_AIM
  self.ainBoxMap[entity] = collider
  local fireRect = entity:cfg().autoFire
  local fireCollideShape = {
    type = "Box",
    extent = {
      x = fireRect.x,
      y = fireRect.y,
      z = fireRect.z
    }
  }
  local fireCollider = Instance.Create("CollisionObject")
  fireCollider:setShape(fireCollideShape)
  fireCollider:setCanBlockCamera(false)
  fireCollider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
  local pos = entity:cfg().autoFireOffset
  fireCollider:setLocalPosition(pos)
  addToBone(entity, fireCollider)
  fireCollider.boxType = Define.COLLIDER_BOX_TYPE.AUTO_FIRE
  self.fireBoxMap[entity] = fireCollider
end

function AimHelper:removePlayerCollisionBox(entity)
  self:removeAutoAimBox(entity)
  self:removeAutoFireBox(entity)
end

function AimHelper:removeAutoAimBox(entity)
  local collider = self.ainBoxMap[entity]
  if collider then
    local parent = World.CurMap:getScene():getRoot()
    parent:removeChild(collider)
  end
  self.ainBoxMap[entity] = nil
end

function AimHelper:removeAutoFireBox(entity)
  local collider = self.fireBoxMap[entity]
  if collider then
    local parent = World.CurMap:getScene():getRoot()
    parent:removeChild(collider)
  end
  self.fireBoxMap[entity] = nil
end

function AimHelper:addPlayerAutoAimBox(entity)
  local aimRect = entity:cfg().autoAim
  local collideShape = {
    type = "Box",
    extent = {
      x = aimRect.x,
      y = aimRect.y,
      z = aimRect.z
    }
  }
  local collider = Instance.Create("CollisionObject")
  collider:setShape(collideShape)
  collider:setCanBlockCamera(false)
  collider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
  local parent = World.CurMap:getScene():getRoot()
  parent:addChild(collider)
  local pos = entity:cfg().autoAimOffset
  collider:setLocalPosition(pos)
  addToBone(entity, collider)
  collider.boxType = Define.COLLIDER_BOX_TYPE.AUTO_AIM
  self.ainBoxMap[entity] = collider
  if not self.aimTimer then
    self.aimTimer = World.LightTimer("updateBoxPos", 1, function()
      self:updateBoxPos()
      return true
    end)
  end
end

function AimHelper:addPlayerAutoFireBox(entity)
  local pos = entity:cfg().autoFireOffset
  local fireRect = entity:cfg().autoFire
  local fireCollideShape = {
    type = "Box",
    extent = {
      x = fireRect.x,
      y = fireRect.y,
      z = fireRect.z
    }
  }
  local fireCollider = Instance.Create("CollisionObject")
  fireCollider:setShape(fireCollideShape)
  fireCollider:setCollisionGroup(Define.COLLISION_GROUP.BOX)
  fireCollider:setCanBlockCamera(false)
  fireCollider:setLocalPosition(pos)
  addToBone(entity, fireCollider)
  fireCollider.boxType = Define.COLLIDER_BOX_TYPE.AUTO_FIRE
  self.fireBoxMap[entity] = fireCollider
  if not self.aimTimer then
    self.aimTimer = World.LightTimer("updateBoxPos", 1, function()
      self:updateBoxPos()
      return true
    end)
  end
end

function AimHelper:updateBoxPos()
  for entity, collider in pairs(self.ainBoxMap) do
    if entity and entity:isValid() and collider then
      local clonePosition = entity:cfg().autoAimOffset
      local pos = getOffsetPos(entity, clonePosition)
      collider:setLocalPosition(pos)
    end
  end
  for entity, collider in pairs(self.fireBoxMap) do
    if entity and entity:isValid() and collider then
      local clonePosition = entity:cfg().autoFireOffset
      local pos = getOffsetPos(entity, clonePosition)
      collider:setLocalPosition(pos)
    end
  end
end

return AimHelper
