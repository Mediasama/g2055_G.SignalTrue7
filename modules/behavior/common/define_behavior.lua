Define.TriggerHandlers = {
  PLAYER_TELEPORT_MAP = "PLAYER_TELEPORT_MAP",
  PLAYER_TELEPORT_POSITION = "PLAYER_TELEPORT_POSITION"
}
Define.Unit = {
  Type = {None = "None", Entity = "Entity"}
}
Define.Behavior = {
  Type = {
    None = "None",
    ShowLog = "ShowLog",
    OperateBastionFacility = "OperateBastionFacility",
    OperateBastionDefense = "OperateBastionDefense",
    OperateBastionPark = "OperateBastionPark",
    OperateTerritoryOccupy = "OperateTerritoryOccupy",
    OperateArea = "OperateArea",
    OperateTattoo = "OperateTattoo",
    TriggerGoodsShelf = "TriggerGoodsShelf",
    ChangeBGM = "ChangeBGM",
    OperateNpcDoor = "OperateNpcDoor"
  },
  State = {
    None = 0,
    Running = 1,
    Finish = 2
  }
}
Define.EntityOperation = {
  Type = {
    Spawn = "spawn",
    Destroy = "destroy",
    EntityEnter = "entityEnter",
    EntityHit = "entityHit",
    EntityLeave = "entityLeave",
    UseItem = "useItem",
    Trigger = "trigger",
    TeleportMap = "teleportMap",
    RideOn = "rideOn",
    RideOff = "rideOff",
    Drive = "drive"
  },
  State = {
    None = "None",
    AnyItem = "AnyItem",
    SpecificItem = "SpecificItem"
  },
  ItemMatchState = {
    None = 0,
    Any = 1,
    Specific = 2
  }
}
