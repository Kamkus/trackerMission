local ESX = exports['es_extended']:getSharedObject()

local currentNPCPosition = Config.NPC.locations[math.random(1, #Config.NPC.locations)]
local tracker = {
    state = false,
    lastTruckerEnded = 0,
    thief = nil,
    car = nil,
    pos = {
        area = nil,
        carPosition = nil
    }
}

local ClearTrackerState = function()
    tracker = {
        state = false,
        lastTruckerEnded = os.time(),
        thief = nil,
        car = nil,
        pos = {
            area = nil,
            carPosition = nil
        }
    }
end

RegisterNetEvent('kd_trucker:server:endTrucker', function()
    local src = source
    ClearTrackerState()
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.addAccountMoney(Config.money.type, math.random(Config.money.min, Config.money.max))
end)

ESX.RegisterServerCallback('kd_trucker:callback:GetNPCPosition', function(src, cb)
    cb(currentNPCPosition)
end)

ESX.RegisterServerCallback('kd_trucker:callback:canStartTracker', function(src, cb)
    print(#ESX.GetExtendedPlayers('job', 'police'))
    cb(os.time() - tracker.lastTruckerEnded >= Config.truckerDelay and not tracker.state and #ESX.GetExtendedPlayers('job', 'police') >= Config.MinPolice)
end)

RegisterNetEvent('kd_trucker:server:startTucker', function()
    local src = source
    if tracker.state then
        return
    end
    tracker.state = true
    tracker.thief = src
    local truckerPosInfo = Config.tuckerLocations[math.random(1, #Config.tuckerLocations)]
    tracker.pos.area = truckerPosInfo.areaPosition
    tracker.pos.carPosition = truckerPosInfo.vehPositions[math.random(1, #truckerPosInfo.vehPositions)]
    TriggerClientEvent('kd_trucker:client:startTucker', src, {
        area = tracker.pos.area,
        carPosition = tracker.pos.carPosition
    })
end)

RegisterNetEvent('kd_trucker:server:setTruckerCar', function(netId)
    tracker.car = netId
end)

RegisterNetEvent('kd_trucker:server:policeGPS', function(coords)
    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPlayers) do
            TriggerClientEvent('kd_trucker:client:policeGPS', xPlayer.source, coords, tracker.car)
    end
end)

RegisterNetEvent('kd_trucker:server:truckerDestroy', function()
    TriggerClientEvent('kd_trucker:client:truckerDestroy', tracker.thief)
    ClearTrackerState()
    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPlayers) do
            TriggerClientEvent('kd_trucker:client:GPSRemoveForced', xPlayer.source)
    end
end)

RegisterNetEvent('kd_trucker:server:GPSRemoved', function()
    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPlayers) do
            TriggerClientEvent('kd_trucker:client:GPSRemoved', xPlayer.source)
    end
end)

AddEventHandler('playerDropped', function (reason)
    local src = source
    if src == tracker.thief then
        ClearTrackerState()
        local xPlayers = ESX.GetExtendedPlayers('job', 'police')
        for _, xPlayer in pairs(xPlayers) do
                TriggerClientEvent('kd_trucker:client:GPSRemoveForced', xPlayer.source)
        end
    end
  end)

  RegisterNetEvent('kd_trucker:server:removeitem', function(item)
    local src = source
    exports.ox_inventory:RemoveItem(src, item, 1)
  end)