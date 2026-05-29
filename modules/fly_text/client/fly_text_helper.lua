local FlyTextHelper = T(Lib, "FlyTextHelper")
local WordSetting = {}
local FlyTaskList = {}
local FlyTextType = {UI = 1, Entity = 2}

local function getUITextListAndImage(text, atlas)
  local setting = WordSetting[atlas]
  if not setting then
    return {}, {}
  end
  local textList = {}
  local word = ""
  for i = 1, #text do
    word = word .. text:sub(i, i)
    if Lib.tableContain(setting.words, word) then
      if setting.folder then
        table.insert(textList, Lib.combinePath(setting.folder, word .. ".png"))
      else
        table.insert(textList, word)
      end
      word = ""
    end
  end
  return textList, setting
end

function FlyTextHelper:getUITextListAndImage(text, atlas)
  return getUITextListAndImage(text, atlas)
end

function FlyTextHelper:broadcastUIFlyText(text, atlas, scale)
  local packet = {
    pid = "onShowFlyText",
    type = FlyTextType.UI,
    atlas = atlas,
    text = text,
    scale = scale
  }
  WorldServer.BroadcastPacket(packet)
end

function FlyTextHelper:onShowUIFlyTextAnim(image, startPosX, startPosY, scale, duration)
  local setting = World.cfg.BloodTipsSetting
  local offsetX, offsetY = setting.offsetX, setting.offsetY
  local x = math.random(1, 2) == 1 and -offsetX or offsetX
  local endPosX, endPosY = startPosX + x, startPosY + offsetY
  local ticks = setting.time
  local scaleTick = setting.scaleTime
  local curScale = setting.beginScale
  local scalePerTicks = (scale - curScale) / scaleTick
  local offsetPosX = (endPosX - startPosX) / ticks
  local offsetPosY = (endPosY - startPosY) / ticks
  local times = 0
  image:setScale(curScale)
  image:setPosition(UDim2.new(0, startPosX, 0, startPosY))
  FlyTaskList[tostring(image)] = function()
    startPosX = startPosX + offsetPosX
    startPosY = startPosY + offsetPosY
    image:setPosition(UDim2.new(0, startPosX, 0, startPosY))
    if times < scaleTick then
      curScale = curScale + scalePerTicks
      image:setScale(curScale)
    else
      curScale = curScale - scalePerTicks
      image:setScale(curScale)
    end
    times = times + 1
    if times >= ticks then
      self.parentWin:removeChild(image)
    end
    return times < ticks
  end
end

function FlyTextHelper:onShowUIFlyText(target, text, scale)
  if World.isClient then
    if not self.parentWin then
      self.parentWin = Me.mainUIWin
    end
    scale = scale or 1
    local numberItem = UI:openWidget("./UI/main/fly_number")
    numberItem:makeTextUIGrid(text)
    self.parentWin:addChild(numberItem)
    self:onShowUIFlyTextAnim(numberItem, 640.0, 350.0, scale)
  else
    local packet = {
      pid = "onShowFlyText",
      type = FlyTextType.UI,
      text = text,
      scale = scale
    }
    target:sendPacket(packet)
  end
end

function FlyTextHelper:onShowEntityFlyTextAnim(fromEntity, setting, textList, scale)
  local startPos = fromEntity:getEyePos()
  local offset = setting.offset or Lib.v3(0.5, 1, 0.5)
  offset = Lib.tov3(offset) * scale
  local x = math.random(1, 2) == 1 and -offset.x or offset.x
  local endPos = startPos + Lib.v3(x, offset.y, x)
  local ticks = setting.duration or 20
  local offsetPos = (endPos - startPos) / ticks
  local image = WorldImageRender.Instance():addWorldImage(textList, startPos, scale, -1)
  local times = 0
  FlyTaskList[tostring(image)] = function()
    startPos = startPos + offsetPos
    image.position = startPos
    times = times + 1
    if times >= ticks then
      image.duration = 0
    end
    return times < ticks
  end
end

function FlyTextHelper:onShowEntityDynamicFlyTextAnim(fromEntity, setting, textList, scale)
  local startPos = fromEntity:getEyePos()
  local offset = setting.offset or Lib.v3(0.5, 1, 0.5)
  offset = Lib.tov3(offset) * scale
  local x = math.random(1, 2) == 1 and -offset.x or offset.x
  local endPos = startPos + Lib.v3(x, offset.y, x)
  local ticks = (setting.stableDuration or 5) + (setting.reduceDuration or 0) + (setting.enlargeDuration or 5)
  local offsetPos = (endPos - startPos) / ticks
  local image = WorldImageRender.Instance():addWorldImage(textList, startPos, scale, -1)
  local times = 0
  image.scale = 0
  FlyTaskList[tostring(image)] = function()
    startPos = startPos + offsetPos
    image.position = startPos
    if times <= (setting.enlargeDuration or 5) then
      image.scale = image.scale + (setting.enlargeSpeed or 0.5)
    elseif times > (setting.stableDuration or 5) + (setting.enlargeDuration or 5) then
      image.scale = image.scale - (setting.enlargeSpeed or 0.5)
    end
    times = times + 1
    if times >= ticks then
      image.duration = 0
    end
    return times < ticks
  end
