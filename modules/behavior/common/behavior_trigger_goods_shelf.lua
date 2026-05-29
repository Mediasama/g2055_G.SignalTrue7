local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local BehaviorBase = require("common.behavior_base")
local BehaviorTriggerGoodsShelf = Lib.class("BehaviorTriggerGoodsShelf", BehaviorBase)

function BehaviorTriggerGoodsShelf:ctor(param)
  BehaviorBase.ctor(self, param)
  self._type = Define.Behavior.Type.TriggerGoodsShelf
end

function BehaviorTriggerGoodsShelf:start(startParam)
  if World.isClient then
    self:stop()
  else
    local curWorld = World.CurWorld
    local operatorLocator = startParam.operatorLocator
    local targetLocator = startParam.targetLocator
    local operator = curWorld:getUnit(operatorLocator)
    local target = curWorld:getUnit(targetLocator)
    if target and target:isValid() and operator and operator.isPlayer and operator:isValid() then
      local shelf = target
      local player = operator
      local param = self._createParam
      if player:isDriving() and param.operateType == Define.GoodsShelf.Trigger.Type.Open then
        return
      end
      local id = shelf:gsp_getID()
      local cfg = GoodsShelfConfig:getCfgById(id)
      if cfg == nil then
        return
      end
      if cfg.type == Define.GoodsShelf.Type.Bullet then
        if param.operateType == Define.GoodsShelf.Trigger.Type.Open then
          local weaponId = player:getCurWeaponID()
          if weaponId == nil then
            return
          else
            if param.triggerParam == nil then
              param.triggerParam = {}
            end
            param.triggerParam.weaponId = weaponId
            param.triggerParam.isCanFillBullet = player:isCanFillBullet(weaponId)
          end
        end
      elseif cfg.type == Define.GoodsShelf.Type.BlackMarket then
        player:bmc_reloadMarket(id)
      end
      local packetParam = {
        operateType = param.operateType or Define.GoodsShelf.Trigger.Type.None,
        id = id,
        objID = target.objID,
        triggerParam = param.triggerParam
      }
      player:S2C_TriggerGoodsShelf(packetParam)
    end
    self:stop()
  end
end

return BehaviorTriggerGoodsShelf
