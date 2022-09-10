require('du_lib/requires/service')
require('du_lib/requires/dataHud')

---@class DataSharing : Service
DataSharing = {}
DataSharing.__index = DataSharing

local SHARE_TIMER = 'data_share'
local HEADERS = { 'Shared' }

---@param db Databank
---@param emitter Emitter
---@param share_interval number
---@param hud FullDataHud
---@return DataSharing
function DataSharing.new(db, emitter, share_interval, hud)
    local self = --[[---@type self]] Service.new()

    ---@type FullDataHudData
    local hudData = FullDataHudData.new('Sync Mode', HEADERS, { })
    hud.updateData(hudData)

    local current_record = 1
    local function share_data()
        local numKeys = db.getNbKeys()

        if numKeys == 0 then
            return
        end

        if current_record > numKeys then
            current_record = 1
        end

        local key = db.getKeyList()[current_record]
        local data = db.getStringValue(key)
        emitter.send(key, data)

        table.insert(hudData.rows, { key })

        current_record = current_record + 1
    end

    ---@param state State
    function self.start(state)
        hudData.rows = {}

        state.registerTimer(SHARE_TIMER, share_interval, share_data)
    end

    return setmetatable(self, DataSharing)
end