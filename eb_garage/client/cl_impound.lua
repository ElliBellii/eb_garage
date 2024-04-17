function createImpoundBlip(data)
    if data.Blip then
        local blip = AddBlipForCoord(data.PedCoords) 
        SetBlipSprite(blip, Config.Blips.Impound.sprite)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, Config.Blips.Impound.color)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Blips.Impound.label)
        EndTextCommandSetBlipName(blip)
    end
end

function createImpoundPed(impound, data)
    lib.requestModel(data.PedType) 
    local ped = CreatePed(1, data.PedType, data.PedCoords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, data.Anim, 0, true)

    local options = {
        {
            name = 'eb_garage:impoundTarget',
            label = 'Tilgå ' .. impound,
            onSelect = function()
                local area = Config.Impounds[impound].Area
                TriggerEvent('eb_garage:impoundMenu', data, area)
            end,
        },
    }
    exports.ox_target:addLocalEntity(ped, options)
end

AddEventHandler('eb_garage:impoundMenu', function(data, area)
    local vehicles = lib.callback.await('eb_garage:getImpoundedVehicles', false)
    if not vehicles then
        print('Noget gik galt!')
        return
    end
    local options = {}

    if #vehicles > 0 then
        for _, v in pairs(vehicles) do
            local fuelLevel = v.vehicleprops.fuelLevel
            local bodyHealth = v.vehicleprops.bodyHealth/10
            local engineHealth = v.vehicleprops.engineHealth/10
            table.insert(options, {
                title = v.label .. ' | ' .. v.numberplate,
                icon = getClassIcon(GetVehicleClassFromName(v.vehicle)),
                description = 'Det koster ' .. ESX.Math.GroupDigits(data.ImpoundPrice) .. ',- at få køretøjet ud',

                onSelect = function()
                    local alert = lib.alertDialog({
                        header = '**Udlevering af ' .. v.label .. '**',
                        content = 'Ønsker du at betale **' .. ESX.Math.GroupDigits(data.ImpoundPrice) .. ',-** for at få din ' .. v.label .. ' udleveret?',
                        centered = true,
                        cancel = true
                    })

                    if alert == 'confirm' then
                        local released = lib.callback.await('eb_garage:releasedVeh', false, v.numberplate, data.ImpoundPrice, v.vehtype, area)
                        if released then
                            if v.vehtype == 'car' then
                                local foundSpawn, SpawnPoint = GetAvailableVehicleSpawnPoint(data.SpawnCoords)
                                lib.requestModel(v.vehicle)
                                local veh = CreateVehicle(v.vehicle, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z, SpawnPoint.w, true, true)
                                SetVehicleNumberPlateText(veh, v.numberplate)
                                lib.setVehicleProperties(veh, v.vehicleprops)
                                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                exports['t1ger_keys']:GiveTemporaryKeys(v.numberplate, GetLabelText(v.vehicle), 'Civil')
                            end
                        end
                    else
                        lib.showContext('eb_garage:impoundMenu')
                    end
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
            readOnly = true,
        })
    end

    lib.registerContext({
        id = 'eb_garage:impoundMenu',
        title = 'Impounded Køretøjer',
        options = options,
    })
    lib.showContext('eb_garage:impoundMenu')
end)

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

function Notify(desc, type)
    lib.notify({title = 'Garage', description = desc, type = type})
end

for impound, data in pairs(Config.Impounds) do
    createImpoundBlip(data)
    createImpoundPed(impound, data)
end