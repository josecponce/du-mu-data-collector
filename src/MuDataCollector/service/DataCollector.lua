require('du_lib/requires/service')

local serde = require('du_lib/requires/serde')

---@class DataCollector : Service
DataCollector = {}
DataCollector.__index = DataCollector

---@param receiver Receiver
---@param db Databank
---@return DataCollector
function DataCollector.new(receiver, db)
    local self = --[[---@type self]] Service.new()

    local receiveData = function(_, channel, message)
        ---@type MiningConstructStateDTO
        local muData = serde.deserialize(message)
        local latest = message

        if db.hasKey(channel) == 1 then
            local previous = db.getStringValue(channel)
            ---@type MiningConstructStateDTO
            local previousData = serde.deserialize(previous)

            if previousData and previousData.timestamp > muData.timestamp  then
                return
            end
        end

        db.setStringValue(channel, latest)
    end

    ---@param state State
    function self.start(state)
        state.registerHandler(receiver, 'onReceived', receiveData)
    end

    return setmetatable(self, DataCollector)
end