local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:player_motion_property(value)
  self:pam_updateMotion()
end