end

function FlyTextHelper:onShowEntityFlyText(fromEntity, atlas, text, scale, isScaleDynamic)
  if not fromEntity:isValid() then
    return
  end
  if World.isClient then
    local textList, setting = getUITextListAndImage(text, atlas)
    if #textList == 0 then
      return
    end
    if setting.interval then
      local tickCount = World.CurWorld:getTickCount()
      local ticks = tickCount - (fromEntity.showFlyTextTick or 0)
      if ticks < setting.interval then
        World.LightTimer("FlyTextHelper:onShowEntityFlyText", ticks, function()
          FlyTextHelper:onShowEntityFlyText(fromEntity, atlas, text, scale, isScaleDynamic)
        end)
        return
      end
      fromEntity.showFlyTextTick = tickCount
    end
    scale = scale or setting.scale or 1
    if isScaleDynamic then
      FlyTextHelper:onShowEntityDynamicFlyTextAnim(fromEntity, setting, textList, scale)
    else
      FlyTextHelper:onShowEntityFlyTextAnim(fromEntity, setting, textList, scale)
    end
  else
    local packet = {
      pid = "onShowFlyText",
      fromObjID = fromEntity.objID,
      type = FlyTextType.Entity,
      atlas = atlas,
      text = text,
      scale = scale
    }
    fromEntity:sendPacketToTracking(packet, true)
  end
end

if not World.isClient then
  return
end
local handles = T(Player, "PackageHandlers")

function handles:onShowFlyText(packet)
  FlyTextHelper:onReceiveFlyText(packet)
end

function FlyTextHelper:onReceiveFlyText(packet)
  if packet.type == FlyTextType.UI then
    FlyTextHelper:onShowUIFlyText(Me, packet.atlas, packet.text, packet.scale)
  elseif packet.type == FlyTextType.Entity then
    local fromEntity = World.CurWorld:getEntity(packet.fromObjID)
    if fromEntity then
      FlyTextHelper:onShowEntityFlyText(fromEntity, packet.atlas, packet.text, packet.scale)
    end
  end
end

function FlyTextHelper:init()
  local folderRoot = World.cfg.fly_textSetting and World.cfg.fly_textSetting.path or "assert"
  local settings = World.cfg.fly_textSetting and World.cfg.fly_textSetting.img or Lib.readGameJson(folderRoot .. "/fly_text/setting.json")
  if not settings then
    folderRoot = "asset"
    settings = Lib.readGameJson(folderRoot .. "/fly_text/setting.json")
  end
  if not settings then
    folderRoot = "fly_text_number"
    settings = Lib.readGameJson(folderRoot .. "/fly_text/setting.json")
  end
  if not settings then
    Lib.logWarning("[Plugins]FlyTextHelper", Root.Instance():getGamePath() .. "assert/fly_text/setting.json is not exists.")
    return
  end
  local lfs = require("lfs")
  for _, setting in pairs(settings) do
    local atlas = setting.atlas or setting.folder
    WordSetting[atlas] = setting
    setting.words = {}
    if setting.folder then
      local path = Lib.combinePath(Root.Instance():getGamePath() .. folderRoot .. "/fly_text", setting.folder) .. "/"
      local attr = lfs.attributes(path)
      if not attr or attr.mode ~= "directory" then
        goto lbl_164
      end
      setting.folder = Lib.combinePath(folderRoot .. "/fly_text", setting.folder)
      for file in lfs.dir(path) do
        if file:find(".png") then
          local word = file:gsub(".png", "")
          table.insert(setting.words, word)
          TextureAtlasRegister.instance:addMemTextureAtlas("FlyText", Lib.combinePath(setting.folder, file))
        end
      end
    end
    if setting.imageSet then
      local result = Lib.readGameJson("resource/imageset/" .. setting.imageSet .. ".json")
      if result then
        for key, _ in pairs(result.frames) do
          table.insert(setting.words, key)
        end
      end
    end
    ::lbl_164::
  end
  World.LightTimer("FlyTextHelper:onTick", 1, function()
    return FlyTextHelper:onTick()
  end)
end

function FlyTextHelper:onTick()
  for key, task in pairs(FlyTaskList) do
    if not task() then
      FlyTaskList[key] = nil
    end
  end
  return true
end

FlyTextHelper:init()
