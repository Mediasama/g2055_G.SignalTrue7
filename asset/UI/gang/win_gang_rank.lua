local widget_virtual_horz_list = require("ui.widget.widget_virtual_horz_list")

function M:init()
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.btnClose = self:child("ButtonClose")
  self:child("TextTitleGangName"):setText(Lang:toText("gang.rank.title.name"))
  self:child("TextTitleGangArea"):setText(Lang:toText("gang.rank.title.area"))
  self:child("TextTitleGangTime"):setText(Lang:toText("gang.rank.title.time"))
  self.textGangName = self:child("TextGangName")
  self.textGangTime = self:child("TextGangTime")
  self.panelTouch = self:child("PanelTouch")
  self.isHide = false
  local scrollView = self:child("ScrollableView")
  self.areaIconList = widget_virtual_horz_list:init(scrollView, scrollView.HorizontalLayout, function(self, parentWindow)
    local item = UI:openWidget("./UI/gang/widget_gang_rank_icon")
    parentWindow:addChild(item:getWindow())
    return item
  end, function(self, childWindow, data)
    childWindow:initData(data)
  end)
end

function M:initEvent()
  function self.panelTouch.onMouseClick()
    self.isHide = not self.isHide
    
    self:setYPosition({
      0,
      self.isHide and -(self:getPixelSize().height - 37) or 0
    })
  end
  
  Lib.subscribeEvent(Event.EVENT_TOP_GANG_UPDATE, function(data)
    self:setData(data)
  end)
end

function M:setData(data)
  self.data = data
  self.textGangName:setText(Lang:toText("gang.rank.title.noGang"))
  self.areaIconList:clearVirtualChild()
  if data then
    self.textGangName:setText(data.gangName)
    for k, _ in pairs(data.territoryList) do
      self.areaIconList:addVirtualChild({id = k})
    end
    self.topGangStamp = data.time
    if not self.gangTimer then
      self.gangTimer = World.Timer(20, function()
        if self.data then
          local t = math.max(os.time() - self.topGangStamp)
          self.textGangTime:setText(os.date("!%H:%M:%S", t))
        else
          self.textGangTime:setText("")
        end
        return true
      end)
    end
  else
    self.data = nil
    self.textGangTime:setText("")
  end
end

M:init()
