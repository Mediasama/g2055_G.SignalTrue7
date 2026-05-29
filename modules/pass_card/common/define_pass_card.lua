Define.PassCardRewardType = {
  RewardMoney = 1,
  RewardItem = 2,
  RewardVehicle = 3,
  RewardCloth = 4,
  RewardWeapon = 5,
  RewardMotion = 6
}
Define.PassCardRewardStatus = {Got = 1}
Define.PassCardGetRewardRespond = {
  ToCarShop = 100,
  GetOffToCarShop = 101,
  WeaponBagFull = 102,
  HaveSameCloth = 103
}
Define.PassCardGetRewardRespondText = {
  [Define.PassCardGetRewardRespond.ToCarShop] = "passCard.carTips",
  [Define.PassCardGetRewardRespond.GetOffToCarShop] = "passCard.carGetOffTips",
  [Define.PassCardGetRewardRespond.WeaponBagFull] = "passCard.weaponTips",
  [Define.PassCardGetRewardRespond.HaveSameCloth] = "passCard.clothTips"
}
Define.PassCardQuestType = {
  QuestTypeKill = 1,
  QuestTypeInCome = 2,
  QuestTypePay = 3
}
Define.PassCardQuestKillType = {
  QuestKillPlayer = 1,
  QuestKillDoor = 2,
  QuestKillATM = 3
}
Define.PassCardQuestInComeType = {QuestInComeMoney = 1}
Define.PassCardQuestPayType = {QuestPayMoney = 1, QuestPayCube = 2}
