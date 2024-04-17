function createBlip(data)
    if data.Blip then
        if data.GarageType == 'car' then
            local blip = AddBlipForCoord(data.PedCoords) 
            SetBlipSprite(blip, Config.Blips.Vehicle.sprite)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, Config.Blips.Vehicle.color)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Blips.Vehicle.label)
            EndTextCommandSetBlipName(blip)
        elseif data.GarageType == 'boat' then
            local blip = AddBlipForCoord(data.PedCoords) 
            SetBlipSprite(blip, Config.Blips.Boat.sprite)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, Config.Blips.Boat.color)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Blips.Boat.label)
            EndTextCommandSetBlipName(blip)
        else
            local blip = AddBlipForCoord(data.PedCoords) 
            SetBlipSprite(blip, Config.Blips.Air.sprite)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, Config.Blips.Air.color)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Blips.Air.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

function createPed(garage, data)
    lib.requestModel(data.PedType) 
    local ped = CreatePed(1, data.PedType, data.PedCoords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, data.Anim, 0, true)

    local options = {
        {
            name = 'eb_garage:garageTarget',
            label = 'Tilgå ' .. garage,
            onSelect = function()
                TriggerEvent('eb_garage:mainMenu', garage, data)
            end,
        },
    }
    exports.ox_target:addLocalEntity(ped, options)
end

AddEventHandler('eb_garage:mainMenu', function(garage, data)
    local area = Config.Garages[garage].Area
    lib.registerContext({
        id = 'eb_garage:mainMenu',
        title = garage,
        options = {
            {
                title = 'Nuværende Område: ' .. area,
                icon = 'map-location-dot',
                readOnly = true,
            },
            {
                title = 'Køretøjs Oversigt',
                description = 'Alle dine køretøjer',
                icon = 'list',
                onSelect = function()
                    TriggerEvent('eb_garage:allVehicles', data)
                end,
            },
            {
                title = 'Ejede Køretøjer',
                description = 'Alle dine ejede køretøjer parkeret i ' .. area,
                icon = 'lock',
                onSelect = function()
                    TriggerEvent('eb_garage:ownedVehicles', data, area)
                end,
            },
            {
                title = 'Leasede Køretøjer',
                description = 'Alle dine leasede køretøjer parkeret i ' .. area,
                icon = 'file-contract',
                onSelect = function()
                    TriggerEvent('eb_garage:leasedVehicles', data, area) 
                end,
            },
        }
    })
    lib.showContext('eb_garage:mainMenu')
end)

AddEventHandler('eb_garage:allVehicles', function(data)
    local vehicles = lib.callback.await('eb_garage:getAllVehicles', false, data.GarageType)
    if not vehicles then
        print('Noget gik galt!')
        return
    end

    local options = {
        {title = 'Tilbage', menu = 'eb_garage:mainMenu'},
    }
    if #vehicles > 0 then
        for _, v in pairs(vehicles) do
            local fuelLevel = v.vehicleprops.fuelLevel
            local bodyHealth = v.vehicleprops.bodyHealth/10
            local engineHealth = v.vehicleprops.engineHealth/10
            table.insert(options, {
                title = v.label,
                icon = getClassIcon(GetVehicleClassFromName(v.vehicle)),
                description = v.numberplate,

                onSelect = function()
                    TriggerEvent('eb_garage:manageVehicle', v.label, v.vehicle, v.numberplate)
                end,

                metadata = {
                    {label = 'Parkeringsstatus', value = v.area},
                    {label = 'Leased', value = isLeased(v.leased)},
                    {label = 'Brændstof', value = fuelLevel .. '%', progress = fuelLevel},
                    {label = 'Køretøjets Helbred', value = bodyHealth .. '%', progress = bodyHealth},
                    {label = 'Motorens Helbred', value = engineHealth .. '%', progress = engineHealth},
                },
            })
        end
    else
        table.insert(options, {
            title = 'Ingen køretøjer fundet',
            icon = 'car',
            readOnly = true,
        })
    end

    lib.registerContext({
        id = 'eb_garage:allVehicles',
        title = 'Alle Køretøjer',
        options = options,
    })
    lib.showContext('eb_garage:allVehicles')
end)

