--Metadata
fx_version 'bodacious'
games {'gta5'}

author 'Cengizhan & Oguzhan'
description 'ESX Bus Job'
version '1.2.0'

client_scripts {
    '@es_extended/locale.lua',
    'config.lua',
    'locales/en.lua',
    'locales/tr.lua',
    'client/main.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'config.lua',
	'@mysql-async/lib/MySQL.lua',
    'locales/en.lua',
    'locales/tr.lua',
    'server/server.lua'
}