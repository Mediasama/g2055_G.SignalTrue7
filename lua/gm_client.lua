local GMItem = GM:createGMItem()
local Cinemachine = T(Lib, "LuaCinemachine")
local camerasCreated = false

local function checkCreateCameras()
  if camerasCreated then
    return
  end
  camerasCreated = true
  Cinemachine:createCamera("normal", {
    follow = Me,
    lookAt = Me,
    body = {
      type = "FocusRound",
      offset = {
        3,
        1.5,
        0
      },
      distance = 10,
      distanceRange = {0.3, 100}
    },
    aim = {type = "POV"},
    avoider = {type = "ZoomIn"},
    noise = {
      type = "SimpleSmooth",
      rotRadianRange = math.pi / 180 * 3,
      rotInterval = 0.05
    }
  })
  Cinemachine:enableNoise("normal", false)
  Cinemachine:createCamera("zoomIn", {
    follow = Me,
    lookAt = Me,
    body = {
      type = "FocusRound",
      offset = {
        3,
        1.5,
        0
      },
      distance = 0,
      distanceRange = {0, 0}
    },
    aim = {type = "POV"}
  })
  Cinemachine:createCamera("die", {
    follow = Me,
    lookAt = Me,
    body = {
      type = "HardLockToTarget",
      offset = {
        0,
        15,
        0
      },
      localspace = false
    },
    aim = {type = "HardLookAt"},
    avoider = {type = "ZoomIn"}
  })
end

GMItem["\233\149\156\229\164\180/\229\184\184\232\167\132"] = function()
  Blockman.instance.gameSettings:setLutTextureName("")
  checkCreateCameras()
  Cinemachine:blendTo("normal", 0)
  Cinemachine:enableNoise("normal", false)
end
GMItem["\233\149\156\229\164\180/\230\173\187\228\186\161"] = function()
  checkCreateCameras()
  Blockman.instance.gameSettings:setLutTextureName("lut_gray.png")
  Cinemachine:blendTo("normal", 0)
  Cinemachine:blendTo("die", 2)
  UI:closeWnd("gm")
end
GMItem["\233\149\156\229\164\180/\230\139\137\232\191\145"] = function()
  checkCreateCameras()
  Cinemachine:blendTo("zoomIn", 1)
  UI:closeWnd("gm")
end
GMItem["\233\149\156\229\164\180/\230\138\150\229\138\168"] = function()
  checkCreateCameras()
  Cinemachine:enableNoise("normal", true)
  UI:closeWnd("gm")
end

GMItem["Hacks/Fly Toggle"] = function()
    Me.isFly = not Me.isFly
    if Me.isFly then
        Me:setProp("gravity", 0)
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "Fly Mode: ON")
    else
        Me:setProp("gravity", 0.08)
        Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", "Fly Mode: OFF")
    end
end

GMItem["Hacks/Fly UP"] = function()
    local pos = Me:getPosition()
    pos.y = pos.y + 2
    Me:setPosition(pos)
end

GMItem["Hacks/Fly DOWN"] = function()
    local pos = Me:getPosition()
    pos.y = pos.y - 2
    Me:setPosition(pos)
end

GMItem["Hacks/Speed X5"] = function()
    Me:setProp("moveSpeed", 2) -- assuming default is lower
end

return GMItem