AddEventHandler('eb_garage:manageVehicle', function(label, vehicle, numberplate)
    local options = {
        { title = 'Tilbage', menu = 'eb_garage:allVehicles' },
    }

    if Config.EnableVehicleRename then
        table.insert(options, {
            title = 'Skift Navn',
            description = 'Giv din ' .. label .. ' et andet navn',
            icon = 'pen',
            onSelect = function()
                local input = lib.inputDialog(label .. ' Navneskift', {'Navn'})
                if not input then lib.showContext('eb_garage:manageVehicle') return end

                local alert = lib.alertDialog({
                    header = '**Navneskift af ' .. label .. '**',
                    content = 'Ønsker du at kalde din ' .. label .. ' for **' .. input[1] .. '**?',
                    centered = true,
                    cancel = true
                })

                if alert == 'confirm' then
                    TriggerServerEvent('eb_garage:changeName', numberplate, input[1])
                else
                    lib.showContext('eb_garage:manageVehicle')
                end
            end,
        })

        table.insert(options, {
            title = 'Refresh Navn',
            description = "Ændre " .. label .. "'s navn til standard",
            icon = 'arrows-rotate',
            disabled = canRefresh(label, vehicle),
            onSelect = function()
                TriggerServerEvent('eb_garage:changeName', numberplate, GetLabelText(vehicle))
            end,
        })
    end

    if Config.EnableVehicleSell then
        table.insert(options, {
            title = 'Sælg ' .. label,
            description = 'Sælg din ' .. label .. ' til en anden spiller',
            icon = 'file-contract',
            onSelect = function()
                TriggerEvent('eb_garage:sellVeh', label, vehicle, numberplate)
            end,
        })
    end

    lib.registerContext({
        id = 'eb_garage:manageVehicle',
        title = label,
        options = options
    })
    lib.showContext('eb_garage:manageVehicle')
end)

AddEventHandler('eb_garage:sellVeh', function(label, vehicle, numberplate)
    local options = {
        { title = 'Tilbage', menu = 'eb_garage:manageVehicle' },
    }
    local playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5.0)
            
    if #playersNearby > 0 then
        for i = 1, #playersNearby, 1 do
            if playersNearby[i] ~= PlayerId() then
                table.insert(options, {
                    title = 'Navn: ' .. GetPlayerName(playersNearby[i]),
                    icon = 'user',
                    onSelect = function()
                        local input = lib.inputDialog(label .. ' Salg', {
                            {type = 'number', label = 'Pris'},
                        }) 
                        if not input then lib.showContext('eb_garage:sellVeh') return end
                        TriggerServerEvent('eb_garage:requestBuyer', GetPlayerServerId(playersNearby[i]), input[1], GetLabelText(vehicle), numberplate)
                    end,
    
                })
            end
        end
    else 
        table.insert(options, {
            title = 'Ingen spillere tæt på',
            icon = 'user',
            readOnly = true,
        })
    end

    lib.registerContext({
        id = 'eb_garage:sellVeh',
        title = 'Vælg Person',
        options = options,
    })
    lib.showContext('eb_garage:sellVeh')
end)

lib.callback.register('eb_garage:sendRequest', function(price, label, plate, name)
    local alert = lib.alertDialog({
        header = '**Køb en ' .. label .. '**',
        content = 'Model: **' .. label .. '**\n\nNummerplade: **' .. plate .. '**\n\nPris: **' .. ESX.Math.GroupDigits(price) .. ',-**\n\nSælger: **' .. name .. '**\n\nØnsker at skrive under på købskontrakten?',
        centered = true,
        cancel = true
    })
	return alert
end)

AddEventHandler('eb_garage:ownedVehicles', function(data, area)
    local vehicles = lib.callback.await('eb_garage:getOwnedVehicles', false, data.GarageType, area)
    if not vehicles then
        print('Noget gik galt!')
        return
    end

    local options = {
        {title = 'Tilbage', menu = 'eb_garage:mainMenu'},
    }
    if #vehicles > 0 then
        for _, v in pairs(vehicles) do
            local fuelLevel = v.vehicleprops.fuelLevel
            local bodyHealth = v.vehicleprops.bodyHealth/10
            local engineHealth = v.vehicleprops.engineHealth/10
            table.insert(options, {
                title = v.label,
                icon = getClassIcon(GetVehicleClassFromName(v.vehicle)),
                description = v.numberplate,

                onSelect = function()
                    local foundSpawn, SpawnPoint = GetAvailableVehicleSpawnPoint(data.SpawnCoords)
                    lib.requestModel(v.vehicle)
                    local veh = CreateVehicle(v.vehicle, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z, SpawnPoint.w, true, true)
                    SetVehicleNumberPlateText(veh, v.numberplate)
                    lib.setVehicleProperties(veh, v.vehicleprops)
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    exports['t1ger_keys']:GiveTemporaryKeys(v.numberplate, GetLabelText(v.vehicle), 'Civil')
                    TriggerServerEvent('eb_garage:pullOutVehicle', v.numberplate)
                end,

                metadata = {
                    {label = 'Brændstof', value = fuelLevel .. '%', progress = fuelLevel},
                    {label = 'Køretøjets Helbred', value = bodyHealth .. '%', progress = bodyHealth},
                    {label = 'Motorens Helbred', value = engineHealth .. '%', progress = engineHealth},
                },
            })
        end
    else
        table.insert(options, {
            title = 'Ingen køretøjer fundet',
            icon = 'car',
            readOnly = true,
        })
    end

    lib.registerContext({
        id = 'eb_garage:ownedVehicles',
        title = 'Ejede Køretøjer',
        options = options,
    })
    lib.showContext('eb_garage:ownedVehicles')
end)

