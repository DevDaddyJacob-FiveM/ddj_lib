fx_version "cerulean"
lua54 "yes"
game "gta5"
use_experimental_fxv2_oal "yes"

author "DevDaddyJacob"
description "DevDaddyJacob's common FiveM libraries"
version "1.3.0"

shared_scripts {
	"shared/logging.lua",
	"config.lua",
	"shared/dataview.lua",
	"shared/types.lua",
}

client_scripts {
	-- Start the internal scripts first
	"client/events/shared.lua",
	"client/events/vehicles.lua",

	"client/gizmo.lua",
	"client/input.lua",
	"client/rpc.lua",
}

server_scripts {
	-- Start the internal scripts first
	"server/events/shared.lua",
	"server/events/vehicles.lua",

	"server/versionCheck.lua",
	"server/rpc.lua",
}

files {
	"client/controls.lua",
	"client/drawText2DThisFrame.lua",
	"imports/rpc.lua",
}