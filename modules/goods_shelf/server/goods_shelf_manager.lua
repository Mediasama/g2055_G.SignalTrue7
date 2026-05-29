local GoodsShelfFactory = require("server.goods_shelf_factory")
local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local GoodsShelfManager = Lib.class("GoodsShelfManager")
local _instance

function GoodsShelfManager.Instance()
  if _instance == nil then
    _instance = GoodsShelfManager.new()
    _instance:init()
  end
  return _instance
end

function GoodsShelfManager:ctor()
  self.shelfDict = {}
  self.loaded = false
end

function GoodsShelfManager:init()
end

function GoodsShelfManager:destroy()
end

function GoodsShelfManager:getShelfDict()
  return self.shelfDict
end

function GoodsShelfManager:getShelf(uid)
  return self.shelfDict[uid]
end

function GoodsShelfManager:setShelf(uid, shelf)
  if not uid then
    return
  end
  if not shelf then
    return
  end
  self.shelfDict[uid] = shelf
end

function GoodsShelfManager:removeShelf(uid)
  self.shelfDict[uid] = nil
end

function GoodsShelfManager:addShelf(shelf)
  self:setShelf(shelf:getUid(), shelf)
end

function GoodsShelfManager:deleteBastion(shelf)
  self:removeShelf(shelf:getUid())
end

function GoodsShelfManager:loadShelves()
  if self.loaded then
    return
  end
  local shelves = GoodsShelfConfig:getAllCfgs()
  for i, shelfConfigItem in pairs(shelves) do
    local shelf = GoodsShelfFactory.Instance():create(shelfConfigItem)
    if shelf then
      self:addShelf(shelf)
    end
  end
  self.loaded = true
end

return GoodsShelfManager
