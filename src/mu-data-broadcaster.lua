unit.hideWidget()

require('MuDataBroadcaster/model/MiningConstructStateDTO')

local serde = require('du_lib/requires/serde')

local broadcastChannel = 'mu' --export:
local pingChannel = 'collector_ping' --export: Channel Collector pings on

miningUnit1, miningUnit2, miningUnit3, miningUnit4, miningUnit5, miningUnit6, miningUnit7 = miningUnit1, miningUnit2, miningUnit3, miningUnit4, miningUnit5, miningUnit6, miningUnit7
emitter = emitter
receiver = receiver
container = container
---@type table<number, MiningUnit>
miningUnits = { miningUnit1, miningUnit2, miningUnit3, miningUnit4, miningUnit5, miningUnit6, miningUnit7 }

receiver.setChannelList({ pingChannel })
local state = MiningConstructStateDTO.new(container, miningUnits)
local stateString = serde.serialize(state)
emitter.send(broadcastChannel, stateString)

unit.exit()