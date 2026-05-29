local Player = _ENV.Player
local viewPreStr = "TerritoryView"

function Player:getAllTerritoryEntity()
  return self.allTerritoryEntity
end

function Player:syncAllTerritoryEntity()
  self:sendPacket({
    pid = "onGetAllTerritoryEntity"
  }, function(result)
    self.allTerritoryEntity = result.data
  end)
end

function Player:showTerritoryView(objID, data)
  if not objID then
    return
  end
  local object = World.CurWorld:getObject(objID)
  if not object or not object:isValid() then
    return false
  end
  local openParam = data
  if openParam then
    openParam.objID = objID
  end
  local windowName = "./UI/territory/win_territory"
  local cfg = World.cfg.territoryCfg.headUI
  local position = object:getPosition() + cfg.position
  local sceneArgs = {
    position = position,
    rotation = cfg.rotation,
    width = cfg.width,
    height = cfg.height,
    isCullBack = false,
    objID = -1,
    flags = cfg.flags
  }
  Lib.showSceneUI(objID, viewPreStr, openParam, sceneArgs, windowName)
end

function Player:hideTerritoryView(objID)
  Lib.hideSceneUI(objID, viewPreStr)
end

function Player:getTerritoryOccupyInfo()
  self:sendPacket({
    pid = "onGetTerritoryOccupyInfo"
  }, function(result)
    Lib.emitEvent(Event.UPDATE_TERRITORY_MAP_INFO, result.data)
  end)
end

function Player:occupyTerritory(id, cb)
  local gangId = self:getGangId()
  if gangId == nil then
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.TerritoryPacketTips[Define.TerritoryPacketCode.NeedAddGang]))
    return
  end
  self:sendPacket({
    pid = "onRequestOccupy",
    id = id
  }, function(result)
    if result and result.code == Define.TerritoryPacketCode.Success then
      if cb then
        cb(result.code)
      end
    else
      if Define.TerritoryPacketTips[result.code] then
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.TerritoryPacketTips[result.code]))
      end
      if cb then
        cb(result.code)
      end
    end
  end)
end

local DrawLineHelper = require("modules.draw_line.draw_line_helper")

function Player:drawBoxByLaser(vis, initPs)
  if initPs == nil then
    return
  end
  if not vis and self.laserHelper == nil then
    return
  end
  if self.laserHelper ~= nil then
    for i = 1, #self.laserHelper do
      self.laserHelper[i]:updateLineDraw(false)
    end
    self.laserHelper = nil
  end
  if self.laserHelper == nil then
    local pos = World.cfg.laserCfg.laserPos
    self.laserHelper = {}
    for i = 1, #pos do
      local lineDrawHelper = DrawLineHelper.new(World.cfg.laserCfg.bulletCfg)
      self.laserHelper[i] = lineDrawHelper
    end
  end
  if not vis then
    for i = 1, #self.laserHelper do
      self.laserHelper[i]:updateLineDraw(vis, nil, 0)
    end
  else
    for i = 1, #self.laserHelper do
      self.laserHelper[i]:updateLineDraw(vis, initPs[i], 0)
    end
  end
end

function Player:drawBoxLaser()
  local pos = World.cfg.laserCfg.laserPos or nil
  self:drawBoxByLaser(true, pos)
end
