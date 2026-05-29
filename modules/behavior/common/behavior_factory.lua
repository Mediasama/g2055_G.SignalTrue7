local BehaviorShowLog = require("common.behavior_show_log")
local BehaviorOperateBastionFacility = require("common.behavior_operate_bastion_facility")
local BehaviorOperateBastionDefense = require("common.behavior_operate_bastion_defense")
local BehaviorOperateBastionPark = require("common.behavior_operate_bastion_park")
local BehaviorOperateTerritoryOccupy = require("common.behavior_operate_territory_occupy")
local BehaviorOperateArea = require("common.behavior_operate_area")
local BehaviorOperateTattoo = require("common.behavior_operate_tattoo")
local BehaviorTriggerGoodsShelf = require("common.behavior_trigger_goods_shelf")
local BehaviorChangeBGM = require("common.behavior_change_bgm")
local BehaviorOperateNpcDoor = require("common.behavior_operate_npc_door")
local BehaviorFactory = Lib.class("BehaviorFactory")
local _instance

function BehaviorFactory.Instance()
  if _instance == nil then
    _instance = BehaviorFactory.new()
    _instance:init()
  end
  return _instance
end

function BehaviorFactory:ctor()
  self._creatorDict = {}
end

function BehaviorFactory:destroy()
end

function BehaviorFactory:init()
  self:registerCreator(Define.Behavior.Type.ShowLog, BehaviorShowLog)
  self:registerCreator(Define.Behavior.Type.OperateBastionFacility, BehaviorOperateBastionFacility)
  self:registerCreator(Define.Behavior.Type.OperateBastionDefense, BehaviorOperateBastionDefense)
  self:registerCreator(Define.Behavior.Type.OperateBastionPark, BehaviorOperateBastionPark)
  self:registerCreator(Define.Behavior.Type.OperateTerritoryOccupy, BehaviorOperateTerritoryOccupy)
  self:registerCreator(Define.Behavior.Type.OperateArea, BehaviorOperateArea)
  self:registerCreator(Define.Behavior.Type.OperateTattoo, BehaviorOperateTattoo)
  self:registerCreator(Define.Behavior.Type.TriggerGoodsShelf, BehaviorTriggerGoodsShelf)
  self:registerCreator(Define.Behavior.Type.ChangeBGM, BehaviorChangeBGM)
  self:registerCreator(Define.Behavior.Type.OperateNpcDoor, BehaviorOperateNpcDoor)
end

function BehaviorFactory:registerCreator(type, class)
  self._creatorDict[type] = class
end

function BehaviorFactory:getCreator(type)
  return self._creatorDict[type]
end

function BehaviorFactory:create(param)
  local instance
  if not param then
    return instance
  end
  local type = param.type
  if not type then
    return instance
  end
  local creator = self:getCreator(type)
  if not creator then
    return instance
  end
  instance = creator.new(param)
  return instance
end

return BehaviorFactory
