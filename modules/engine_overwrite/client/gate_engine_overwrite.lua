local main = {}
local tickEngineHandler = L("tickEngineHandler", handle_tick)

function handle_tick(frameTime)
  tickEngineHandler(frameTime)
end

function main:init()
  self:initLog()
  self:setGlobalProperty()
  CGame.instance:toggleDebugMessageShown(false)
  self:initGlobalEvent()
end

function main:setGlobalProperty()
  GlobalProperty.Instance():setBoolProperty("DebugSound", false)
  GlobalProperty.Instance():setBoolProperty("DisableCheckBlockTouch", true)
end

function main:initLog()
  Lib.setDebugLog(CGame.Instance():isDebuging())
end

function main:initGlobalEvent()
  Lib.subscribeKeyDownEvent("key.pull", function()
    local pos = Me:getPosition()
    local str = string.format("%.2f,%.2f,%.2f,%.2f", pos.x, pos.y, pos.z, Blockman.instance:viewerRenderYaw())
    PlatformUtil.copyToClipboard(str, string.len(str))
    print("PlatformUtil.copyToClipboard " .. str)
  end)
  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_PAUSE", Event.EVENT_GAME_PAUSE, function()
    if Me.stopGameBgm then
      Player.CurPlayer:stopGameBgm()
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_RESUME", Event.EVENT_GAME_RESUME, function()
    if Me.playGameBgm then
      Player.CurPlayer:playGameBgm()
    end
  end)
end

main:init()
