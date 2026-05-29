Define.Bastion = {
  Type = {None = "None", Home = "Home"},
  Facility = {
    Type = {
      None = "None",
      Reborn = "Reborn",
      DoorSensor = "DoorSensor",
      OutDoorTrigger = "OutDoorTrigger",
      InDoorTrigger = "InDoorTrigger",
      Closet = "Closet",
      Armory = "Armory",
      Vault = "Vault",
      Garage = "Garage",
      Park = "Park",
      ToolKit = "ToolKit",
      DoorPlate = "DoorPlate"
    },
    TriggerType = {
      None = "None",
      Open = "Open",
      Close = "Close"
    },
    OperateType = {
      Buy = "Buy",
      Query = "Query",
      Fetch = "Fetch",
      Deposit = "Deposit",
      Steal = "Steal"
    },
    OperateErrorCode = {
      Overflow = -1,
      Succeed = 0,
      ParamWrong = 1,
      UnknownFacility = 2,
      UnknownManner = 3,
      InvalidOwner = 4,
      InvalidOperator = 5,
      Failed = 6
    }
  },
  Defense = {
    Type = {None = "None", Door = "Door"},
    Status = {
      None = "None",
      Normal = "Normal",
      Damaged = "Damaged",
      Hacked = "Hacked"
    },
    Tips = {
      Type = {
        None = 0,
        Damaged = 1,
        AttackDoor = 7,
        StartHacked = 6,
        Hacked = 2,
        HackedSucceed = 3,
        HackedFailed = 4,
        OwnerUpdate = 5
      }
    }
  },
  Currency = {
    Type = {Gold = 3}
  },
  DoorHackItemID = 80001
}
