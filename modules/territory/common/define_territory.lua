Define.TerritoryTriggerType = {Enter = "Enter", Exit = "Exit"}
Define.TerritoryOwnerType = {Player = 1, Gang = 2}
Define.TerritoryPacketCode = {
  Success = 1,
  OtherPlayerOccupying = 2,
  ErrorRequest = 3,
  SelfCamp = 4,
  NeedAddGang = 5
}
Define.TerritoryPacketTips = {
  [Define.TerritoryPacketCode.Success] = 1,
  [Define.TerritoryPacketCode.OtherPlayerOccupying] = "territory.tips.other.player.occupying",
  [Define.TerritoryPacketCode.ErrorRequest] = "territory.tips.error.request",
  [Define.TerritoryPacketCode.SelfCamp] = "territory.tips.same.camp",
  [Define.TerritoryPacketCode.NeedAddGang] = "territory.tips.need.add.gang"
}
Define.TerritoryEffectType = {
  NormalEffect = 1,
  NormalEffectMyCamp = 2,
  OccupyEffect = 3,
  InComeEffect = 4
}
