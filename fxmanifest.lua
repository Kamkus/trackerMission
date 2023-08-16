fx_version 'cerulean'

game 'gta5'

version '1.0.0'

description 'Created By Kamkus'

lua54 'yes'
use_fxv2_oal 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua'
}

client_scripts {'client/main.lua'}

server_scripts {'server/main.lua'}