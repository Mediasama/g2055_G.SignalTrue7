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
    end
  end
end

function M:onClose()
end

M:init()
