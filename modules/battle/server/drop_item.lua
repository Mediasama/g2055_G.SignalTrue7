function DropItemServer:pick(player)
  print("DropItemServer:pick")
end

function DropItemServer:canPicked(player)
  print("DropItemServer:canPicked ===== ")
  local dropData = {}
  dropData.objID = self.objID
  dropData.itemData = self:getItemData()
  dropData.pos = self:getConfigPos()
  player:sendPacket({
    pid = "showDropItem",
    dropData = dropData
  })
end

function DropItemServer:getItemCount()
  if not self.count then
    self.count = self.properties.count
  end
  return self.count
end

function DropItemServer:setItemData(data)
  self.itemData = data
end

function DropItemServer:getItemData()
  return self.itemData
end

function DropItemServer:setItemCount(count)
  self.count = count
end

function DropItemServer:setConfigPos(pos)
  self.configPos = pos
end

function DropItemServer:getConfigPos()
  if not self.configPos then
    local pos = Lib.v3(0, 0, 0)
    local posStr = self.properties.position
    for i, v in ipairs(Lib.splitString(posStr, " ")) do
      local d = Lib.splitString(v, ":")
      pos[d[1]] = d[2]
    end
    self.configPos = pos
  end
  return self.configPos
end

function DropItemServer:setLifeTime(cd)
  if self.dropTimer then
    self.dropTimer()
  end
  self.dropTimer = World.LightTimer("drop behavior", cd, function()
    self:destroy()
  end)
end

local oldDestroy = DropItemServer.destroy

function DropItemServer:destroy()
  if self.dropTimer then
    self.dropTimer()
  end
  oldDestroy(self)
end

function DropItemServer:spawnInfo()
  return {
    pid = "DropItemSpawn",
    objID = self.objID,
    pos = self.createPos or self:getPosition(),
    item = self:item() and self:item():seri(),
    pitch = self:data("pitch"),
    yaw = self:data("yaw"),
    moveSpeed = self.moveSpeed,
    moveTime = self.moveTime,
    guardTime = self:data("guardTime"),
    shake = self:data("shake"),
    fixRotation = self.fixRotation,
    instanceId = self:getInstanceID(),
    itemData = self.itemData
  }
end
