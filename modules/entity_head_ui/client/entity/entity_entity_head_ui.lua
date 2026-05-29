local Entity = _ENV.Entity
local headUICfg = {
  UI = "./UI/entity_head_ui/win_entity_head_ui",
  sceneUICfg = {
    position = {
      x = 0,
      y = 1.8,
      z = 0
    },
    rotation = {
      x = 0,
      y = 0,
      z = 0
    },
    width = 5,
    height = 5,
    flags = 4
  }
}
local viewPreStr = "entityHeadUI"

function Entity:getEntityHeadUIData()
  return self:getValue("entityHeadUI")
end

function Entity:openSceneWindow()
  if Lib.isDebugCloseUI() then
    return
  end
  local cfg = self:cfg().headUICfg or headUICfg
  local objID = self.objID
  local windowKey = viewPreStr .. tostring(objID)
  local sceneWindow = UI:getSceneWindow(windowKey)
  if not sceneWindow then
    local object = World.CurWorld:getObject(objID)
    if not object or not object:isValid() then
      return false
    end
    local position = cfg.sceneUICfg.position or headUICfg.sceneUICfg.position
    local rotation = cfg.sceneUICfg.rotation or headUICfg.sceneUICfg.rotation
    local width = cfg.sceneUICfg.width or headUICfg.sceneUICfg.width
    local height = cfg.sceneUICfg.height or headUICfg.sceneUICfg.height
    local sceneArgs = {
      position = position,
      rotation = rotation,
      width = width,
      height = height,
      isCullBack = false,
      objID = objID,
      flags = cfg.sceneUICfg.flags or headUICfg.sceneUICfg.flags
    }
    local openParam = {
      objID = objID,
      isPlayer = self.isPlayer,
      hurtSelf = self:getValue("autoHurtSelf")
    }
    local windowName = cfg.UI or headUICfg.UI
    local sceneWnd, wnd = UI:openNewCustomSceneWindow(windowName, windowKey, sceneArgs, openParam)
    sceneWindow = sceneWnd
    self.headUIWnd = {windowKey = windowKey, wnd = wnd}
  end
end

function Entity:updateEntityHeadUI(data)
  local value = data or self:getEntityHeadUIData()
  local showMe = not value.showSelf and self.objID == Me.objID
  local notShowContents = (not value.name or not value.name.visible) and (not value.progress or not value.progress.visible)
  if value == nil or showMe or notShowContents then
    self:hideEntityHeadUI()
    return
  end
  if self.headUIWnd == nil or self.headUIWnd.wnd == nil then
    self:openSceneWindow()
  end
  if self.headUIWnd and self.headUIWnd.wnd then
    local result = self.headUIWnd.wnd:onDataChanged(value)
    if not result then
      self:hideEntityHeadUI()
    end
  end
end

function Entity:hideEntityHeadUI()
  if self.headUIWnd and self.headUIWnd.windowKey then
    self.headUIWnd.wnd:onClose()
    UI:closeSceneWindow(self.headUIWnd.windowKey)
  end
  self.headUIWnd = nil
end
