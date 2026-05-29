local EntityNpcDoorClient = Entity

function EntityNpcDoorClient:ndp_updateProperty()
  local door = self
  if not door:ndp_getID() then
    return
  end
  local status = door:ndp_getStatus()
  if status == Define.Bastion.Defense.Status.Normal then
    self:setCollisionGroup(Define.COLLISION_GROUP.BUILDING)
  elseif status == Define.Bastion.Defense.Status.Damaged then
    self:setCollisionGroup(0)
  elseif status == Define.Bastion.Defense.Status.Hacked then
    self:setCollisionGroup(0)
  end
end
