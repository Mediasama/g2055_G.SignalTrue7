function Lib.logBastion(...)
  Lib.logInfo("=================Bastion Log Start=================")
  
  Lib.logInfo(...)
  Lib.logInfo("=================Bastion Log End=================")
end

local BastionUtils = Lib.class("BastionUtils")
local _instance

function BastionUtils.Instance()
  if _instance == nil then
    _instance = BastionUtils.new()
    _instance:init()
  end
  return _instance
end

function BastionUtils:ctor()
end

function BastionUtils:init()
  self._facilityTypeToConfigDict = {}
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.Reborn] = {
    cfgName = "myplugin/trigger_bastion_reborn"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.DoorSensor] = {
    cfgName = "myplugin/trigger_bastion_door_sensor"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.InDoorTrigger] = {
    cfgName = "myplugin/trigger_bastion_in_door"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.OutDoorTrigger] = {
    cfgName = "myplugin/trigger_bastion_out_door"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.Closet] = {
    cfgName = "myplugin/trigger_bastion_closet"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.Armory] = {
    cfgName = "myplugin/trigger_bastion_armory"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.Vault] = {
    cfgName = "myplugin/trigger_bastion_vault"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.Garage] = {
    cfgName = "myplugin/trigger_bastion_garage"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.Park] = {
    cfgName = "myplugin/trigger_bastion_park"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.ToolKit] = {
    cfgName = "myplugin/trigger_bastion_toolkit"
  }
  self._facilityTypeToConfigDict[Define.Bastion.Facility.Type.DoorPlate] = {
    cfgName = "myplugin/trigger_bastion_doorplate"
  }
end

function BastionUtils:getFacilityConfig(type)
  return self._facilityTypeToConfigDict[type]
end

function BastionUtils:copyArray(array)
  local cloneArray = {}
  for i, v in pairs(array) do
    cloneArray[i] = v
  end
  return cloneArray
end

function BastionUtils:swapSamples(array, index1, index2)
  array[index1], array[index2] = array[index2], array[index1]
end

function BastionUtils:shuffleSamples(samples)
  local counter = #samples
  while 1 < counter do
    local index = math.random(counter)
    self:swapSamples(samples, index, counter)
    counter = counter - 1
  end
end

function BastionUtils:getMinPriorityCandidate(candidates)
  local minCandidate
  for i, candidate in pairs(candidates) do
    if minCandidate == nil then
      minCandidate = candidate
    elseif candidate.priority < minCandidate.priority then
      minCandidate = candidate
    end
  end
  return minCandidate
end

function BastionUtils:getNSamples(samples, amount, putBack, repeatIfNotEnough)
  if amount <= 0 or next(samples) == nil then
    return {}
  end
  local cloneSamples = self:copyArray(samples)
  return self:drawNSamples(cloneSamples, amount, putBack, repeatIfNotEnough)
end

function BastionUtils:drawNSamples(samples, amount, putBack, repeatIfNotEnough)
  if putBack then
    repeatIfNotEnough = true
  end
  local result = {}
  while amount > #result do
    local drawCountPerTimes = amount
    if putBack then
      drawCountPerTimes = 1
    else
      drawCountPerTimes = math.min(amount - #result, #samples)
    end
    local candidates = self:drawSamples(samples, drawCountPerTimes)
    for i, candidate in pairs(candidates) do
      table.insert(result, candidate)
    end
    if not repeatIfNotEnough then
      break
    end
  end
  return result
end

function BastionUtils:drawSamples(samples, amount)
  local result = {}
  self:shuffleSamples(samples)
  local candidates = {}
  local minCandidate = {index = -1, priority = -999}
  for i, sample in pairs(samples) do
    if sample.weight > 0 then
      local priority = math.log(math.random()) / sample.weight
      if amount > #candidates then
        table.insert(candidates, {index = i, priority = priority})
        minCandidate = self:getMinPriorityCandidate(candidates)
      elseif priority > minCandidate.priority or minCandidate.index == -1 then
        minCandidate.index = i
        minCandidate.priority = priority
        minCandidate = self:getMinPriorityCandidate(candidates)
      end
    end
  end
  for i, candidate in pairs(candidates) do
    table.insert(result, samples[candidate.index].value)
  end
  return result
end

return BastionUtils
