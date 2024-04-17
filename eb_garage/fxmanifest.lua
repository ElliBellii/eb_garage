fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Garage system made my EB Scripting'
author 'https://discord.gg/CBFGCTEEAW'
version '1.0.0'

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'shared/logs.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared/config.lua'
}