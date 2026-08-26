-- Copy of the FiveM built in baseevents with our events piped in instead
local isInVehicle = false
local isEnteringVehicle = false
local currentVehicle = 0
local currentSeat = 0

local function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if GetPedInVehicleSeat(vehicle, i) == ped then
            return i
        end
    end

    return -2
end

local function initLocalVehTracking()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local ped = PlayerPedId()

            if not isInVehicle and not IsPlayerDead(PlayerId()) then
                if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
                    -- trying to enter a vehicle!
                    local vehicle = GetVehiclePedIsTryingToEnter(ped)
                    local seat = GetSeatPedIsTryingToEnter(ped)
                    local netId = VehToNet(vehicle)
                    isEnteringVehicle = true
                    TriggerServerEvent('DevDaddyJacob:Lib:Events:Server:OnEnteringVehicle', vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), netId)
                elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
                    -- vehicle entering aborted
                    TriggerServerEvent('DevDaddyJacob:Lib:Events:Server:OnAbortEnteringVehicle')
                    isEnteringVehicle = false
                elseif IsPedInAnyVehicle(ped, false) then
                    -- suddenly appeared in a vehicle, possible teleport
                    isEnteringVehicle = false
                    isInVehicle = true
                    currentVehicle = GetVehiclePedIsUsing(ped)
                    currentSeat = GetPedVehicleSeat(ped)
                    local model = GetEntityModel(currentVehicle)
                    local name = GetDisplayNameFromVehicleModel()
                    local netId = VehToNet(currentVehicle)
                    TriggerServerEvent('DevDaddyJacob:Lib:Events:Server:OnEnteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
                end
            elseif isInVehicle then
                if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) then
                    -- bye, vehicle
                    local model = GetEntityModel(currentVehicle)
                    local name = GetDisplayNameFromVehicleModel()
                    local netId = VehToNet(currentVehicle)
                    TriggerServerEvent('DevDaddyJacob:Lib:Events:Server:OnLeftVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
                    isInVehicle = false
                    currentVehicle = 0
                    currentSeat = 0
                end
            end
            Citizen.Wait(50)
        end
    end)
end


-- Init
Citizen.CreateThread(function()
    logger:debug("initializing vehicle events module")

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
            logger:debug("finished initializing vehicle events module")
            return
        end
    end


    -- If baseevents isn't running, roll our copy of the handling logic
    initLocalVehTracking()

    logger:debug("finished initializing vehicle events module")
end)


--[[
    Usage demo:

    RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnEnteringVehicle", function(vehicle, seat, displayName, vehNetId)
        print("<OnEnteringVehicle>", vehicle, seat, displayName, vehNetId)
    end)

    RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnAbortEnteringVehicle", function()
        print("<OnAbortEnteringVehicle>")
    end)

    RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnEnteredVehicle", function(vehicle, seat, displayName, vehNetId)
        print("<OnEnteredVehicle>", vehicle, seat, displayName, vehNetId)
    end)

    RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnLeftVehicle", function(vehicle, seat, displayName, vehNetId)
        print("<OnLeftVehicle>", vehicle, seat, displayName, vehNetId)
    end)
]]
