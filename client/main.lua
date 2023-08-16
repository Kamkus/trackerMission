local ESX = exports['es_extended']:getSharedObject()

local trackerBlip = nil

local trackerState = nil
local trackerCar = nil
local trackerLocation = nil
local startedGPS = 0
local trackerPoliceBlip = nil
local trackerPoliceCar = nil

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('kd_trucker:callback:GetNPCPosition', function(currentNPCPosition)
        lib.requestModel(Config.NPC.model, 500)
        local NPC = CreatePed(4, GetHashKey(Config.NPC.model), currentNPCPosition.x, currentNPCPosition.y,
            currentNPCPosition.z, currentNPCPosition.w, false, true)
        SetEntityCoordsNoOffset(NPC, currentNPCPosition.x, currentNPCPosition.y, currentNPCPosition.z, true, false,
            false)
        FreezeEntityPosition(NPC, true)
        SetEntityInvincible(NPC, true)
        SetBlockingOfNonTemporaryEvents(NPC, true)
        exports.qtarget:AddTargetEntity(NPC, {
            options = {{
                icon = "fa-regular fa-circle-check",
                label = Config.lang['talk_to_npc'],
                action = function()
                    ESX.TriggerServerCallback('kd_trucker:callback:canStartTracker', function(canStart)
                        if not canStart then
                            ESX.ShowNotification(Config.lang['mission_in_progress'], 'info', 3000)
                            return
                        end
                        TriggerServerEvent('kd_trucker:server:startTucker')

                    end)
                end
            }},
            distance = 2
        })
    end)
end)

local GetDistanceBetweenTwoCoords = function(coords1, coords2)
    return math.ceil(math.sqrt((coords2.x - coords1.x) ^ 2 + (coords2.y - coords1.y) ^ 2))
end

RegisterNetEvent('kd_trucker:client:truckerDestroy', function()
    DeleteEntity(trackerCar)
    if trackerBlip ~= nil then
        RemoveBlip(trackerBlip)
    end
    trackerBlip = nil
    trackerState = nil
    trackerCar = nil
    trackerLocation = nil
    startedGPS = 0
end)

RegisterNetEvent('kd_trucker:client:startTucker', function(data)
    local carModel = Config.carModels[math.random(1, #Config.carModels)]
    SetNewWaypoint(data.area.x, data.area.y)
    local radius = GetDistanceBetweenTwoCoords(data.carPosition, data.area) + 100.0
    trackerBlip = AddBlipForRadius(data.area, radius)
    SetBlipAlpha(trackerBlip, 150)
    SetBlipColour(trackerBlip, 49)
    trackerState = 1
    lib.requestModel(carModel, 500)
    trackerCar = CreateVehicle(carModel, data.carPosition.x, data.carPosition.y, data.carPosition.z, data.carPosition.w,
        true, true)
    SetEntityCoordsNoOffset(trackerCar, data.carPosition, false, false, false)
    SetEntityHeading(trackerCar, data.carPosition.w)
    ESX.ShowNotification(string.format(Config.lang['car_location'], GetDisplayNameFromVehicleModel(GetHashKey(carModel)), GetVehicleNumberPlateText(trackerCar)), 'info', 10000)
    TriggerServerEvent('kd_trucker:server:setTruckerCar', NetworkGetNetworkIdFromEntity(trackerCar))
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        while trackerState == 1 do
            if #(GetEntityCoords(playerPed) - vector3(data.area.x, data.area.y, data.area.z)) <= radius then
                ESX.ShowNotification(Config.lang['right_spot'], 'info', 3000)
                trackerState = 2
            end
            Citizen.Wait(1000)
        end
    end)
    Citizen.SetTimeout(Config.AFKProtect * 1000 * 60, function()
        if trackerState == 1 then
            ESX.ShowNotification(Config.lang['afk'], 'error', 5000)
            TriggerServerEvent('kd_trucker:server:truckerDestroy')
        end
    end)
end)

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
    if trackerState ~= 2 then
        return
    end
    if (vehicle == trackerCar or GetVehicleNumberPlateText(trackerCar) == plate) then
        RemoveBlip(trackerBlip)
        trackerState = 3
        startedGPS = GetGameTimer()
        -- Add some alert for police
        ESX.ShowNotification(Config.lang['rid_of_gps'],'success', 3000)
        Citizen.CreateThread(function()
            while trackerState == 3 do
                TriggerServerEvent('kd_trucker:server:policeGPS', GetEntityCoords(trackerCar))
                Citizen.Wait(500)
            end
        end)
    end
end)

