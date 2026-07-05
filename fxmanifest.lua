fx_version "cerulean"
lua54 "yes"
game "gta5"
use_experimental_fxv2_oal "yes"

author "DevDaddyJacob"
description "DevDaddyJacob's common FiveM libraries"
version "1.2.0"

shared_scripts {
	"shared/dataview.lua",
	"shared/logging.lua",
	"shared/types.lua",
}

client_scripts {
	"client/gizmo.lua",
	"client/input.lua",
	"client/rpc.lua",
}

server_scripts {
	"server/rpc.lua",
}

files {
	"imports/rpc.lua",
}