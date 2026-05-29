local GridViewHelper = Lib.class("GridViewHelper")

function GridViewHelper:ctor(data)
  self:initGv(data)
end

function GridViewHelper:initGv(data)
  self.gv = UIMgr:new_widget("grid_view")
  self.gv:SetMoveAble(data.moveAble)
  self.gv:SetvScorllMoveAble(data.vScorllMoveAble)
  self.gv:SethScorllMoveAble(data.hScorllMoveAble)
  self.gv:InitConfig(data.xDis or 0, data.yDis or 0, data.xCellNum or 1)
  self.gv:SetArea(data.area[1], data.area[2], data.area[3], data.area[4])
  self.gv:SetAutoColumnCount(data.autoColumnCount)
  data.gvParent:AddChildWindow(self.gv)
  self.adapter = UIMgr:new_adapter("common", data.widgetWidth, data.widgetHeight, data.widgetName, data.widgetJson)
  self.gv:invoke("setAdapter", self.adapter)
  self.cellSelectedCb = data.cellSelectedCb
  self.dataList = {}
end

function GridViewHelper:cellClickedCb(index, dx, dy)
  if self.curIndex == index and not self.enableRepeatClick then
    return false
  end
  self.preIndex = self.curIndex
  if self.preIndex and self.dataList[self.preIndex] then
    self.dataList[self.preIndex].select = false
  end
  self.curIndex = index
  if self.preIndex == nil then
    self.preIndex = self.curIndex
  end
  self.dataList[self.curIndex].select = true
  self.adapter:setData(self.dataList)
  if self.dataList[index] and self.cellSelectedCb then
    self.cellSelectedCb(self.dataList[index].data, dx, dy, index)
  end
  return true
end

function GridViewHelper:setData(data, initTabIndex, eliminateCb, enableRepeatClick)
  local index = 1
  self.enableRepeatClick = enableRepeatClick or false
  self.dataList = {}
  if eliminateCb then
    for k, v in pairs(data) do
      if eliminateCb(v) then
        local cbIndex = index
        self.dataList[index] = {
          data = v,
          select = false,
          clickCb = function(_, dx, dy)
            if self.cellSelectedCb then
              self:cellClickedCb(cbIndex, dx, dy)
            end
          end,
          index = index
        }
        index = index + 1
      end
    end
  else
    for k, v in pairs(data) do
      local cbIndex = index
      self.dataList[index] = {
        data = v,
        select = false,
        clickCb = function(_, dx, dy)
          if self.cellClickedCb then
            self:cellClickedCb(cbIndex, dx, dy)
          end
        end,
        index = index
      }
      index = index + 1
    end
  end
  self.adapter:setData(self.dataList)
  if initTabIndex == -1 then
    return
  end
  if initTabIndex and self.dataList[initTabIndex] then
    self.curIndex = nil
    self.preIndex = nil
    self:cellClickedCb(initTabIndex)
    return
  end
  if self.curIndex and self.dataList[initTabIndex] then
    self:cellClickedCb(self.curIndex)
    return
  end
  if self.dataList[1] then
    self:cellClickedCb(1)
  end
end

function GridViewHelper:setClickIndex(data)
  for i = 1, #self.dataList do
    if self.dataList[i].data == data then
      self:cellClickedCb(i)
      return
    end
  end
end

function GridViewHelper:getAdapter()
  return self.adapter
end

function GridViewHelper:getGridView()
  return self.gv
end

return GridViewHelper
