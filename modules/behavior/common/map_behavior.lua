local WorldBehavior = World

function WorldBehavior:getUnit(param)
  if param.type == Define.Unit.Type.Entity then
    return self:getEntity(param.id)
  end
  return nil
end
