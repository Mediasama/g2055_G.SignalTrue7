Define.DIE_SUB_STATE = {
  OnGround = "OnGround",
  BeCarried = "BeCarried",
  BeThrow = "BeThrow",
  AutoHurt = "AutoHurt",
  Throw = "Throw"
}
Define.DIE_SUB_STATE_REF_PLAYER_STATE = {
  [Define.DIE_SUB_STATE.OnGround] = Define.CHARACTER_STATE_TYPE.GROUND,
  [Define.DIE_SUB_STATE.BeCarried] = Define.CHARACTER_STATE_TYPE.BeCARRY
}
