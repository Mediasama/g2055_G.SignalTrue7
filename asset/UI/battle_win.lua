function M:onOpen(params)
  self.noTimer = true
  
  self:initUI(params or {})
  self.pkWindow.killImage:setVisible(false)
  self.pkWindow.killText:setVisible(false)
  self.pkWindow:setVisible(false)
  self.enemyPoints = {}
  self.dropPoints = {}
  self.imgRadarImg:setVisible(false)
  self:initOrientation()
end

function M:initUI(params)
  self.imgRadarImg = self.pkWindow.radarImg
  self.imgSectorImg = self.pkWindow.radarImg.sectorImg
  Lib.subscribeEvent(Event.EVENT_BATTLE_DATA, function(data)
    self:updateView(data)
  end)
  
  function self.preWindow.matchButton.onMouseClick()
    local CameraManager = T(Lib, "CameraManager")
    CameraManager:switchView()
  end
  
  Lib.subscribeEvent(Event.EVENT_BATTLE_DATA, function(data)
    self:updateView(data)
  end)
  Lib.subscribeEvent(Event.EVENT_KILL_ICON, function()
    self:showKillIcon()
  end)
  Lib.subscribeEvent(Event.EVENT_KILL_TEXT, function(text)
    self:showKillText(text)
  end)
end

function M:updateView(data)
  if data then
    self.isInBattle = true
    self.preWindow:setVisible(false)
    self.pkWindow:setVisible(true)
    Lib.logDebug("data data = ", Lib.v2s(data, 4))
    self.pkWindow.maxKillText:setText(data.rankData[1].killCount)
    for i, v in ipairs(data.rankData) do
      if v.playerID == Me.platformUserId then
        self.pkWindow.mykillText:setText(v.killCount)
        self.pkWindow.myRankText:setText(i)
      end
    end
    self:countDowning(data.leftTime)
  else
    self.preWindow:setVisible(true)
    self.pkWindow:setVisible(false)
  end
end

function M:countDowning(time)
  local count = math.floor(time)
  local text = "%s\231\167\146"
  self.pkWindow.leftTime:setText(string.format(text, count))
  if self.noTimer then
    World.LightTimer("", 20, function()
      count = count - 1
      self.pkWindow.leftTime:setText(string.format(text, count))
      if 0 < count then
        self.noTimer = false
        return true
      end
      self:updateView()
      self.isInBattle = false
      self.noTimer = true
    end)
  end
end

local LuaTimer = T(Lib, "LuaTimer")
local displayRefreshTime = 500
local orientationRefreshTime = 50
local pointWidth = 20
local maxDistance = 50
local radarWidth = 142
local radarRadius = (radarWidth - 46) / 2
local pointFile = "set:g2050_battle.json image:img_0_radar03"
local dropFile = "set:g2050_foster.json image:img_0_foster_replace01"
local v3AngleXZ = Lib.v3AngleXZ
local v3cut = Lib.v3cut
local RootW = 204
local RootH = 172

local function getPosDistance2D(pos1, pos2)
  if not pos1 or not pos2 then
    return math.huge
  end
  local dx, dz = pos1.x - pos2.x, pos1.z - pos2.z
  return math.sqrt(dx * dx + dz * dz)
end

function M:getAllEntity()
  local entityList = World.CurWorld:getAllEntity()
  local tab = {}
  for _, obj in pairs(entityList) do
    if obj.isPlayer and obj.objID ~= Me.objID then
      tab[obj.objID] = obj
    end
  end
  return tab
end

