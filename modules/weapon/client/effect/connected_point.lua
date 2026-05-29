local ConnectedPoint = Lib.class("ConnectedPoint", {})

function ConnectedPoint:ctor(points)
  self:setPoints(points)
end

function ConnectedPoint:getPoints(hintNum)
  return self.points
end

function ConnectedPoint:setPoints(points)
  self.points = points
end

return ConnectedPoint
