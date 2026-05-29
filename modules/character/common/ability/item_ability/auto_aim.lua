local AutoAim = T(Lib, "AutoAim")
local CameraManager = T(Lib, "CameraManager")
local LuaTimer = T(Lib, "LuaTimer")

function AutoAim:checkAutoAim()
  local isAutoAim = self.entity.weapon:getIsAutoAim()
  local isAutoFire = self.entity.weapon:getIsAutoFire()
  local curCamera = Camera.getActiveCamera()
  local origin = curCamera:getPosition()
  local direction = curCamera:getDirection()
  local curLength = 500
  local resultTable = Me.map:getPhysicsWorld():raycastAll(origin, direction, curLength, Define.COLLISION_GROUP.BOX)
  local hitObj
  if isAutoAim then
    for i, obj in ipairs(resultTable) do
      local target = obj.target
      if target.boxType == Define.COLLIDER_BOX_TYPE.AUTO_AIM then
        local minDis = 999
        if target and target.bindEntity and target.bindEntity:isValid() then
          local pos = target.bindEntity:getPosition()
          local sPos = Blockman.instance:getScreenPos(pos)
          local offsetX, offsetY = sPos.x - 0.5, sPos.y - 0.5
          local dis = offsetX * offsetX + offsetY * offsetY
          if minDis > dis then
            hitObj = obj
            minDis = dis
          end
        end
      end
    end
    if hitObj then
      local hitPos = hitObj.collidePos
      local dir1 = hitPos - origin
      local target = hitObj.target
      local center = Lib.copy(target.bindEntity:getPosition())
      center.y = hitPos.y
      local dir2 = center - origin
      local qu = Quaternion.fromVectorRotation(dir1, dir2)
      local pitch, yaw, roll = qu:toEulerAngle()
      self:moveToTarget(target, pitch, yaw)
    end
  end
  if isAutoFire then
    local launcher = self.entity.weapon:getLauncher()
    if not launcher then
      return
    end
    local needFire
    for i, hitObj in ipairs(resultTable) do
      local target = hitObj.target
      if target.boxType == Define.COLLIDER_BOX_TYPE.AUTO_FIRE and target and target.bindEntity and target.bindEntity:isValid() then
        local distance = launcher.autoFireDistance or 500
        local pos = target.bindEntity:getPosition()
        local dis = Lib.getPosDistance(origin, pos)
        if distance >= dis then
          needFire = true
          break
        end
      end
    end
    if self.isOpenFire and not needFire then
      self:closeFire()
    end
    if not self.isOpenFire and needFire then
      local delay = launcher.autoFireDelay
      if delay and not self.delayCall then
        self.delayCall = World.LightTimer("AutoAim:delayCall", delay * 20, function()
          if self.needFire then
            self:openFire()
          end
          self.delayCall = nil
        end)
      else
        self:openFire()
      end
    end
    self.needFire = needFire
  end
end

function AutoAim:init(entity)
  self.entity = entity
  self.aimTimer = World.LightTimer("AutoAim:init", 2, function()
    self:checkAutoAim()
    return true
  end)
end

function AutoAim:closeAbility(entity)
  self:aimTimer()
end

function AutoAim:moveToTarget(target, pitch, yaw)
  local offset = tonumber(World.cfg.autoAimMoveSpeed)
  if 0 < yaw then
    if yaw < offset then
      offset = yaw
    end
  elseif yaw > -offset then
    offset = yaw
  else
    offset = -offset
  end
  if 0.01 < offset or offset < -0.01 then
    CameraManager:changeCameraYaw(-offset, 5)
  end
end

function AutoAim:openFire()
  self.isOpenFire = self.entity.weapon:autoFire()
end

function AutoAim:closeFire()
  self.isOpenFire = false
  self.entity.weapon:closeFire()
end

return AutoAim
