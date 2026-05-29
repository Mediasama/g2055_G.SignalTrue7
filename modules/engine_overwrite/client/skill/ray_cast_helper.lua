local RayCastHelper = T(Lib, "RayCastHelper")
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

function RayCastHelper:startRayCast(weaponPos, direction, cameraLength)
  local results = Me.map:getPhysicsWorld():raycastAll(weaponPos, direction, 50, -1)
  local hitObj = getHitObj(results, weaponPos)
  return hitObj
end

return RayCastHelper
