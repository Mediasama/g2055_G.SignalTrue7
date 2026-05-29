function Player:autoDataExpire()
  local lastLoginTime = self:getLastLoginTime()
  
  local nowTime = os.time()
  if not Lib.isSameWeek(lastLoginTime, nowTime) then
  end
  if not lastLoginTime or not Lib.isSameDay(lastLoginTime, nowTime) then
  end
  self:updateLastLoginTime()
end
