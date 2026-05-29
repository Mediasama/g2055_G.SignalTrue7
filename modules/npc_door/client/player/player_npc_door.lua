local PlayerNpcDoorClient = Player

function PlayerNpcDoorClient:ndp_C2S_RequestHackNpcDoor(param, resp)
  param.pid = "ndp_C2S_RequestHackNpcDoor"
  self:sendPacket(param, resp)
end

function PlayerNpcDoorClient:ndp_ShowHackDoorUI(param)
  if Lib.isDebugCloseUI() then
    return
  end
  local objID = param.objID or 0
  local triggerParam = param.triggerParam or {}
  local door = World.CurWorld:getObject(objID)
  if not door or not door:isValid() then
    return false
  end
  local doorId = door:ndp_getID()
  if not doorId then
    return
  end
  local doorConfigID = door:ndp_getConfigID()
  if not doorConfigID then
    return
  end
  local windowKey = "npc_door_" .. doorId
  local sceneWindow = UI:getSceneWindow(windowKey)
  if not sceneWindow then
    local offset = triggerParam.offset or Vector3.new(0, 0, 0)
    local width = triggerParam.width or 3
    local height = triggerParam.height or 3
    local parentRotation = Vector3.new(-door:getRotationPitch(), -door:getRotationYaw(), -door:getRotationRoll())
    Lib.rotate(offset, parentRotation)
    local position = door:getPosition() + offset
    local sceneArgs = {
      position = position,
      rotation = {
        0,
        0,
        0
      },
      width = width,
      height = height,
      isCullBack = false,
      objID = -1,
      flags = 4
    }
    local openParam = {objID = objID}
    local windowName = "./UI/bastion/win_bastion_npc_door_hack_icon"
    local sceneWnd, wnd = UI:openNewCustomSceneWindow(windowName, windowKey, sceneArgs, openParam)
    sceneWindow = sceneWnd
  end
end

function PlayerNpcDoorClient:ndp_CloseHackDoorUI(param)
  local objID = param.objID or 0
  local triggerParam = param.triggerParam or {}
  local door = World.CurWorld:getObject(objID)
  if not door or not door:isValid() then
    return false
  end
  local doorId = door:ndp_getID()
  if not doorId then
    return
  end
  local windowKey = "npc_door_" .. doorId
  UI:closeSceneWindow(windowKey)
end
