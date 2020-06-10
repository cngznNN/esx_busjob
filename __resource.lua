resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

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