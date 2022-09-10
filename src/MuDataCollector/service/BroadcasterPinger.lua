require('du_lib/requires/service')

---@class BroadcasterPinger : Service
---@field PING_TIMER
BroadcasterPinger = {}
BroadcasterPinger.__index = BroadcasterPinger

BroadcasterPinger.PING_TIMER = 'broadcast_ping'

---@param emitter Emitter
---@param channel string
---@param interval number
---@return BroadcasterPinger
function BroadcasterPinger.new(emitter, channel, interval)
    local self = --[[---@type self]] Service.new()

    local ping = function()
        emitter.send(channel, 'ping')
    end

    ---@param state State
    function self.start(state)
        state.registerTimer(BroadcasterPinger.PING_TIMER, interval, ping)
    end

    return setmetatable(self, BroadcasterPinger)
end