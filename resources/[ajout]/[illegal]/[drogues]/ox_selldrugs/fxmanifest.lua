fx_version 'cerulean'

game 'gta5'

client_scripts{    
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'config.lua',
    'client.lua',
}

server_scripts{
    'config.lua',
    'server.lua',
}

shared_script '@es_extended/imports.lua'