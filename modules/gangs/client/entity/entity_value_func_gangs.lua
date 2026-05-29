local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:gangIconInfo(value)
  if self.isPlayer then
    self:resetHeadTextHeight()
    self:openPlayerHeadGangIcon()
    Lib.emitEvent(Event.EVENT_REFRESH_PLAYER_GANG_ICON, self.objID, value)
    if self.platformUserId == Me.platformUserId then
      self:updateOtherPlayerCircle()
    else
      self:updatePlayerCircle()
    end
  end
end

function Entity.ValueFunc:killPlayerDict(value)
  if self.isPlayer and self:checkPlayerKillMe(Me.platformUserId) then
    self:updatePlayerCircle()
  end
end

local viewPreStr = "PlayerHeadGangIcon"

function Entity:openPlayerHeadGangIcon()
  if Lib.isDebugCloseUI() then
    return
  end
  if self.objID == Me.objID then
    return
  end
  local windowKey = viewPreStr .. tostring(self.objID)
  local sceneWindow = UI:getSceneWindow(windowKey)
  if not sceneWindow then
    local object = World.CurWorld:getObject(self.objID)
    if not object or not object:isValid() then
      return false
    end
    local cfg = World.cfg.gangCfg.headUI
    local sceneArgs = {
      position = cfg.position,
      rotation = cfg.rotation,
      width = cfg.width,
      height = cfg.height,
      isCullBack = false,
      objID = self.objID,
      flags = cfg.flags
    }
    local openParam = {
      objID = self.objID
    }
    local windowName = "./UI/entity_head_ui/win_player_head"
    local sceneWnd, wnd = UI:openNewCustomSceneWindow(windowName, windowKey, sceneArgs, openParam)
    print("open win key=", windowKey)
    sceneWindow = sceneWnd
  end
end

function Entity:closePlayerHeadGangIcon()
  if self.isPlayer or self:cfg().isTrolley or self.getBastionDefenseType and self:getBastionDefenseType() == Define.Bastion.Defense.Type.Door then
    local windowKey = viewPreStr .. tostring(self.objID)
    UI:closeSceneWindow(windowKey)
  end
end