AddEventHandler('esx:exitedVehicle', function(vehicle, plate, seat, displayName, netId)
    if trackerState ~= 4 or #(trackerLocation - GetEntityCoords(trackerCar)) > 30.0 then
        return
    end
    if (vehicle == trackerCar or GetVehicleNumberPlateText(trackerCar) == plate) then
        RemoveBlip(trackerBlip)
        ESX.ShowNotification(Config.lang['good_job'], 'success', 3000)
        TriggerServerEvent('kd_trucker:server:endTrucker')
        Citizen.SetTimeout(5000, function()
            DeleteEntity(trackerCar)
            trackerBlip = nil
            trackerState = nil
            trackerCar = nil
            trackerLocation = nil
            startedGPS = 0
        end)
    end
end)

RegisterNetEvent('kd_trucker:client:GPSRemoved', function()
    Citizen.SetTimeout(Config.GPSRemove, function()
        if trackerPoliceBlip ~= nil then
            RemoveBlip(trackerPoliceBlip)
            trackerPoliceBlip = nil
        end
    end)
end)

RegisterNetEvent('kd_trucker:client:GPSRemoveForced', function()
    if trackerPoliceBlip ~= nil then
        RemoveBlip(trackerPoliceBlip)
        trackerPoliceBlip = nil
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        RemoveBlip(trackerBlip)
    end
end)

RegisterNetEvent('kd_trucker:client:policeGPS', function(coords, vehicleNetID)
    if vehicleNetID ~= trackerPoliceCar then
        trackerPoliceCar = vehicleNetID
    end
    RemoveBlip(trackerPoliceBlip)
    trackerPoliceBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(trackerPoliceBlip, 227)
    SetBlipScale(trackerPoliceBlip, 1.5)
    SetBlipDisplay(trackerPoliceBlip, 2)
    SetBlipColour(trackerPoliceBlip, 49)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.lang['stolen_vehicle'])
    EndTextCommandSetBlipName(trackerPoliceBlip)
end)

local inAction = false


local GPSDestroyed = function()
    trackerState = 4
    TriggerServerEvent('kd_trucker:server:GPSRemoved')
    ESX.ShowNotification(
        Config.lang['gps_off'],
        'success', 3000)
    trackerLocation = Config.trackerHideoutLocations[math.random(1, #Config.trackerHideoutLocations)]
    trackerBlip = AddBlipForCoord(trackerLocation.x, trackerLocation.y, trackerLocation.z)
    SetBlipSprite(trackerBlip, 271)
    SetBlipScale(trackerBlip, 1.0)
    SetBlipDisplay(trackerBlip, 2)
    SetBlipColour(trackerBlip, 73)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.lang['drop'])
    EndTextCommandSetBlipName(trackerBlip)
    SetBlipRoute(trackerBlip, true)
end

local hackSuccess = function()
    if lib.progressBar({
        duration = 20000,
        label = Config.lang['taking_off_gps'],
        useWhileDead = false,
        canCancel = false,
        anim = {
            dict = 'amb@prop_human_bum_bin@base',
            clip = 'base',
            blendIn = 8.0,
            blendOut = 8.0
        },
        disable = {
            move = true,
            car = true
        }
    }) then
        inAction = false
        GPSDestroyed()
        TriggerServerEvent('kd_trucker:server:removeitem', Config.RequireItem)
    else
        inAction = false
    end
end

exports.qtarget:Vehicle({
    options = {{
        icon = "fa-regular fa-circle-check",
        label = Config.lang['tow_the_vehicle'],
        canInteract = function(entity)
            if trackerPoliceCar == nil then
                return false
            end
            return entity == NetworkGetEntityFromNetworkId(trackerPoliceCar)
        end,
        action = function()
            if not inAction then
                inAction = true
                if lib.progressBar({
                    duration = 6000,
                    label = Config.lang['towing'],
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true
                    }
                }) then
                    inAction = false
                    TriggerServerEvent('kd_trucker:server:truckerDestroy')
                    trackerPoliceCar = nil
                else
                    inAction = false
                end
            end
        end,
        job = {
            ['police'] = 0
        }
    }, {
        icon = "fa-regular fa-circle-check",
        label = Config.lang['gps_take_off'],
        canInteract = function(entity)
            if trackerState ~= 3 then
                return false
            end
            return (GetGameTimer() - startedGPS) / 1000 >= Config.destroyGPSTime
        end,
        action = function()
            if exports.ox_inventory:Search('count', Config.RequireItem) < 1 then
                ESX.ShowNotification(Config.lang['required_items'], 'error', 3000)
                return
            end
            hackSuccess()
        end
    }},
    distance = 2
})