function M:initRadar()
  if self.radarTimer then
    LuaTimer:cancel(self.radarTimer)
    self.radarTimer = nil
  end
  self.radarTimer = LuaTimer:scheduleTimer(function()
    if not self.isInBattle then
      return true
    end
    local enemyDict = self:getAllEntity()
    if enemyDict then
      local distance, enemyPosition, myPosition, enemyYaw, radarDistance, image, x, y
      for i, enemy in pairs(enemyDict) do
        distance = getPosDistance2D(Me:getPosition(), enemy:getPosition())
        if enemy and enemy:getPosition() then
          enemyPosition, myPosition = enemy:getPosition(), Me:getPosition()
          radarDistance = math.min(distance / maxDistance, 1) * radarRadius
          local oX = RootW / 2
          local oY = RootH / 2
          local vector = v3cut(enemyPosition, myPosition)
          local normal = Lib.v3normalize(vector)
          local point = Lib.v3multip(normal, radarDistance)
          local pointOff = pointWidth / 2
          x = oX - point.x - pointOff
          y = oY - point.z - pointOff
          if not self.enemyPoints[i] then
            image = UI:createStaticImage("StaticImage" .. i)
            image:setImage(pointFile)
            image:setVisible(true)
            image:setSize(UDim2.new(0, pointWidth, 0, pointWidth))
            self.imgRadarImg:addChild(image)
            self.enemyPoints[i] = {img = image}
          end
          self.enemyPoints[i].visit = true
          image = self.enemyPoints[i].img
          local str = string.format("{{0,%f},{0,%f}}", x, y)
          image:setProperty("Position", str)
        end
      end
      if Me.dropData then
        local inDrop
        local mePos = Me:getPosition()
        for _, data in ipairs(Me.dropData) do
          local i = data.objID
          distance = getPosDistance2D(mePos, data.pos)
          enemyPosition, myPosition = data.pos, Me:getPosition()
          radarDistance = math.min(distance / maxDistance, 1) * radarRadius
          local oX = RootW / 2
          local oY = RootH / 2
          local vector = v3cut(enemyPosition, myPosition)
          local normal = Lib.v3normalize(vector)
          local point = Lib.v3multip(normal, radarDistance)
          local pointOff = pointWidth / 2
          x = oX - point.x - pointOff
          y = oY - point.z - pointOff
          if not self.dropPoints[i] then
            image = UI:createStaticImage("StaticImage" .. i)
            image:setImage(dropFile)
            image:setVisible(true)
            image:setSize(UDim2.new(0, 8, 0, 8))
            self.imgRadarImg:addChild(image)
            self.dropPoints[i] = {img = image}
          end
          self.dropPoints[i].visit = true
          image = self.dropPoints[i].img
          local str = string.format("{{0,%f},{0,%f}}", x, y)
          image:setProperty("Position", str)
        end
      end
    end
  end, displayRefreshTime)
end

local rotationV3 = {
  x = 0,
  y = 0,
  z = 1
}

local function rotationToQuaternion(v3, rotation)
  local halfRotation = 0.5 * rotation
  local halfSin = math.sin(halfRotation)
  return {
    w = math.cos(halfRotation),
    x = v3.x * halfSin,
    y = v3.y * halfSin,
    z = v3.z * halfSin
  }
end

function M:initOrientation()
  self.orientationTimer = LuaTimer:scheduleTimer(function()
    local initFightPosYaw = -180
    local visualYaw = Me:getRotationYaw() - (initFightPosYaw or 0)
    local leftQ = rotationToQuaternion(rotationV3, math.rad(visualYaw))
    self.imgSectorImg:setProperty("Rotation", "w:" .. leftQ.w .. " x:" .. leftQ.x .. " y:" .. leftQ.y .. " z:" .. leftQ.z)
  end, orientationRefreshTime)
end

function M:clearRadar()
  for i, point in pairs(self.enemyPoints) do
    if not World.CurWorld:getObject(i) then
      self.imgRadarImg:removeChild(point.img)
      self.enemyPoints[i] = nil
    end
  end
end

function M:showKillIcon()
  if self.skillIconTimer then
    self.skillTextTimer()
  end
  print("self.pkWindow.killImage true")
  self.pkWindow.killImage:setVisible(true)
  self.skillIconTimer = Me:timer(40, function()
    self.pkWindow.killImage:setVisible(false)
  end)
end

function M:showKillText(text)
  if self.skillTextTimer then
    self.skillTextTimer()
  end
  print("self.pkWindow.texttttt true")
  self.pkWindow.killText:setText(text)
  self.pkWindow.killText:setVisible(true)
  self.skillTextTimer = Me:timer(40, function()
    self.pkWindow.killText:setVisible(false)
  end)
end
