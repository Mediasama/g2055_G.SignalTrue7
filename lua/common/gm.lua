local M = {}
if World.isClient then
    Event.EVENT_SHOW_GMBOARD = Event.register("EVENT_SHOW_GMBOARD")
    Event.EVENT_SHOW_GM_BTN = Event.register("EVENT_SHOW_GM_BTN")
end
return M
