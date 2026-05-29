local worldCfg = World.cfg
local ConnectedPoint = require("client.effect.connected_point")
local LineObjectHelper = Lib.class("LineObjectHelper", {})

function LineObjectHelper:ctor(bulletCfg, parent, index)
  self.index = index
  self:initLineObject(bulletCfg, parent)
end

function LineObjectHelper:initLineObject(bulletCfg, parent)
  self.node = Instance.Create("LineRenderer")
  self.material = Material.CreateFromTemplate(bulletCfg.material)
  self.node:setMaterial(self.material)
  if bulletCfg.color then
    self.node:setColor(bulletCfg.color)
  end
  self.node:setSegmentLength(bulletCfg.segmentLength or 0)
  if bulletCfg.frameSpeed then
    self.frameSpeed = bulletCfg.frameSpeed
  end
  if bulletCfg.imgTexture then
    self.textures = bulletCfg.imgTexture
  end
  self.finalTexture = bulletCfg.finalTexture
  self.curve = ConnectedPoint.new({
    Lib.v3(0, 0, 0),
    Lib.v3(0, 0, 0)
  })
  self.node:setCurve(self.curve)
  self.node:setLocalPosition(Lib.v3(0, 0, 0))
  self.parent = parent
  self:setLineVisible(false)
  self:setLineWidth(bulletCfg.width)
end

function LineObjectHelper:setLineWidth(width)
  if self.width ~= width then
    self.width = width
    local sWidth = self.width
    self.node:setWidth(sWidth)
  end
end

function LineObjectHelper:setLineVisible(vis)
  local parent = self.node:getParent()
  if vis then
    if parent == nil then
      self.parent:addChild(self.node)
    end
  elseif parent ~= nil then
    self.parent:removeChild(self.node)
  end
end

function LineObjectHelper:updateRenderInfo(timeDelta)
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

function LineObjectHelper:updateStraightLineDraw(timeDelta, vis, pos, endPos, width)
  if self.node == nil then
    return
  end
  self:setLineVisible(vis)
  self:updateRenderInfo(timeDelta)
  if vis and self.node then
    local points = {
      Lib.v3(pos.x, pos.y, pos.z),
      Lib.v3(endPos.x, endPos.y, endPos.z)
    }
    self.curve:setPoints(points)
    self:setLineWidth(width)
  end
end

function LineObjectHelper:destroy()
  if self.node then
    self.parent:removeChild(self.node)
  end
end

return LineObjectHelper
