local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["g2055/\230\143\143\232\190\185"] = function(self)
  self:setEdge(true, {
    1,
    0,
    0,
    1
  })
end
GMItem["g2055/\229\142\187\230\143\143\232\190\185"] = function(self)
  self:setEdge(false, {
    1,
    0,
    0,
    1
  })
end
GMItem["g2055/\230\181\139\232\175\149\233\149\156\229\164\18011"] = function(self)
  local CameraManager = T(Lib, "CameraManager")
  CameraManager:freeViewEx()
end
GMItem["g2055/\230\181\139\232\175\149\233\149\156\229\164\18012"] = function(self)
  Me:setProp("calcYawBySpeedDir", 0)
  Me:sendPacket({
    pid = "ChangeViewMode",
    mode = 1
  })
  Blockman.instance.gameSettings:setLockBodyRotation(true)
  Camera.getActiveCamera():update()
end
GMItem["g2055/\230\181\139\232\175\149\233\149\156\229\164\18013"] = function(self)
  Me:setProp("calcYawBySpeedDir", 0)
  Me:sendPacket({
    pid = "ChangeViewMode",
    mode = 1
  })
  Blockman.instance.gameSettings:setLockBodyRotation(true)
end
GMItem["g2055/\230\181\139\232\175\149\233\149\156\229\164\18014"] = function(self)
  Me:setProp("calcYawBySpeedDir", 0)
  Me:sendPacket({
    pid = "ChangeViewMode",
    mode = 1
  })
end
GMItem["g2055/\230\181\139\232\175\149\233\149\156\229\164\18015"] = function(self)
  GlobalProperty.Instance():setFloatProperty("MaxYMotion", World.cfg.maxYMotion or -2.0)
  GlobalProperty.Instance():setBoolProperty("DisableThirdPersonCameraOffset", false)
end
