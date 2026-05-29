local BastionOperatorBase = Lib.class("BastionOperatorBase")

function BastionOperatorBase:ctor(param)
  param = param or {}
  self._type = Define.Bastion.Facility.Type.None
end

function BastionOperatorBase:destroy()
end

function BastionOperatorBase:operate(param)
end

return BastionOperatorBase
