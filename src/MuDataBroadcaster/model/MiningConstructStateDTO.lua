---@class MiningConstructStateDTO
MiningConstructStateDTO = {}
MiningConstructStateDTO.__index = MiningConstructStateDTO

---@param container Container
---@param units table<number, MiningUnit>
---@return MiningConstructStateDTO
function MiningConstructStateDTO.new(container, units)
    local self = --[[---@type self]] {}

    self.timestamp = system.getUtcTime()
    self.container = ContainerStateDTO.new(container)
    ---@type MiningUnitStateDTO[]
    self.miningUnits = {}
    for _, unit in pairs(units) do
        table.insert(self.miningUnits, MiningUnitStateDTO.new(unit))
    end

    return self
end

---@class MiningUnitStateDTO
MiningUnitStateDTO = {}
MiningUnitStateDTO.__index = MiningUnitStateDTO

---@param unit MiningUnit
---@return MiningUnitStateDTO
function MiningUnitStateDTO.new(unit)
    local self = --[[---@type self]] {}

    self.calibration = unit.getCalibrationRate()
    self.lastCalibration = unit.getLastExtractionTime()
    self.state = unit.getState()

    return self
end

---@class ContainerStateDTO
ContainerStateDTO = {}
ContainerStateDTO.__index = ContainerStateDTO

---@param container Container
---@return ContainerStateDTO
function ContainerStateDTO.new(container)
    local self = --[[---@type self]] {}

    self.fillLevel = container.getItemsVolume() / container.getMaxVolume()

    return self
end