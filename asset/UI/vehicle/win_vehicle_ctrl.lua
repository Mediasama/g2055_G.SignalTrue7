function M:init()
  self:initUI()
  
  self:initEvent()
end

function M:initUI()
end

function M:initEvent()
  function self.ButtonJump.onMouseClick()
    local useCarInfo = Me:getInUseCar()
    
    if useCarInfo then
      local params = {
        id = useCarInfo.id
      }
      Me:sendPacket({
        pid = "jumpVehicle",
        params = params
      })

      -- Enhanced Vehicle Jump (Client Side Impulse)
      local car = World.CurWorld:getEntity(useCarInfo.objId)
      if car and car:isValid() then
          local motion = car.motion
          motion.y = motion.y + 0.5
          car.motion = motion
      end
    end
  end
end

function M:onClose()
end

M:init()
