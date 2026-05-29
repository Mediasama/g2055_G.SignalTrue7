if World.isClient then
  Event.EVENT_UPDATE_NEW_TATTOO_DATA = Event.register("EVENT_UPDATE_NEW_TATTOO_DATA")
  Event.EVENT_TATTOO_INTERRUPT = Event.register("EVENT_TATTOO_INTERRUPT")
else
end
