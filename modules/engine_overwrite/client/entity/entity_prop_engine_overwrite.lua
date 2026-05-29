function Entity.EntityProp:hideActor(value, add, cfg, id)
  if add then
    self:setEntityHide(true)
  else
    self:setEntityHide(false)
  end
end

local function resetActionMapQueue(entity, buff_id, skinQueue)
  for i = #skinQueue, 1, -1 do
    local skinData = skinQueue[i]
    if skinData and skinData.buff_id == buff_id then
      table.remove(skinQueue, i)
      break
    end
  end
  return (0 < #skinQueue and skinQueue[#skinQueue] or {}).value
end

function Entity.EntityProp:actionMap(value, add, buff)
  local buff_id = buff.id
  if not self.actionMapQueue then
    self.actionMapQueue = {}
  end
  if add then
    for src, dst in pairs(value) do
      self:setActionMapping(src, dst)
    end
    table.insert(self.actionMapQueue, {value = value, buff_id = buff_id})
  else
    for src, dst in pairs(value) do
      self:removeActionMapping(src)
    end
    local reset = resetActionMapQueue(self, buff_id, self.actionMapQueue)
    for src, dst in pairs(reset or {}) do
      self:setActionMapping(src, dst)
    end
  end
end

function Entity.EntityProp:effects(value, add, buff)
  for index, effect in pairs(value) do
    local name = string.format("buff_%d_%d_%d", self.objID, buff.id, index)
    if add then
      self:showEffect(effect, buff.cfg, name)
    else
      self:delEffect(name, effect.smoothRemove)
    end
  end
end

function Entity.EntityProp:buffAction(value, add, buff)
  if not value.isClient then
    return
  end
  local actionData
  if add then
    actionData = value.startAction
  else
    actionData = value.endAction
  end
  if actionData then
    local actionName = actionData.actionName
    local time = actionData.time or -1
    if actionName and actionName ~= "" then
      self:updateUpperAction(actionName, time)
    end
  end
end

function Entity.EntityProp:lockBodyRotation(value, add, buff)
  if add then
    Blockman.Instance().gameSettings:setLockBodyRotation(value)
  else
    Blockman.Instance().gameSettings:setLockBodyRotation(not value)
  end
end

function Entity.EntityProp:actorAlpha(value, add, cfg, id)
  if add then
    self:setAlpha(value)
  else
    self:setAlpha(1)
  end
end
