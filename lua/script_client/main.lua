local old_handle_render_tick = handle_render_tick

function handle_render_tick(frameTime)
  old_handle_render_tick(frameTime)
  Lib.emitEvent(Event.EVENT_RENDER_TICK, frameTime)
  if Me.dropItems then
    for i, v in ipairs(Me.dropItems) do
      v:onUpdate(frameTime)
    end
  end
end

local main = {}

function main:init()
  self:initGlobalEvent()
end

local bgSound

function main:initGlobalEvent()
  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_PAUSE", Event.EVENT_GAME_PAUSE, function()
    Player.CurPlayer:stopGameBgm()
    bgSound = Me:stopBgm()
  end)
  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_RESUME", Event.EVENT_GAME_RESUME, function()
    Player.CurPlayer:playGameBgm()
    if bgSound then
      Me:playBgmByKey(bgSound)
    end
  end)
end

main:init()