AddEventHandler('eb_garage:leasedVehicles', function(data, area)
    local vehicles = lib.callback.await('eb_garage:getLeasedVehicles', false, data.GarageType, area)
    if not vehicles then
        print('Noget gik galt!')
        return
    end

    local options = {
        {title = 'Tilbage', menu = 'eb_garage:mainMenu'},
    }
    if #vehicles > 0 then
        for _, v in pairs(vehicles) do
            local fuelLevel = v.vehicleprops.fuelLevel
            local bodyHealth = v.vehicleprops.bodyHealth/10
            local engineHealth = v.vehicleprops.engineHealth/10
            table.insert(options, {
                title = v.label,
                icon = getClassIcon(GetVehicleClassFromName(v.vehicle)),
                description = v.numberplate,

                onSelect = function()
                    local foundSpawn, SpawnPoint = GetAvailableVehicleSpawnPoint(data.SpawnCoords)
                    lib.requestModel(v.vehicle)
                    local veh = CreateVehicle(v.vehicle, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z, SpawnPoint.w, true, true)
                    SetVehicleNumberPlateText(veh, v.numberplate)
                    lib.setVehicleProperties(veh, v.vehicleprops)
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    exports['t1ger_keys']:GiveTemporaryKeys(v.numberplate, GetLabelText(v.vehicle), 'Civil')
                    TriggerServerEvent('eb_garage:pullOutVehicle', v.numberplate)
                end,

                metadata = {
                    {label = 'Brændstof', value = fuelLevel .. '%', progress = fuelLevel},
                    {label = 'Køretøjets Helbred', value = bodyHealth .. '%', progress = bodyHealth},
                    {label = 'Motorens Helbred', value = engineHealth .. '%', progress = engineHealth},
                },
            })
        end
    else
        table.insert(options, {
            title = 'Ingen køretøjer fundet',
            icon = 'car',
            readOnly = true,
        })
    end

    lib.registerContext({
        id = 'eb_garage:leasedVehicles',
        title = 'Leasede Køretøjer',
        options = options,
    })
    lib.showContext('eb_garage:leasedVehicles')
end)

function onEnter()
if IsPedInAnyVehicle(PlayerPedId(), false) then
    lib.showTextUI('[E] - Parker Køretøj')
end

end
 
function onExit()
    lib.hideTextUI()
end

function inside(self)
    local playerveh = GetVehiclePedIsIn(PlayerPedId())
    local plate = GetVehicleNumberPlateText(playerveh)
    local vehicleprops = lib.getVehicleProperties(playerveh)
    local area = Config.Garages[self.garage].Area 
    if IsControlJustReleased(1, 38) then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local parked = lib.callback.await('eb_garage:parkVeh', false, plate, vehicleprops, area)
            if parked then
                lib.hideTextUI()
                if self.data.GarageType == 'car' or self.data.GarageType == 'air' then
                    TaskLeaveVehicle(PlayerPedId(), playerveh, false)
                end
                lib.progressCircle({
                    duration = 1000,
                    label = 'Parkerer Køretøjet',
                    position = 'bottom',
                    canCancel = false,
                    disable = {
                        move = true,
                        combat = true
                    }
                })
                ESX.Game.DeleteVehicle(playerveh)
                if self.data.GarageType == 'boat' then
                    SetEntityCoordsNoOffset(PlayerPedId(), Config.Garages[self.garage].PedCoords)
                end
            end
        end
    end
end

function createParking(garage, data)
    lib.zones.sphere({
        coords = vec3(data.ParkCoords.x, data.ParkCoords.y, data.ParkCoords.z),
        radius = Config.ParkingCirkleRadius,
        debug = Config.Debug,
        onEnter = onEnter,
        inside = inside,
        onExit = onExit,
        garage = garage,
        data = data
    })
end

function GetAvailableVehicleSpawnPoint(SpawnCoords)
    local found, foundSpawnPoint = false, nil
    for i = 1, #SpawnCoords, 1 do
        if ESX.Game.IsSpawnPointClear(vec3(SpawnCoords[i].x, SpawnCoords[i].y, SpawnCoords[i].z), 5.0) then
            found, foundSpawnPoint = true, SpawnCoords[i]
            break
        end
    end
    if found then
        return true, foundSpawnPoint
    else
        Notify('Alle parkeringspladser er optaget!', 'error')
        return false
    end
end


function canRefresh(label, vehicle)
    if label == GetLabelText(vehicle) then
        return true
    else
        return false
    end
end

function getClassIcon(class)
    if class == 8 then
        return 'motorcycle'
    elseif class == 13 then
        return 'bicycle'
    elseif class == 14 then
        return 'ship'
    elseif class == 16 then
        return 'plane'
    elseif class == 15 then
        return 'helicopter'
    else
        return 'car'
    end
end

function isLeased(leased)
    if leased == 1 then
        return 'Ja'
    else
        return 'Nej'
    end
end

function Notify(desc, type)
    lib.notify({title = 'Garage', description = desc, type = type})
end

for garage, data in pairs(Config.Garages) do
    createBlip(data)
    createPed(garage, data)
    createParking(garage, data)
end