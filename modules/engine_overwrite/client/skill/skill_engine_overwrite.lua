function Skill.getSkill(name)
  local player = Player.CurPlayer
  
  local cfg = Skill.Cfg(name)
  local from
  local tb = player:data("skill").skillMap and player:data("skill").skillMap[name] or {}
  local objID = tb and tb.objID
  if objID then
    from = World.CurWorld:getEntity(objID)
  else
    from = player
  end
  return cfg, from
end

function Skill.ClickCast(packet)
  do return end
  if not Skill.canUseSkill(Player.CurPlayer) then
    return
  end
  if Me.weapon:isMelee() then
    if Me:checkIsState(Define.CHARACTER_STATE_TYPE.CARRY) then
      local msg = Lang:toText("weapon.carry.cant.use")
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", msg)
      return
    end
    Me:changeState(Define.CHARACTER_STATE_TYPE.SKILL, {packet = packet})
  end
end

function Skill.onCast(packet)
end

function Skill.TouchBegin(packet)
  do return end
  if Me.weapon:isMelee() then
    if Me:checkIsState(Define.CHARACTER_STATE_TYPE.CARRY) then
      return
    end
    Me:changeState(Define.CHARACTER_STATE_TYPE.SKILL, {packet = packet})
  end
end

function Skill.Cast(cfg, from, packet)
  print("Skill.Cast")
  if not Skill.canUseSkill(from) then
    return
  end
  packet = packet or {}
  if cfg:canCast(packet, from) then
    local action = cfg.action
    local len = #action
    local index = math.random(1, len)
    local actionName = action[index]
    cfg.castAction = actionName
    cfg:preSwing(packet, from)
  else
    print("Skill.Cast  cfg:canCast false ")
    return false
  end
  return cfg
end

function Skill.canUseSkill(player)
  if player and player.isPlayer and player:isValid() then
    return not player:isDriving()
  end
  return false
end
