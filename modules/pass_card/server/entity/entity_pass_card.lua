local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer
local PassCardHelper = T(Lib, "PassCardHelper")

function Entity:isPassCardDate()
  local date = self:getPlayerPassCardDate()
  if date.passCardBeginDate and date.passCardEndDate then
    return PassCardHelper:isPassCardDate(date.passCardBeginDate, date.passCardEndDate)
  end
  return false
end
