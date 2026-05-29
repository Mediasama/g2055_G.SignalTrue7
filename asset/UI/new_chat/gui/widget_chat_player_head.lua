function M:init()
  self.detailInf = nil
  
  self.hasAction = true
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imageHead = self.PanelHead.ImageHead
  self.imageFrame = self.PanelHead.ImageFrame
  self.imageMale = self.PanelHead.ImageMale
  self.imageFemale = self.PanelHead.ImageFemale
  self.textLevel = self.PanelHead.ImageHead
  self.dialogBoxOffset = 50
  self.imageHead:setImage("set:default_icon.json image:header_icon")
end

function M:initEvent()
  function self.PanelHead.onMouseClick(instance, window, x, y)
    if self.hasAction and self.detailInf and self.detailInf.userId ~= Me.platformUserId then
      local box = Lib.openWindow("./UI/new_chat/gui/win_chat_player_dialog_box")
      
      local nodeX = CEGUICoordConverter.screenToWindowX1(box:getWindow(), x)
      local nodeY = CEGUICoordConverter.screenToWindowY1(box:getWindow(), y)
      box:setPanelPos(nodeX + self.dialogBoxOffset, nodeY)
      box:initData(self.detailInf)
    end
  end
end

function M:initData(detailInf)
  if detailInf then
    if detailInf.userId == nil then
      self.detailInf = nil
      Lib.logError("widget_chat_player_head:initData() error ! detailInf.userId==nil ")
      return
    end
    self.detailInf = detailInf
    self.imageMale:setVisible(detailInf.sex == 1)
    self.imageFemale:setVisible(detailInf.sex ~= 1)
    if detailInf.picUrl then
      self.imageHead:setImage(detailInf.picUrl)
    end
  end
end

M:init()
