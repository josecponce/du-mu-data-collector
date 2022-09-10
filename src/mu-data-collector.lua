require('du_lib/requires/stateManager')
require('du_lib/requires/dataHud')
require('du_lib/waypoints/WaypointManager')
require('MuDataCollector/service/BroadcasterPinger')
require('MuDataCollector/service/DataCollector')
require('MuDataCollector/service/MuDataHud')
require('MuDataCollector/service/DataSharing')

local broadcastChannel = 'collector_ping' --export: Channel to ping MuDataBroadcasters on
local broadcastInterval = 1 --export: How often the collector should ping the MU programming boards
local shareInterval = 0.5 --export: Interval between sharing each data point
local minCalibration = 0.35 --export: Calibration to use for the Next Calibration field in the HUD
local contentFontSize = 15 --export: Hud content size
local elementsByPage = 10 --export: How many elements are show per page of the HUD

local workPerTick = 1000 --export: coroutine amount of work done per tick
local workTickInterval = 0.1 --export: coroutine interval between ticks


emitter = emitter
receiver = receiver
muDb = muDb
waypointDb = waypointDb


--Collect Data State
local hud = FullDataHud.new(system, contentFontSize, elementsByPage)
local waypointManager = WaypointManager.new(system, waypointDb)
---@type Service[]
local collectServices = {
    BroadcasterPinger.new(emitter, broadcastChannel, broadcastInterval),
    DataCollector.new(receiver, muDb),
    MuDataHud.new(system, muDb, minCalibration, hud, waypointManager),
    hud
}
local collectState = State.new(collectServices, unit, system, workPerTick, workTickInterval)


--Sync/Share State
local syncServices = {
    DataSharing.new(muDb, emitter, shareInterval, hud),
    hud
}
local syncState = State.new(syncServices, unit, system, workPerTick, workTickInterval)


StateManager.new({ collectState, syncState }, system).start()