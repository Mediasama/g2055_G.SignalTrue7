local sin = math.sin
local cos = math.cos
local rad = math.rad
local ChatUIHelper = T(World, "ChatUIHelper")
local rotationV3 = {
  {
    x = 1,
    y = 0,
    z = 0
  },
  {
    x = 0,
    y = 1,
    z = 0
  },
  {
    x = 0,
    y = 0,
    z = 1
  }
}

local function rotationToQuaternion(v3, rotation)
  local halfRotation = 0.5 * rotation
  local halfSin = sin(halfRotation)
  return {
    w = cos(halfRotation),
    x = v3.x * halfSin,
    y = v3.y * halfSin,
    z = v3.z * halfSin
  }
end

function ChatUIHelper:setWidgetRotate(widget, angle, axis)
  if not widget or type(angle) ~= "number" or not rotationV3[axis] then
    print("ChatUIHelper:setWidgetRotate() error ", widget, angle, axis)
    return
  end
  local angle = rotationToQuaternion(rotationV3[axis], rad(angle))
  widget:setProperty("Rotation", "w:" .. angle.w .. " x:" .. angle.x .. " y:" .. angle.y .. " z:" .. angle.z)
end

function ChatUIHelper:getContentItemType(pageType)
  if pageType == Define.ChatPage.System then
    return Define.ChatMainContentType.SystemItem
  else
    return Define.ChatMainContentType.NormalItem
  end
end

function ChatUIHelper:openCardShop()
  UI:openWindow("./UI/new_chat/gui/win_chat_car_shop")
end
