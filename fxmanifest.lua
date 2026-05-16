fx_version "cerulean"
lua54 "yes"
game "gta5"
use_experimental_fxv2_oal "yes"

author "DevDaddyJacob"
description "DevDaddyJacob's common FiveM libraries"
version "1.0.0"

shared_scripts {
	"shared/logging.lua",
}

client_scripts {
	"client/rpc.lua",
}

server_scripts {
	"server/rpc.lua",
}

files {
	"imports/rpc.lua",
}