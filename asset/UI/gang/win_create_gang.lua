local GangIconConfig = T(Config, "GangIconConfig")
local scrollWidgetHelper = require("modules.helper_common.client.scroll_widget_helper")

function M:init()
  self.textPanelCreateGangTitle = self:child("TextPanelCreateGangTitle")
  self.textPanelCreateGangTitle:setText(Lang:toText("gang.title.gang.create.list"))
  self:child("ButtonCreateGang"):setText(Lang:toText("gang.button.create.gang"))
  self.editBoxGangName = self:child("EditBoxGangName")
  
  function self.editBoxGangName.onInputCaptureGained()
    local inputText = self.editBoxGangName:getText()
    if inputText == Lang:toText("gang.edit.box.default.tips") then
      self.editBoxGangName:setText("")
    end
  end
  
  local scrollHelper = scrollWidgetHelper.new({
    scrollableView = self:child("ScrollableViewGangIcon"),
    verticalLayout = self:child("VerticalLayoutGangIcon"),
    itemWidget = "./UI/gang/widget_gang_icon_item",
    itemDataFuncName = "onDataChanged",
    layout = Define.ScrollWidgetLayout.Hor,
    selectedCallBack = function(data)
      self:selectedCreateGangIconCallBack(data)
    end
  })
  scrollHelper:resetData(GangIconConfig:getAllCfgs())
  self:initButton()
  self:initData()
end

function M:initData()
  self.gangCreateIconId = 1
  self.editBoxGangName:setText(Lang:toText("gang.edit.box.default.tips"))
end

function M:initButton()
  self:child("ButtonCreateGang").onMouseClick = function()
    if self.editBoxGangName:getText() == Lang:toText("gang.edit.box.default.tips") or self.editBoxGangName:getText() == "" then
      Plugins.CallTargetPluginFunc("fly_text", "pushNormalFlyText", Lang:toText(Define.GangsPacketCodeToastTips[Define.GangsPacketCode.GangNameNull]))
      return
    end
    Me:createNewGang(self.gangCreateIconId, self.editBoxGangName:getText(), function(code)
      if code == Define.GangsPacketCode.Success then
        self:close()
      end
    end)
  end
  self:child("ButtonCloseCreateGang").onMouseClick = function()
    self:close()
  end
end

function M:selectedCreateGangIconCallBack(data)
  self.gangCreateIconId = data.id
end

function M:close()
  self:initData()
  Lib.closeWindow("./UI/gang/win_create_gang")
end

function M:onOpen()
  self:setUsingAutoRenderingSurface(true)
end

M:init()
