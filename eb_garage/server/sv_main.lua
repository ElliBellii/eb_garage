lib.callback.register('eb_garage:getAllVehicles', function(source, vehtype)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rawdata = MySQL.Sync.fetchAll('SELECT * FROM ebowned_vehicles WHERE owner = ? AND vehtype = ?', {xPlayer.getIdentifier(), vehtype})

    if rawdata then
        local vehicles = {}
        for _, data in pairs(rawdata) do
            table.insert(vehicles, {
                label = data.label,
                vehicle = data.vehicle,
                area = data.area,
                vehicleprops = json.decode(data.vehicleprops),
                numberplate = data.numberplate,
                leased = data.leased
            })
        end
        return vehicles
    end
end)

RegisterNetEvent('eb_garage:changeName', function(plate, newName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local owner = MySQL.Sync.fetchScalar('SELECT owner FROM ebowned_vehicles WHERE numberplate = ?', {plate})

    if owner then
        if owner == xPlayer.getIdentifier() then
            MySQL.Async.execute('UPDATE ebowned_vehicles SET label = ? WHERE numberplate = ?', {newName, plate})
            Notify(source, 'Du ændrede køretøjets navn til ' .. newName, 'success')
        else
            if Config.EnableKick then
                DropPlayer(source, Config.KickMessage)
            end
            if Logs.EnableLogs then
                local message =
                '**En spiller prøvede at ændre navn på et køretøj, som han ikke ejede**\n\n' ..
                '**Navn:** ' .. xPlayer.getName() .. '\n' ..
                '**Identifier:** ' .. xPlayer.getIdentifier() .. '\n' ..
                '**ID:** ' .. source .. '\n' ..
                '**Nummerplade:** ' .. plate .. '\n'
            
                DiscordLog(message)
            end
        end
    end
end)

RegisterNetEvent('eb_garage:requestBuyer', function(target, price, label, plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    local owner = MySQL.Sync.fetchScalar('SELECT owner FROM ebowned_vehicles WHERE numberplate = ?', {plate})

    if owner then
        if owner == xPlayer.getIdentifier() then
            Notify(source, 'Anmodning sendt til ' .. xTarget.getName(), 'success')
            local accepted = lib.callback.await('eb_garage:sendRequest', target, price, label, plate, xPlayer.getName())

            if accepted == 'confirm' then
                if xTarget.getAccount('bank').money >= price then
                    xTarget.removeAccountMoney('bank', price)
                    xPlayer.addAccountMoney('bank', price)
                    MySQL.Async.execute('UPDATE ebowned_vehicles SET owner = ?, label = ? WHERE numberplate = ?', {xTarget.getIdentifier(), label, plate})
                    Notify(source, xTarget.getName() .. ' købte din ' .. label .. ' for ' .. ESX.Math.GroupDigits(price) .. ',-', 'success')
                    Notify(target, 'Du købte en ' .. label .. ' for ' .. ESX.Math.GroupDigits(price) .. ',-', 'success')
                else
                    local need = price - xTarget.getAccount('bank').money
                    Notify(source, xTarget.getName() .. ' har ikke penge nok til at købe din ' .. label, 'error')
                    Notify(target, 'Du mangler ' .. ESX.Math.GroupDigits(need) .. ',- for at kunne købe en ' .. label, 'error')
                end
            else
                Notify(source, xTarget.getName() .. ' afviste dit tilbud!', 'error')
            end
        else
            if Config.EnableKick then
                DropPlayer(source, Config.KickMessage)
            end
            if Logs.EnableLogs then
                local message =
                '**En spiller prøvede at sælge et køretøj, som han ikke ejede**\n\n' ..
                '**Navn:** ' .. xPlayer.getName() .. '\n' ..
                '**Identifier:** ' .. xPlayer.getIdentifier() .. '\n' ..
                '**ID:** ' .. source .. '\n' ..
                '**Køretøj:** ' .. label .. '\n' ..
                '**Nummerplade:** ' .. plate .. '\n' ..
                '**Pris:** ' .. ESX.Math.GroupDigits(price) .. '\n' ..
                '**Køber ID:** ' .. target .. '\n'            
                DiscordLog(message)
            end
        end
    end
end)

lib.callback.register('eb_garage:getOwnedVehicles', function(source, vehtype, area)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rawdata = MySQL.Sync.fetchAll('SELECT * FROM ebowned_vehicles WHERE owner = ? AND vehtype = ? AND area = ? AND leased = ? AND parked = ?', {xPlayer.getIdentifier(), vehtype, area, 0, 1})

    if rawdata then
        local vehicles = {}
        for _, data in pairs(rawdata) do
            table.insert(vehicles, {
                label = data.label,
                vehicle = data.vehicle,
                vehicleprops = json.decode(data.vehicleprops),
                numberplate = data.numberplate
            })
        end
        return vehicles
    end
end)

lib.callback.register('eb_garage:getLeasedVehicles', function(source, vehtype, area)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rawdata = MySQL.Sync.fetchAll('SELECT * FROM ebowned_vehicles WHERE owner = ? AND vehtype = ? AND area = ? AND leased = ? AND parked = ?', {xPlayer.getIdentifier(), vehtype, area, 1, 1})

    if rawdata then
        local vehicles = {}
        for _, data in pairs(rawdata) do
            table.insert(vehicles, {
                label = data.label,
                vehicle = data.vehicle,
                vehicleprops = json.decode(data.vehicleprops),
                numberplate = data.numberplate
            })
        end
        return vehicles
    end
end)

RegisterNetEvent('eb_garage:pullOutVehicle', function(plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local owner = MySQL.Sync.fetchScalar('SELECT owner FROM ebowned_vehicles WHERE numberplate = ?', {plate})
    
    if owner then
        if owner == xPlayer.getIdentifier() then
            MySQL.Async.execute('UPDATE ebowned_vehicles SET parked = ?, impounded = ?, area = ? WHERE numberplate = ?', {0, 1, 'Ude', plate})
            Notify(source, 'Du trak et køretøj ud af garagen', 'success')
        else
            if Config.EnableKick then
                DropPlayer(source, Config.KickMessage)
            end
            if Logs.EnableLogs then
                local message =
                '**En spiller prøvede at tage et køretøj ud af garagen, som han ikke ejede**\n\n' ..
                '**Navn:** ' .. xPlayer.getName() .. '\n' ..
                '**Identifier:** ' .. xPlayer.getIdentifier() .. '\n' ..
                '**ID:** ' .. source .. '\n' ..
                '**Nummerplade:** ' .. plate .. '\n'            
                DiscordLog(message)
            end
        end
    end
end)

lib.callback.register('eb_garage:getImpoundedVehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rawdata = MySQL.Sync.fetchAll('SELECT * FROM ebowned_vehicles WHERE owner = ? AND impounded = ? AND parked = ?', {xPlayer.getIdentifier(), 1, 0})
    
    if rawdata then
        local vehicles = {}
        for _, data in pairs(rawdata) do
            table.insert(vehicles, {
                label = data.label,
                vehicle = data.vehicle,
                vehicleprops = json.decode(data.vehicleprops),
                numberplate = data.numberplate,
                vehtype = data.vehtype
            })
        end
        return vehicles
    end
end)

lib.callback.register('eb_garage:releasedVeh', function(source, plate, price, vehtype, area)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getAccount('bank').money >= price then
        xPlayer.removeAccountMoney('bank', price)
        if vehtype == 'car' then
            MySQL.Async.execute('UPDATE ebowned_vehicles SET parked = ?, impounded = ? WHERE numberplate = ?', {0, 0, plate})
            Notify(source, 'Du hentede dit køretøj fra impound', 'success')
        else
            MySQL.Async.execute('UPDATE ebowned_vehicles SET parked = ?, impounded = ?, area = ? WHERE numberplate = ?', {1, 0, area, plate})
            Notify(source, 'Dit køretøj kan findes i en garge i dette område (' .. area .. ')', 'success')
        end
        return true
    else
        local need = price - xPlayer.getAccount('bank').money
        Notify(source, 'Du mangler ' .. ESX.Math.GroupDigits(need) .. ',-', 'error')
        return false
    end
end)

lib.callback.register('eb_garage:parkVeh', function(source, plate, vehicleprops, area)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local owner = MySQL.Sync.fetchScalar('SELECT owner FROM ebowned_vehicles WHERE numberplate = ?', {plate})

    if owner then
        if owner == xPlayer.getIdentifier() then
            MySQL.Async.execute('UPDATE ebowned_vehicles SET parked = ?, impounded = ?, area = ?, vehicleprops = ? WHERE numberplate = ?', {1, 0, area, json.encode(vehicleprops), plate})
            Notify(source, 'Du parkerede dit køretøj i garagen', 'success')
            return true
        else
            Notify(source, 'Du ejer ikke dette køretøj!', 'error')
            return false
        end
    end
end)

function DiscordLog(message)
    local embeds = {
        {
            ["title"] = 'EB Garage | Exploit Logs',
            ["description"] = message,
            ["color"] = 4162294,
            ["footer"] = {
                ["text"] = "EB Scripting | https://discord.gg/CBFGCTEEAW | " .. os.date("%d/%m/%Y %H:%M:%S"),
            },
        }
    }

    PerformHttpRequest(Logs.Webhook, function(err, text, headers) end, 'POST', json.encode({ username = name, embeds = embeds }), { ['Content-Type'] = 'application/json' })
end



function Notify(id, desc, type)
	TriggerClientEvent('ox_lib:notify', id, { title = 'Garage', description = desc, type = type})
end