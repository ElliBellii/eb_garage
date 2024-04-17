Config = {}

Config.Debug = false
Config.ParkingCirkleRadius = 10

Config.EnableKick = true
Config.KickMessage = 'SERVER KICK | Forsøg på udnyttelse af exploit. Informatinen er vidersendt til staffs.'

Config.EnableVehicleRename = true
Config.EnableVehicleSell = true 

Config.Blips = {
    Vehicle = {label = 'Garage', sprite = 357, color = 3},
    Boat = {label = 'Båd Garage', sprite = 356, color = 3},
    Air = {label = 'Fly Garage', sprite = 359, color = 3},
    Impound = {label = 'Impound', sprite = 67, color = 17}
}

Config.Garages = {
    ['Midtby Garage'] = {
        Blip = true,
        Area = 'Los Santos', -- Los Santos / Sandy / Paleto
        PedType = 'a_m_m_eastsa_01',
        Anim = 'WORLD_HUMAN_CLIPBOARD', -- Set to false if you dont want an animation
        GarageType = 'car', -- car / boat / air
        PedCoords = vector4(215.6502, -808.8042, 29.7518, 249.6624),
        SpawnCoords = {
            vector4(222.1528, -801.1656, 30.6803, 245.7919),
            vector4(223.4908, -799.1122, 30.6646, 243.9638),
            vector4(224.6672, -796.5347, 30.6661, 245.7299),
            vector4(226.1472, -794.1620, 30.6617, 246.3315),
        },
        ParkCoords = vector3(221.3655, -797.1567, 30.7067)
    },

    ['Strand Båd Garage'] = { 
        Blip = true,
        Area = 'Los Santos',
        PedType = 'a_m_m_eastsa_01',
        Anim = 'WORLD_HUMAN_CLIPBOARD',
        GarageType = 'boat',
        PedCoords = vector4(-1799.6493, -1224.4696, 0.5915, 141.7025),
        SpawnCoords = {
            vector4(-1795.4404, -1230.0558, 0.4583, 145.9147),
        },
        ParkCoords = vector3(-1795.4404, -1230.0558, 0.4583)
    },

    ['Lufthavn Fly Garage'] = {
        Blip = true,
        Area = 'Los Santos',
        PedType = 'a_m_m_eastsa_01',
        Anim = 'WORLD_HUMAN_CLIPBOARD',
        GarageType = 'air',
        PedCoords = vector4(-941.1562, -2954.1006, 12.9451, 147.8355),
        SpawnCoords = {
            vector4(-975.7167, -2983.5125, 13.9451, 60.1634),
        },
        ParkCoords = vector3(-975.7167, -2983.5125, 13.9451)
    },
}

Config.Impounds = {
    ['LS Impound'] = {
        Blip = true,
        Area = 'Los Santos', -- Los Santos / Sandy / Paleto
        ImpoundPrice = 5000,
        PedType = 'a_m_m_eastsa_01',
        Anim = 'WORLD_HUMAN_CLIPBOARD',
        PedCoords = vector4(408.9800, -1622.8365, 28.2919, 228.3117),
        SpawnCoords = {
            vector4(417.3595, -1627.3495, 29.2920, 140.0973),
            vector4(419.7216, -1629.4348, 29.2919, 136.7958),
            vector4(421.5926, -1635.8932, 29.2919, 87.0105),
            vector4(421.5261, -1639.0452, 29.2924, 90.5996),
        }
    },
}