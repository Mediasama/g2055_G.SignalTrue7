Define.ScrollWidgetLayout = {
  Vert = 1,
  Hor = 2,
  Grid = 3
}
local scrollWidget = {
  [Define.ScrollWidgetLayout.Vert] = require("ui.widget.widget_virtual_vert_list"),
  [Define.ScrollWidgetLayout.Hor] = require("ui.widget.widget_virtual_horz_list"),
  [Define.ScrollWidgetLayout.Grid] = require("ui.widget.widget_virtual_grid")
}
local ScrollWidgetHelper = Lib.class("ScrollWidgetHelper")

function ScrollWidgetHelper:ctor(data)
  self:initScroll(data)
  self.dataList = nil
  self.currentSelectIndex = 1
end

function ScrollWidgetHelper:initScroll(data)
  local layout = data.layout
  local rowSize = data.rowSize
  local scrollableView = data.scrollableView
  local verticalLayout = data.verticalLayout
  local itemWidget = data.itemWidget
  local itemDataFuncName = data.itemDataFuncName
  self.selectedCallBack = data.selectedCallBack
  local class = scrollWidget[layout]
  if class then
    self.scrollView = class:init(scrollableView, verticalLayout, function(self, parentWindow)
      local item = UI:openWidget(itemWidget)
      parentWindow:addChild(item:getWindow())
      return item
    end, function(self, childWindow, msg)
      local func = childWindow[itemDataFuncName]
      if func and type(func) == "function" then
        func(childWindow, msg)
      end
    end, rowSize)
  end
end

function ScrollWidgetHelper:getScrollView()
  return self.scrollView
end

function ScrollWidgetHelper:itemClickCallBack(itemIndex, itemData)
  self:onItemClick(itemIndex, itemData)
  self:reloadData()
end

function ScrollWidgetHelper:onItemClick(itemIndex, itemData)
  self.dataList[self.currentSelectIndex].selected = false
  self.currentSelectIndex = itemIndex
  self.dataList[self.currentSelectIndex].selected = true
  if self.selectedCallBack then
    self.selectedCallBack(self.dataList[self.currentSelectIndex].data)
  end
end

function ScrollWidgetHelper:reloadData()
  self.scrollView:refresh(self.dataList)
end

function ScrollWidgetHelper:resetData(dataList)
  dataList = dataList or {}
  local dataListNew = {}
  local i = 1
  for k, v in pairs(dataList) do
    local itemIndex = i
    dataListNew[i] = {
      index = itemIndex,
      data = v,
      selected = false,
      itemClickCb = function(itemData)
        self:itemClickCallBack(itemIndex, itemData)
      end
    }
    i = i + 1
  end
  self.dataList = dataListNew
  self.currentSelectIndex = 1
  if dataListNew[self.currentSelectIndex] then
    dataListNew[self.currentSelectIndex].selected = true
  end
  self.scrollView:clearVirtualChild()
  self.scrollView:addVirtualChildList(dataListNew)
end

function ScrollWidgetHelper:clearScrollData()
  self.scrollView:clearVirtualChild()
end

return ScrollWidgetHelper
