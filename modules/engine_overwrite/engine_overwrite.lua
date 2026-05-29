require("common.entity_engine_overwrite")
require("common.define_engine_overwrite")
require("common.instance_expand")
if World.isClient then
  require("client.entity.entity_prop_engine_overwrite")
  require("client.gate_engine_overwrite")
  require("client.ui.grid_view_helper")
  require("client.skill.skill_engine_overwrite")
  require("client.skill.melee_region_attack")
  require("client.skill.missile_attack")
  require("client.entity.entity_client_engine_overwrite")
else
  require("server.entity.entity_prop_engine_overwrite")
  require("server.player.player_engine_overwrite")
  require("server.async_process")
  require("server.gate_engine_overwrite")
end
local Pool = {}
local handlers = {}

function handlers.defaultSetting()
  return {
    settingKey = "engineOverwriteSetting"
  }
end

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    print("!!!!!!!!!!!!!!!!!!  handlers.ENTITY_ENTER(context),entity.isPlayer:", entity.objID, [[



]])
  else
  end
end

function handlers.ENTITY_LEAVE(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    entity:autoDataExpire()
  else
  end
end

function handlers.ENTITY_TOUCHDOWN(context)
  context.canDoDamage = false
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    entity:setMapPos(World.cfg.defaultMap, World.cfg.initPos)
  else
  end
end

function handlers.initAdapterView(params)
  local res = {}
  local GridViewHelper = _ENV.GridViewHelper
  if not params then
    return nil
  end
  res = GridViewHelper.new({
    xDis = params.xDis,
    yDis = params.yDis,
    xCellNum = params.xCellNum,
    area = {
      {0, 1},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    widgetWidth = params.widgetWidth,
    widgetHeight = params.widgetHeight,
    widgetJson = params.widgetJson,
    widgetName = params.widgetName,
    gvParent = params.gvParent,
    cellSelectedCb = params.cellSelectedCb
  })
  res:setData(params.dataList, -1, nil, true)
  return res
end

if World.isClient then
  local poolClass = require("client.pool.pool")
  
  function handlers.initPool(key, params)
    Pool[key] = poolClass.new(params)
  end
  
  function handlers.getObj(key)
    local pool = Pool[key]
    return pool:get()
  end
  
  function handlers.pushObj(key, ui)
    local pool = Pool[key]
    return pool:push(ui)
  end
  
  function handlers.showGM()
    local window = UI:openWnd("gm")
    window:root():SetLevel(1)
  end
  
  local function toBigNum(num)
    if not num then
      return 0
    end
    num = tostring(math.floor(num or 0))
    local ans = string.reverse(num)
    local res = ""
    for i = 1, #ans do
      res = res .. string.sub(ans, i, i)
      if i % 3 == 0 and i ~= #ans then
        res = res .. ","
      end
    end
    local ans = string.reverse(res)
    return ans
  end
  
  function handlers.toBigIntegerString(num)
    return toBigNum(num)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
