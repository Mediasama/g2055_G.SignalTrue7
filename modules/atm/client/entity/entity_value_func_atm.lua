local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:ATMHurtStamp(value)
  if self:cfg().ATMType == Define.ATM_TYPE.ATM then
  end
end
