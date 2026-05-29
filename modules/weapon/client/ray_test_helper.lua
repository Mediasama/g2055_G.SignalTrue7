local RayTestHelper = T(Lib, "RayTestHelper")
local DCorrectedPoint = tonumber(World.cfg.DCorrectedLen)

local function getHitObj(collisionList, pos)
  if #collisionList == 0 then
    return
  end
  local obj
  local minLen = 99999
  for i, v in ipairs(collisionList) do
    local target = v.target
    if target.boxType == Define.COLLIDER_BOX_TYPE.HIT_BOX or target.className == "MeshPartClient" then
      local length = Lib.getPosDistance(v.collidePos, pos)
      if minLen > length then
        obj = v
        minLen = length
      end
    end
  end
  local hitBoxType = obj and obj.target.boxType
  return obj, hitBoxType
end

local function showRayLine(rayName, origin, direction, length)
  DebugDraw.addEntry(rayName, function()
    local d = Lib.copy(direction)
    d:normalize()
    local endPos = origin + d * length
    DebugDraw.instance:drawLine(origin, endPos, 4278190335)
  end)
  local funName = "set" .. rayName .. "Enabled"
  DebugDraw.instance[funName](DebugDraw.instance, true)
end

function RayTestHelper:startRayCast(weaponPos, cameraPos, cameraDirection, cameraLength, ownID)
  local d = Lib.copy(cameraDirection)
  d:normalize()
  local endPos = cameraPos + d * DCorrectedPoint
  local weaponDirection = endPos - weaponPos
  local length = Lib.getPosDistance(weaponPos, endPos)
  local resultTable = Me.map:getPhysicsWorld():raycastAll(weaponPos, weaponDirection, length, -1)
  local hitObj, hitBoxType = getHitObj(resultTable, weaponPos)
  if World.cfg.showBulletLine then
    showRayLine("ShowRayTestLine", weaponPos, weaponDirection, length)
    Blockman.instance:playEffectByPos("g2049_effect_sp_03.effect", weaponPos, 0, 50000, Lib.v3(0.15, 0.15, 0.15))
    Blockman.instance:playEffectByPos("g2049_effect_sp_03.effect", endPos, 0, 50000, Lib.v3(0.15, 0.15, 0.15))
  end
  if not hitObj then
    local results = Me.map:getPhysicsWorld():raycastAll(endPos, cameraDirection, cameraLength - DCorrectedPoint, -1)
    hitObj, hitBoxType = getHitObj(results, weaponPos)
  end
  hitBoxType = hitBoxType and hitObj.target.hitBoxType
  return hitObj, hitBoxType
end

return RayTestHelper
