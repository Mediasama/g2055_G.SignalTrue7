Define.GangOperationType = {
  Create = 0,
  Join = 1,
  Chat = 2,
  Voice = 3,
  Leave = 4,
  Transfer = 5,
  Dismiss = 6,
  ChangeLogo = 7
}
Define.GangTeamInfoType = {
  Create = 0,
  Join = 1,
  Exit = 2,
  LogoChange = 3,
  TerritoryAdd = 4,
  TerritoryMinus = 5,
  ChairManChange = 6,
  ChairDismiss = 7,
  AllPlayerLeave = 8
}
Define.CoinsPos = {Body = 0, WareHouse = 1}
Define.TattooOperationType = {
  Start = 0,
  Interrupt = 1,
  Success = 2
}
Define.TerritoryOperationType = {
  Start = 0,
  Interrupt = 1,
  Success = 2
}
Define.CurrencyReason = {
  BastionFetch = "BastionFetch",
  OccupyTerritory = "Territory",
  Pick = "Pick",
  Die = "Die",
  BastionSteal = "BastionSteal",
  Buy = "Buy",
  Tattoo = "Tattoo",
  BastionDeposit = "BastionDeposit",
  Door = "Door",
  BlackMarket = "BlackMarket",
  Clothes = "Clothes",
  BuyCar = "BuyCar",
  BuyItem = "BuyItem",
  Garage = "Garage",
  Bullet = "Bullet",
  Weapon = "Weapon",
  Armory = "Armory",
  Exchange = "Exchange",
  PassCardReward = "PassCardReward",
  ATM = "ATM"
}
Define.CurrencyReasonId = {
  [Define.CurrencyReason.BastionFetch] = 1,
  [Define.CurrencyReason.OccupyTerritory] = 2,
  [Define.CurrencyReason.Pick] = 3,
  [Define.CurrencyReason.Die] = 4,
  [Define.CurrencyReason.Weapon] = 5,
  [Define.CurrencyReason.Tattoo] = 6,
  [Define.CurrencyReason.BastionDeposit] = 7,
  [Define.CurrencyReason.Door] = 8,
  [Define.CurrencyReason.BlackMarket] = 9,
  [Define.CurrencyReason.Clothes] = 10,
  [Define.CurrencyReason.BuyCar] = 11,
  [Define.CurrencyReason.BuyItem] = 12,
  [Define.CurrencyReason.Garage] = 13,
  [Define.CurrencyReason.Bullet] = 14,
  [Define.CurrencyReason.Armory] = 15,
  [Define.CurrencyReason.Exchange] = 16,
  [Define.CurrencyReason.BastionSteal] = 17,
  [Define.CurrencyReason.PassCardReward] = 18,
  [Define.CurrencyReason.ATM] = 19
}
Define.CurrencyType = {
  FromSystem = 0,
  FromPlayer = 1,
  Others = 2
}
Define.ItemFlowReason = {
  Buy = "Buy",
  Fetch = "Fetch",
  Deposit = "Deposit",
  Steal = "Steal"
}
Define.ItemFlowSubReason = {}
Define.EventTracking = {
  Type = {
    None = "",
    EnterArea = "enter_area",
    ExitArea = "area_leave",
    OperateFacility = "player_house_set",
    ChangeClothes = "clothing_set",
    HackDoor = "house_door_unlock",
    GainItem = "item_gain",
    LoseItem = "item_drop",
    ChatInf = "cheat_info",
    AddFriend = "add_friend",
    CarDrive = "cars_drive",
    CarArrive = "cars_arrive",
    CarUnlock = "car_unlock",
    CarBump = "drive_bump",
    PassCardBuy = "passcard_buy",
    PassCardAwardGet = "passcard_award_get",
    PassCardTaskFinish = "passcard_task_finish",
    UseAction = "use_action",
    UseDoubleAction = "use_double_action",
    ATMSet = "atm_set"
  },
  Area = {
    Shop = {
      None = 0,
      Weapon = 1,
      Tattoo = 2,
      Clothes = 3,
      Car = 4,
      BlackMarket = 5,
      Bullet = 6
    },
    Bastion = {
      None = 0,
      Armory = 11,
      Closet = 12,
      Door = 13,
      Garage = 14,
      Toolkit = 15,
      Vault = 16,
      Park = 17
    }
  },
  Facility = {
    Vault = {
      None = 0,
      Deposit = 1,
      Fetch = 2
    },
    Armory = {
      None = 0,
      Deposit = 11,
      Fetch = 12,
      Buy = 13
    },
    Closet = {
      None = 0,
      Deposit = 21,
      Fetch = 22
    },
    Garage = {
      None = 0,
      Buy = 31,
      Deposit = 32,
      Fetch = 33
    },
    Defense = {None = 0, Fetch = 41}
  },
  Defense = {
    Door = {
      Hack = {
        Start = 0,
        Killed = 1,
        Failed = 2,
        Succeed = 3
      }
    }
  },
  Item = {
    Type = {
      Car = 1,
      Weapon = 2,
      Clothes = 3,
      Skin = 4,
      Bullet = 5,
      Item = 6
    },
    Gain = {
      Fetch = 0,
      Buy = 1,
      PickUpSystem = 2,
      PickUpDrop = 6,
      Steal = 3,
      BlackMarket = 4,
      Hack = 5,
      PassCard = 7
    },
    Lose = {
      Use = 0,
      Deposit = 1,
      Die = 2,
      Expropriate = 3,
      Hack = 4,
      Steal = 5
    }
  },
  ChatInf = {
    Type = {
      Private = 1,
      Gang = 2,
      World = 3
    },
    InfType = {
      Text = 1,
      Voice = 2,
      Emoji = 3
    }
  },
  AddFriend = {
    Status = {
      SendInvite = 0,
      ReceiveInvite = 1,
      AgreeInvite = 2,
      RefuseInvite = 3,
      InviteSuccess = 4,
      InviteFail = 5
    }
  },
  CarUnlock = {
    Status = {
      Start = 0,
      Break = 1,
      Fail = 2,
      Success = 3
    }
  },
  CarBump = {
    BumpType = {
      Player = 0,
      StaticCar = 1,
      MoveCar = 2
    }
  },
  PassCardBuy = {
    BuyContent = {Gold = 1, Level = 2}
  },
  PassCardAwardGet = {
    AwardType = {Free = 0, Gold = 1}
  },
  UseDoubleAction = {
    ActionType = {Shame = 1, Throw = 2}
  }
}
