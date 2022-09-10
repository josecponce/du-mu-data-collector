require('du_lib/requires/service')
require('du_lib/requires/dataHud')
require('du_lib/waypoints/WaypointManager')

local serde = require('du_lib/requires/serde')

---@class MuDataHud : Service
MuDataHud = {}
MuDataHud.__index = MuDataHud

local perHourDecay = 0.00625

local function durationFormat(duration)
    local timeLeft = duration
    local days = math.floor(timeLeft / (24 * 3600))
    timeLeft = timeLeft - days * 24 * 3600
    local hours = math.floor(timeLeft / 3600)
    timeLeft = timeLeft - hours * 3600
    local minutes = math.floor(timeLeft / 60)
    timeLeft = timeLeft - minutes * 60

    return string.format('%.0fd %.0fh %.0fm', days, hours, minutes)
end

local HEADERS = { 'Name', 'Time', 'Calib', 'Next Calib', 'Cont %', 'MU #' }

---@param minCalibration number
---@return string[][]
local function calculateData(system, db, minCalibration)
    local keys = db.getKeyList()
    table.sort(keys)
    local data = {}

    local currentTime = system.getUtcTime()
    for _, key in pairs(keys) do
        ---@type MiningConstructStateDTO
        local muData = serde.deserialize(db.getStringValue(key))

        local miningUnits = muData.miningUnits
        table.sort(miningUnits, function(l, r)
            return l.calibration < r.calibration
        end)
        local elapsed = math.max(0, currentTime - muData.timestamp)
        local minCalUnit = miningUnits[1]
        local decayHoursTotal = math.floor((minCalUnit.lastCalibration + elapsed) / 3600 - 72)
        local decayHoursCollect = math.max(0, minCalUnit.lastCalibration / 3600 - 72)
        local decay = math.max(0, decayHoursTotal - decayHoursCollect) * perHourDecay
        local estimateMinCalibration = math.max(0, minCalUnit.calibration - decay)

        local originalCalibration = minCalUnit.calibration + decayHoursCollect * perHourDecay
        local totalTimeToMinCalibration = 72 + (originalCalibration - minCalibration) / perHourDecay
        local nextCalibrationTime = math.max(0, totalTimeToMinCalibration * 3600 - minCalUnit.lastCalibration - elapsed)

        local row = {
            key,
            durationFormat(elapsed),
            string.format('%.2f%%', estimateMinCalibration * 100),
            durationFormat(nextCalibrationTime),
            string.format('%.2f%%', muData.container.fillLevel * 100),
            #miningUnits
        }

        table.insert(data, row)
    end

    return data
end

---@param system System
---@param muDb Databank
---@param minCalibration number
---@param hud FullDataHud
---@param waypointManager WaypointManager
---@return MuDataHud
function MuDataHud.new(system, muDb, minCalibration, hud, waypointManager)
    local self = --[[---@type self]] Service.new()

    local data
    local  function updateHud()
        data = calculateData(system, muDb, minCalibration)
        local huData = FullDataHudData.new('Collect Mode', HEADERS, data)
        hud.updateData(huData)
    end

    local function recordWaypoint(_, _, index)
        local name = data[index][1]
        waypointManager.recordWaypoint(name)
    end

    local function setWaypoint(_, _, index)
        local name = data[index][1]
        waypointManager.setWaypoint(name)
    end

    ---@param state State
    function self.start(state)
        state.registerTimer('MuDataHud_updateHud', 0.5, updateHud)
        state.registerHandler(hud, FULL_DATA_HUD_EVENTS.DETAIL_ACTION_LEFT, recordWaypoint)
        state.registerHandler(hud, FULL_DATA_HUD_EVENTS.DETAIL_ACTION_RIGHT, setWaypoint)
    end

    return setmetatable(self, MuDataHud)
end