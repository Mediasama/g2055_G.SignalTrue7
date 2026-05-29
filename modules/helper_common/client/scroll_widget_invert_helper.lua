local ScrollWidgetHelper = require("modules.helper_common.client.scroll_widget_helper")
local ScrollWidgetInvertHelper = Lib.class("ScrollWidgetInvertHelper", ScrollWidgetHelper)

function ScrollWidgetInvertHelper:ctor(data)
  ScrollWidgetHelper.ctor(self, data)
end

function ScrollWidgetInvertHelper:onItemClick(itemIndex, itemData)
  if itemIndex == self.currentSelectIndex then
    self.dataList[itemIndex].selected = not self.dataList[itemIndex].selected
  else
    self.dataList[self.currentSelectIndex].selected = false
    self.dataList[itemIndex].selected = true
  end
  self.currentSelectIndex = itemIndex
  if self.selectedCallBack then
    self.selectedCallBack(self.dataList[self.currentSelectIndex].data)
  end
end

return ScrollWidgetInvertHelper
