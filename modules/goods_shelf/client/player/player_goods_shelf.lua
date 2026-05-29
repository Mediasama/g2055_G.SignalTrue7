local GoodsShelfTypeToIconUIDict = {}
GoodsShelfTypeToIconUIDict[Define.GoodsShelf.Type.Clothes] = "./UI/goods_shelf/win_goods_shelf_icon_clothes"
GoodsShelfTypeToIconUIDict[Define.GoodsShelf.Type.Cars] = "./UI/goods_shelf/win_goods_shelf_icon_car"
GoodsShelfTypeToIconUIDict[Define.GoodsShelf.Type.Weapons] = "./UI/goods_shelf/win_goods_shelf_icon_weapon"
GoodsShelfTypeToIconUIDict[Define.GoodsShelf.Type.BlackMarket] = "./UI/goods_shelf/win_goods_shelf_icon_black_market"
GoodsShelfTypeToIconUIDict[Define.GoodsShelf.Type.Bullet] = "./UI/goods_shelf/win_goods_shelf_icon_bullet"

local function getGoodsShelfIconUI(shelfType)
  return GoodsShelfTypeToIconUIDict[shelfType]
end

local GoodsShelfConfig = T(Config, "GoodsShelfConfig")
local PlayerGoodsShelfClient = Player

function PlayerGoodsShelfClient:showGoodsShelfIcon(objID, shelfID, triggerParam)
  if Lib.isDebugCloseUI() then
    return
  end
  local config = GoodsShelfConfig:getCfgById(shelfID)
  if not config then
    return
  end
  local shelfType = config.type
  local windowKey = shelfType .. tostring(shelfID)
  local sceneWindow = UI:getSceneWindow(windowKey)
  if not sceneWindow then
    local object = World.CurWorld:getObject(objID)
    if not object or not object:isValid() then
      return false
    end
    local offset = triggerParam.offset or Vector3.new(0, 0, 0)
    local width = triggerParam.width or 3
    local height = triggerParam.height or 3
    local parentRotation = Vector3.new(-object:getRotationPitch(), -object:getRotationYaw(), -object:getRotationRoll())
    Lib.rotate(offset, parentRotation)
    local position = object:getPosition() + offset
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
    local openParam = {}
    openParam.shelfType = shelfType
    openParam.shelfID = shelfID
    openParam.objID = objID
    openParam.triggerParam = triggerParam
    local windowName = getGoodsShelfIconUI(shelfType)
    local sceneWnd, wnd = UI:openNewCustomSceneWindow(windowName, windowKey, sceneArgs, openParam)
    Me:evt_reportWinOpen(windowKey)
    sceneWindow = sceneWnd
  end
end

function PlayerGoodsShelfClient:hideGoodsShelfIcon(objID, shelfID, triggerParam)
  local config = GoodsShelfConfig:getCfgById(shelfID)
  if not config then
    return
  end
  local shelfType = config.type
  local windowKey = shelfType .. tostring(shelfID)
  UI:closeSceneWindow(windowKey)
  Me:evt_reportWinClose(windowKey)
end

function PlayerGoodsShelfClient:C2S_RequestPurchaseGoods(param, resp)
  param.pid = "C2S_RequestPurchaseGoods"
  self:sendPacket(param, resp)
end
