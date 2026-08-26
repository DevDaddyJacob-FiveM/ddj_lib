local function onEnteringVehicle(player, vehicle, seat, displayName, vehNetId)
    TriggerClientEvent(
        "DevDaddyJacob:Lib:Events:Client:OnEnteringVehicle",
        player,
        vehicle,
        seat,
        displayName,
        vehNetId
    )
end

local function onAbortEnteringVehicle(player)
    TriggerClientEvent("DevDaddyJacob:Lib:Events:Client:OnAbortEnteringVehicle", player)
end

local function onEnteredVehicle(player, vehicle, seat, displayName, vehNetId)
    TriggerClientEvent(
        "DevDaddyJacob:Lib:Events:Client:OnEnteredVehicle",
        player,
        vehicle,
        seat,
        displayName,
        vehNetId
    )
end

local function onLeftVehicle(player, vehicle, seat, displayName, vehNetId)
    TriggerClientEvent(
        "DevDaddyJacob:Lib:Events:Client:OnLeftVehicle",
        player,
        vehicle,
        seat,
        displayName,
        vehNetId
    )
end


-- Init
Citizen.CreateThread(function()
    logger:debug("initializing vehicle events module")

    -- Define the event mapping
    local eventMapping = {
        enteringVehicle = {
            baseeventsEvent = "baseevents:enteringVehicle",
            ddjEvent = "DevDaddyJacob:Lib:Events:Server:OnEnteringVehicle",
            ddjFunc = onEnteringVehicle
        },
        enteringAborted = {
            baseeventsEvent = "baseevents:enteringAborted",
            ddjEvent = "DevDaddyJacob:Lib:Events:Server:OnAbortEnteringVehicle",
            ddjFunc = onAbortEnteringVehicle
        },
        enteredVehicle = {
            baseeventsEvent = "baseevents:enteredVehicle",
            ddjEvent = "DevDaddyJacob:Lib:Events:Server:OnEnteredVehicle",
            ddjFunc = onEnteredVehicle
        },
        leftVehicle = {
            baseeventsEvent = "baseevents:leftVehicle",
            ddjEvent = "DevDaddyJacob:Lib:Events:Server:OnLeftVehicle",
            ddjFunc = onLeftVehicle
        },
    }


    if false == Config["DisableBaseEventsHook"] then
        -- If base events is starting, wait until it's not starting
        local retryCount = 0
        while 10 > retryCount and "starting" == GetResourceState("baseevents") do
            logger:debug("resource 'baseevents' starting, waiting...")

            Citizen.Wait(500)
            retryCount = retryCount + 1
        end

        if 10 <= retryCount then
            logger:fatal("resource 'baseevents' took too long to start!")
            return
        end


        -- Hook into the events from baseevents
        if "started" == GetResourceState("baseevents") then
            for key, value in pairs(eventMapping) do
                logger:trace("hooking into baseevents event '%s'", value.baseeventsEvent)

                RegisterNetEvent(value.baseeventsEvent, function(...)
                    value.ddjFunc(source, ...)
                end)
            end

            logger:debug("finished hooking into resource 'baseevents'")
        end
    end

    for key, value in pairs(eventMapping) do
        logger:trace("registering event '%s'", value.ddjEvent)
        RegisterNetEvent(value.ddjEvent, function(...)
            value.ddjFunc(source, ...)
        end)
    end

    logger:debug("finished initializing vehicle events module")
end)
