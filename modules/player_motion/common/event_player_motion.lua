if World.isClient then
  Event.EVENT_PAM_MOTION_CHANGED = Event.register("EVENT_PAM_MOTION_CHANGED")
  Event.EVENT_PAM_START_MOTION = Event.register("EVENT_PAM_ACTIVE_MOTION")
  Event.EVENT_PAM_STOP_MOTION = Event.register("EVENT_PAM_STOP_MOTION")
else
end
