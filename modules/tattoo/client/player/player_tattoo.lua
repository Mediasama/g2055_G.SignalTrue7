local Player = _ENV.Player
local viewPreStr = "Tattoo"

function Player:showTattooErrorTips(code)
  if code and Define.TattooPacketTips[code] then
    Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.TattooPacketTips[code]))
  end
end

function Player:requestTattoo(objID, tattooId, cb)
  self:sendPacket({
    pid = "onRequestTattoo",
    objID = objID,
    tattooId = tattooId
  }, function(result)
    if result then
      if result.code ~= Define.TattooPacketCode.Success then
        Me:showTattooErrorTips(result.code)
      end
      if cb then
        cb(result.code)
      end
    end
  end)
end

function Player:showTattooView(objID, data)
  local openParam = {data = data, objID = objID}
  local cfg = World.cfg.tattoo.headUI
  local position = cfg.position
  local sceneArgs = {
    position = position,
    rotation = cfg.rotation,
    width = cfg.width,
    height = cfg.height,
    isCullBack = false,
    objID = objID,
    flags = cfg.flags
  }
  local windowName = "./UI/tattoo/win_tattoo"
  Lib.showSceneUI(objID, viewPreStr, openParam, sceneArgs, windowName)
end

function Player:hideTattooView(objID)
  Lib.hideSceneUI(objID, viewPreStr)
end
