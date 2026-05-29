local PlayerSceneTriggersClient = Player

function PlayerSceneTriggersClient:stg_changeBGM(param)
  local bgm = param.bgm or ""
  Me:playBgmByKey(bgm)
end
