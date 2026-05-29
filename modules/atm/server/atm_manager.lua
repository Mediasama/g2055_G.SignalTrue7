local ATMManager = T(Lib, "ATMManager")
local AtmConfig = T(Config, "AtmConfig")

function ATMManager:init()
  self.ATMList = {}
  local allcfg = AtmConfig:getAllCfgs()
  for _, v in pairs(allcfg) do
    local cfg = v
    local data = {
      cfgName = cfg.entityName,
      map = World.CurWorld:getMap(),
      pos = cfg.pos.position,
      ry = cfg.pos.rotation.y
    }
    local entity = EntityServer.Create(data)
    table.insert(self.ATMList, entity)
    entity:setATMState(Define.ATM_STATE.ST_NORMAL)
    entity:setATMCfgId(cfg.id)
    entity:setATMCurMoney(cfg.all_money)
    entity:setATMDropStamp(os.time())
    entity:setMaxHp(cfg.hp or 1)
  end
  self.ATMManagerTimer = World.Timer(20, function()
    self:update()
    return true
  end)
end

function ATMManager:update()
  for _, atm in pairs(self.ATMList) do
    if atm:getATMState() == Define.ATM_STATE.ST_DEAD then
      local cfg = AtmConfig:getCfgById(atm:getATMCfgId())
      if cfg and os.time() - atm:getATMDropStamp() >= cfg.cd then
        atm:ATMRevive()
      end
    elseif atm:getATMHurtStamp() > 0 then
      local setting = atm:cfg()
      if setting.ATMType == Define.ATM_TYPE.ATM then
        if os.time() - atm:getATMHurtStamp() > setting.RedEdgeTime then
          atm:setATMHurtStamp(0)
        end
      elseif setting.ATMType == Define.ATM_TYPE.ATM_NPC and os.time() - atm:getATMHurtStamp() > setting.ScareTime then
        atm:setATMHurtStamp(0)
        atm:playAMTAction(atm:cfg().action.idle)
      end
    end
  end
end

return ATMManager
