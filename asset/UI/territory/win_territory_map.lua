local TerritoryConfig = T(Config, "TerritoryConfig")
local mapIconWidth = 42
local meIconWidth = 60
local gangMemberIconWidth = 46
local areaIconWidth = 141
local areaIconHeight = 111

function M:init()
  self.imageMap = self:child("ImageMap")
  self.buttonClose = self:child("ButtonClose")
  self.imageMe = self:child("ImageMe")
  self.imageMyHouse = self:child("ImageMyHouse")
  self.panelImageMe = self:child("PanelImageMe")
  for i = 1, 6 do
    self:child("Text" .. i):setText(Lang:toText("territory.map.tips" .. i))
  end
  self:child("TextBottomTips"):setText(Lang:toText("territory.map.tips.bottom"))
  
  function self.buttonClose.onMouseClick()
    Lib.emitEvent(Event.EVENT_UI_CLOSE_MINIMAP)
  end
  
  self.mapImgHeight = self.imageMap:getHeight()[2]
  self.mapImgWidth = self.imageMap:getHeight()[2]
  local mapCfg = World.cfg.territoryCfg.mapEdge
  local mapWidth = -(mapCfg.rightBottom.x - mapCfg.leftTop.x)
  local mapHeight = mapCfg.leftTop.z - mapCfg.rightBottom.z
  self.mapWidth = mapWidth
  self.mapHeight = mapHeight
  self.mapCfg = mapCfg
  self.gangMemberObjID = {}
  self:initMap()
  Me:requestMyGangData(function()
    self.gangMemberList = Me:getGangMemberList()
  end)
  self:initEvent()
  Me:getTerritoryOccupyInfo()
end

function M:initEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.UPDATE_TERRITORY_MAP_INFO, function(data)
    self:updateMapIconInfo(data)
  end)
end

function M:updateMapIconInfo(data)
  for k, v in pairs(data) do
    local id = v.id
    local item = self.iconWidget[id]
    if item then
      item:onDataChange(v)
    end
    item = self.iconArea[id]
    if item then
      item:onDataChange(v)
    end
  end
end

local function setMapPos(target, position, mapW, mapH, mapCfg, iconW, iconH, anchor)
  if anchor == nil then
    anchor = 0.5
  end
  if iconH == nil then
    iconH = iconW
  end
  local x = -(position.x - mapCfg.leftTop.x) / mapW + iconW / self.mapImgWidth * anchor
  local y = (position.z - mapCfg.rightBottom.z) / mapH - iconH / self.mapImgHeight * anchor
  target:setArea2({
    1 - x,
    0
  }, {y, 0}, {0, iconW}, {0, iconH})
end

function M:initTerritoryIcon(v)
  local pos = v.pos
  local item = UI:openWidget("./UI/territory/widget_territory_map_icon")
  self.imageMap:addChild(item:getWindow())
  setMapPos(item, pos, self.mapWidth, self.mapHeight, self.mapCfg, mapIconWidth)
  self.iconWidget[v.id] = item
  item:initIcon()
end

function M:initAreaIcon(v)
  local pos = v.area_pos
  local item = UI:openWidget("./UI/territory/widget_territory_area")
  self.imageMap:addChild(item:getWindow())
  setMapPos(item, pos, self.mapWidth, self.mapHeight, self.mapCfg, areaIconWidth, areaIconHeight, 0)
  self.iconArea[v.id] = item
  item:initIcon(v)
end

function M:initMap()
  if self.iconWidget == nil then
    self.iconWidget = {}
    self.iconArea = {}
    local cfg = TerritoryConfig:getAllCfgs()
    for k, v in pairs(cfg) do
      self:initAreaIcon(v)
      self:initTerritoryIcon(v)
    end
  end
  setMapPos(self.imageMe, Me:getPosition(), self.mapWidth, self.mapHeight, self.mapCfg, meIconWidth)
  setMapPos(self.imageMyHouse, Me:bhp_getBastionPosition(), self.mapWidth, self.mapHeight, self.mapCfg, meIconWidth)
  self:updateMePosition()
end

function M:updateGangMemberIconPos()
  local gangList = self.gangMemberList
  if gangList == nil then
    return
  end
  for k, v in pairs(gangList) do
    local objID = v.objID
    if objID ~= Me.objID then
      if self.gangMemberObjID[objID] == nil then
        local entity = World.CurWorld:getObject(objID)
        if entity and entity:isValid() then
          local pos = entity:getPosition()
          local item = UI:openWidget("./UI/territory/widget_gang_member_icon")
          self.panelImageMe:addChild(item:getWindow())
          setMapPos(item, pos, self.mapWidth, self.mapHeight, self.mapCfg, gangMemberIconWidth)
          self.gangMemberObjID[objID] = {entity = entity, item = item}
        end
      elseif self.gangMemberObjID[objID].entity:isValid() then
        setMapPos(self.gangMemberObjID[objID].item, self.gangMemberObjID[objID].entity:getPosition(), self.mapWidth, self.mapHeight, self.mapCfg, gangMemberIconWidth)
      else
        self.panelImageMe:removeChild(self.gangMemberObjID[objID].item)
        self.gangMemberObjID[objID] = nil
      end
    end
  end
end

local rotationV3 = {
  x = 0,
  y = 0,
  z = 1
}

function M:updateMeIconPos()
  setMapPos(self.imageMe, Me:getPosition(), self.mapWidth, self.mapHeight, self.mapCfg, meIconWidth)
  local initFightPosYaw = 90
  local visualYaw = Me:getCurYaw() - (initFightPosYaw or 0)
  local rotation = Quaternion.rotateAxis(rotationV3, visualYaw)
  local str = string.format("w:%f x:%f y:%f z:%f", rotation.w, rotation.x, rotation.y, rotation.z)
  self.imageMe:setProperty("Rotation", str)
end

function M:updateMePosition()
  self.posUpdater = World.Timer(1, function()
    self:updateMeIconPos()
    self:updateGangMemberIconPos()
    return true
  end)
end

function M:onOpen()
  self:setUsingAutoRenderingSurface(true)
  Me:evt_reportWinOpen("win_territory_map")
  self:init()
end

function M:onClose()
  Me:evt_reportWinClose("win_territory_map")
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.posUpdater then
    self.posUpdater()
    self.posUpdater = nil
  end
  for k, v in pairs(self.gangMemberObjID) do
    self.panelImageMe:removeChild(self.gangMemberObjID[k].item)
    self.gangMemberObjID[k] = nil
  end
  self.gangMemberList = nil
end
