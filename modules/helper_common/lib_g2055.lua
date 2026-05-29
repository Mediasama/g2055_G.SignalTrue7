local Lib = _ENV.Lib
local debugCloseUI = false

function Lib.switchDebugCloserUI()
  debugCloseUI = not debugCloseUI
end

function Lib.isDebugCloseUI()
  return debugCloseUI
end

function Lib.showScreenMask(visible)
  if Lib.isDebugCloseUI() then
    return
  end
  if visible then
    UI:openWindow("./UI/win_screen_touch_mask")
  else
    UI:closeWindow("./UI/win_screen_touch_mask")
  end
end

function Lib.openWindow(uiName, instanceName, resGroup, ...)
  if Lib.isDebugCloseUI() then
    return
  end
  Me:evt_reportWinOpen(uiName)
  return UI:openWindow(uiName, instanceName, resGroup, ...)
end

function Lib.closeWindow(uiName, ...)
  Me:evt_reportWinClose(uiName)
  UI:closeWindow(uiName, ...)
end

function Lib.showSceneUI(objID, viewPreStr, openParam, sceneArgs, windowName)
  if Lib.isDebugCloseUI() then
    return
  end
  if not objID then
    return
  end
  local windowKey = viewPreStr .. tostring(objID)
  local sceneWindow = UI:getSceneWindow(windowKey)
  if not sceneWindow then
    local object = World.CurWorld:getObject(objID)
    if not object or not object:isValid() then
      return false
    end
    local sceneWnd, wnd = UI:openNewCustomSceneWindow(windowName, windowKey, sceneArgs, openParam)
    sceneWindow = sceneWnd
    Me:evt_reportWinOpen(windowKey)
  end
end

function Lib.hideSceneUI(objID, viewPreStr)
  if not objID then
    return
  end
  local windowKey = viewPreStr .. tostring(objID)
  Me:evt_reportWinClose(windowKey)
  UI:closeSceneWindow(windowKey)
end

function Lib.getFaceDirect(entity)
  local dir = Lib.posAroundYaw({
    x = 0,
    y = 0,
    z = 1
  }, entity:getRotationYaw())
  return dir
end

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

function Lib.openDeathCamera(time)
  if time == nil then
    return
  end
  Cinemachine:enable(true)
  checkCreateCameras()
  Blockman.instance.gameSettings:setLutTextureName("lut_gray.png")
  Cinemachine:blendTo("normal", 0)
  World.Timer(10, function()
    Cinemachine:blendTo("die", time)
    return false
  end)
end

function Lib.resetDeathCamera()
  Blockman.instance.gameSettings:setLutTextureName("")
  Cinemachine:enable(false)
end
