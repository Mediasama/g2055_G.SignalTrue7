Define.GangsPosition = {ChairMan = 1, Member = 2}
Define.GangsPositionName = {
  [Define.GangsPosition.ChairMan] = "gang.position.chairman",
  [Define.GangsPosition.Member] = "gang.position.member"
}
Define.GangsPacketCode = {
  Success = 0,
  HasGangs = 1,
  CreateFail = 2,
  SensitiveWord = 3,
  GangNameExist = 4,
  GangNameNull = 5,
  GangNameTooLong = 6,
  Other = 7,
  AlreadyEnterOtherGang = 8,
  MaxMember = 9,
  SuccessApply = 10
}
Define.GangsPacketCodeToastTips = {
  [Define.GangsPacketCode.SensitiveWord] = "gang.tips.sensitive.word",
  [Define.GangsPacketCode.GangNameExist] = "gang.tips.name.exist",
  [Define.GangsPacketCode.GangNameNull] = "gang.tips.name.null",
  [Define.GangsPacketCode.HasGangs] = "gang.tips.access.apply.fail",
  [Define.GangsPacketCode.GangNameTooLong] = "gang.tips.name.too.long",
  [Define.GangsPacketCode.AlreadyEnterOtherGang] = "gang.tips.player.has.gang",
  [Define.GangsPacketCode.MaxMember] = "gang.tips.max.member"
}
Define.ProcessApplication = {Access = 1, Deny = 2}
Define.GangScrollIndex = {
  GangList = 1,
  ApplyList = 2,
  MemberList = 3
}
Define.GangPlayerCircleType = {
  Green = 1,
  Yellow = 2,
  Red = 3
}
Define.GangPlayerCircleEffect = {
  [Define.GangPlayerCircleType.Green] = "g2055_effect_player_guangquan_green.effect",
  [Define.GangPlayerCircleType.Yellow] = "g2055_effect_player_guangquan_yellow.effect",
  [Define.GangPlayerCircleType.Red] = "g2055_effect_player_guangquan_red.effect"
}
