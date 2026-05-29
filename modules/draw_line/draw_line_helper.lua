local worldCfg = World.cfg
local ConnectedLinePoint = Lib.class("ConnectedLinePoint", {})

function ConnectedLinePoint:ctor(points)
  self:setPoints(points)
end

function ConnectedLinePoint:getPoints()
  return self.points
end

function ConnectedLinePoint:setPoints(points)
  self.points = points
end

local DrawLineHelper = Lib.class("DrawLineHelper", {})

function DrawLineHelper:ctor(bulletCfg, index)
  self.index = index
  self.parent = Me.map:getScene():getRoot()
  self:initLineObject(bulletCfg)
end

function DrawLineHelper:initLineObject(bulletCfg)
  bulletCfg = bulletCfg or {
    imgTexture = {"jg07.png"},
    segmentLength = 5,
    scrollingSpeed = 5,
    frameSpeed = 5,
    width = 25
  }
  self.node = Instance.Create("LineRenderer")
  if bulletCfg then
    if bulletCfg.color then
      self.node:setColor(bulletCfg.color)
    end
    self.node:setSegmentLength(bulletCfg.segmentLength or 0)
    if bulletCfg.frameSpeed then
      self.frameSpeed = bulletCfg.frameSpeed
    else
      self.frameSpeed = 0.04
    end
    if bulletCfg.imgTexture then
      self.textures = bulletCfg.imgTexture
    end
    if bulletCfg.finalTexture then
      self.finalTexture = bulletCfg.finalTexture
    end
    if bulletCfg.material then
      self.material = Material.CreateFromTemplate(bulletCfg.material)
    else
      self.material = Material.CreateFromTemplate("jiguang.json")
    end
    if bulletCfg.width then
      self:setLineWidth(bulletCfg.width)
    else
      self:setLineWidth(100)
    end
  else
    self.material = Material.CreateFromTemplate("jiguang.json")
    self:setLineWidth(100)
    self.frameSpeed = 0.04
  end
  self.node:setMaterial(self.material)
  self.linePoints = {
    Lib.v3(0, 0, 0),
    Lib.v3(0, 0, 0)
  }
  self.curve = ConnectedLinePoint.new(self.linePoints)
  self.curve:setPoints(self.linePoints)
  self.node:setCurve(self.curve)
  self.node:setLocalPosition(Lib.v3(0, 0, 0))
  self:setLineVisible(false)
end

function DrawLineHelper:setLineWidth(width)
  if self.width ~= width then
    self.width = width
    self.node:setWidth(self.width)
  end
end

function DrawLineHelper:setLineVisible(vis)
  local parent = self.node:getParent()
  if vis then
    if parent == nil then
      self.parent:addChild(self.node)
    end
  elseif parent ~= nil then
    self.parent:removeChild(self.node)
  end
end

function DrawLineHelper:updateRenderInfo(timeDelta)
  if timeDelta == nil then
    return
  end
  if not self.time then
    self.time = 0
    self.textureIndex = 1
  end
  self.time = self.time + timeDelta
  if self.time > self.frameSpeed then
    self.textureIndex = self.textureIndex + 1
    self.time = 0
  end
  local final = false
  if self.textureIndex > #self.textures then
    if self.finalTexture then
      final = true
    else
      self.textureIndex = 1
    end
  end
  self.material:activeTexture(0, final and self.finalTexture or self.textures[self.textureIndex])
end

function DrawLineHelper:updateLineDraw(vis, points, timeDelta, width)
  if self.node == nil then
    return
  end
  self:setLineVisible(vis)
  if points == nil or points and #points < 2 then
    return
  end
  if vis then
    local initPoints = Lib.v3(points[1].x, points[1].y, points[1].z)
    self.node:setLocalPosition(initPoints)
    self:updateRenderInfo(timeDelta)
    for i = 2, #points do
      self.linePoints[i] = Lib.v3(points[i].x, points[i].y, points[i].z) - initPoints
    end
    self.curve:setPoints(self.linePoints)
    if self.width ~= width and width then
      self.node:setWidth(width)
      self.width = width
    end
  end
end

function DrawLineHelper:destroy()
  if self.node and self.node:getParent() == nil then
    self:setLineVisible(true)
  end
end

return DrawLineHelper
