--[[
    This file is a adapted version of the exisitng Gizmo implementation make by Demigod916,
    Andyy7666, and AvarianKnight, and is used under the GNU General Public License v3.0
    (https://github.com/Demigod916/object_gizmo/blob/main/LICENSE)

    CREDITS
        Demigod916: https://github.com/Demigod916/object_gizmo
        Andyyy7666: https://github.com/overextended/ox_lib/pull/453
        AvarianKnight: https://forum.cfx.re/t/allow-drawgizmo-to-be-used-outside-of-fxdk/5091845/8?u=demi-automatic

    
    LICENSE NOTICE:
        This file (gizmo.lua) is covered under the GNU General Public License v3.0
        outlined in https://github.com/Demigod916/object_gizmo/blob/main/LICENSE
]]

-- Dependency validation
if "ddj_lib" ~= GetCurrentResourceName() then
    if nil == DataView then
        error("Missing required dependency 'DataView'!")
    end

    local usingScaleformUI = nil ~= ScaleformUI
    print("Checking for ScaleformUI dependency:", usingScaleformUI)
    if not usingScaleformUI then
        print("[!] Missing optional dependency 'ScaleformUI'!")
    end
end



local function normalizeCoords(x, y, z)
    local length = math.sqrt(x * x + y * y + z * z)
    
    if length == 0 then
        return 0, 0, 0
    end

    return x / length, y / length, z / length
end



Gizmo = setmetatable({
    Modes = {
        TRANSLATE = 0,
        ROTATE = 1,
        SCALE = 2,
    },
    Commands = {
        SELECT = {
            PRESSED = "+gizmoSelect",
            RELEASED = "-gizmoSelect"
        },
        TRANSLATE = {
            PRESSED = "+gizmoTranslation",
            RELEASED = "-gizmoTranslation"
        },
        ROTATE = {
            PRESSED = "+gizmoRotation",
            RELEASED = "-gizmoRotation"
        },
        SCALE = {
            PRESSED = "+gizmoScale",
            RELEASED = "-gizmoScale"
        },
        LOCAL = {
            PRESSED = "+gizmoLocal",
            RELEASED = "-gizmoLocal"
        },
    },
    store = {},
    localMode = true,
    activeGizmo = nil,
    scaleEnabled = false,
}, Gizmo)
Gizmo.__index = Gizmo
Gizmo.__call = function()
    return "Gizmo"
end


function Gizmo.new(entityHandle)
    _Gizmo = setmetatable({
        _entityHandle = entityHandle,
        _mode = Gizmo.Modes.TRANSLATE,
        _isActive = false,
        _threadRunning = false,
        _isPed = nil,
    }, Gizmo)

    Gizmo.store[entityHandle] = _Gizmo

    return _Gizmo
end


function Gizmo.from(entityHandle)
    return Gizmo.store[entityHandle]
end


function Gizmo:isActive()
    return self._isActive
end


function Gizmo:destroy()
    local handle = self._entityHandle
    Citizen.Await(self:deactivateAsync())
    Gizmo.store[handle] = nil
end


function Gizmo:isPed()
    if self._isPed == nil then
        self._isPed = IsEntityAPed(self._entityHandle)
    end

    return self._isPed
end


function Gizmo:exists()
    return DoesEntityExist(self._entityHandle)
end


function Gizmo:position()
    return GetEntityCoords(self._entityHandle)
end


function Gizmo:rotation()
    return GetEntityRotation(self._entityHandle)
end


function Gizmo:matrix(view)
    if view == nil then
        local fwdVec, rightVec, upVec, pos = GetEntityMatrix(self._entityHandle)
        local _view = DataView.ArrayBuffer(60)
    
        _view:SetFloat32(0, rightVec[1])
            :SetFloat32(4, rightVec[2])
            :SetFloat32(8, rightVec[3])
            :SetFloat32(12, 0)
            :SetFloat32(16, fwdVec[1])
            :SetFloat32(20, fwdVec[2])
            :SetFloat32(24, fwdVec[3])
            :SetFloat32(28, 0)
            :SetFloat32(32, upVec[1])
            :SetFloat32(36, upVec[2])
            :SetFloat32(40, upVec[3])
            :SetFloat32(44, 0)
            :SetFloat32(48, pos[1])
            :SetFloat32(52, pos[2])
            :SetFloat32(56, pos[3])
            :SetFloat32(60, 1)
    
        return _view
    else
        local x1, y1, z1 = view:GetFloat32(16), view:GetFloat32(20), view:GetFloat32(24)
        local x2, y2, z2 = view:GetFloat32(0), view:GetFloat32(4), view:GetFloat32(8)
        local x3, y3, z3 = view:GetFloat32(32), view:GetFloat32(36), view:GetFloat32(40)
        local tx, ty, tz = view:GetFloat32(48), view:GetFloat32(52), view:GetFloat32(56)
    
        if not Gizmo.scaleEnabled then
            x1, y1, z1 = normalizeCoords(x1, y1, z1)
            x2, y2, z2 = normalizeCoords(x2, y2, z2)
            x3, y3, z3 = normalizeCoords(x3, y3, z3)
        end
    
        SetEntityMatrix(self._entityHandle,
            x1, y1, z1,
            x2, y2, z2,
            x3, y3, z3,
            tx, ty, tz
        )
    end
end


function Gizmo:activate()
    if self._isActive == true or self._threadRunning == true then
        return
    end
    
    Citizen.CreateThread(function()
        Gizmo.activeGizmo = self._entityHandle
        self._isActive = true
        self._threadRunning = true
        
        local inCursorMode = true
        EnterCursorMode()
        
        if self:isPed() then
            SetEntityAlpha(self._entityHandle, 200)
        else
            SetEntityDrawOutline(self._entityHandle, true)
        end

        if usingScaleformUI then
            ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(
                self:getInstructionButtons()
            )
        end

        while self._isActive == true and self:exists() do
            Citizen.Wait(0)

            -- Disable controls
            local disabledControls = {
                0, -- INPUT_NEXT_CAMERA
                14, -- INPUT_WEAPON_WHEEL_NEXT
                15, -- INPUT_WEAPON_WHEEL_PREV
                16, -- INPUT_SELECT_NEXT_WEAPON
                17, -- INPUT_SELECT_PREV_WEAPON
                23, -- INPUT_ENTER
                24, -- INPUT_ATTACK
                25, -- INPUT_AIM
                26, -- INPUT_LOOK_BEHIND
                140, -- INPUT_MELEE_ATTACK_LIGHT
                141, -- INPUT_MELEE_ATTACK_HEAVY
                142, -- INPUT_MELEE_ATTACK_ALTERNATE
                143, -- INPUT_MELEE_BLOCK
                157, -- INPUT_SELECT_WEAPON_UNARMED
                158, -- INPUT_SELECT_WEAPON_MELEE
                159, -- INPUT_SELECT_WEAPON_HANDGUN
                160, -- INPUT_SELECT_WEAPON_SHOTGUN
                161, -- INPUT_SELECT_WEAPON_SMG
                162, -- INPUT_SELECT_WEAPON_AUTO_RIFLE
                163, -- INPUT_SELECT_WEAPON_SNIPER
                164, -- INPUT_SELECT_WEAPON_HEAVY
                165, -- INPUT_SELECT_WEAPON_SPECIAL
                200, -- INPUT_FRONTEND_PAUSE_ALTERNATE
            }
            for i = 1, #disabledControls, 1 do
                DisableControlAction(0, disabledControls[i], true)
            end

            DisablePlayerFiring(PlayerId(), true)

            -- Allow the camera movement on right click hold
            if not IsDisabledControlPressed(0, 25) then
                if not inCursorMode then
                    EnterCursorMode()
                    inCursorMode = true
                end

                local cameraControls = {
                    1, -- INPUT_LOOK_LR
                    2, -- INPUT_LOOK_UD
                    12, -- INPUT_WEAPON_WHEEL_UD
                    13, -- INPUT_WEAPON_WHEEL_LR
                }
                for i = 1, #cameraControls, 1 do
                    DisableControlAction(0, cameraControls[i], true)
                end
            else
                if inCursorMode then
                    LeaveCursorMode()
                    inCursorMode = false
                end

                -- SetMouseCursorActiveThisFrame()
            end

            local matrix = self:matrix()
            local hasChanged = Citizen.InvokeNative(
                0xEB2EDCA2,
                matrix:Buffer(),
                'Editor1',
                Citizen.ReturnResultAnyway()
            )

            if hasChanged then
                self:matrix(matrix)
            end

            -- Handle escape key press
            if IsDisabledControlPressed(0, 200) then
                self:deactivateAsync()
            end
        end

        LeaveCursorMode()
        if self:exists() then
            if self:isPed() then
                SetEntityAlpha(self._entityHandle, 255)
            end
            SetEntityDrawOutline(self._entityHandle, false)
        end

        if usingScaleformUI then
            ScaleformUI.Scaleforms.InstructionalButtons:ClearButtonList()
        end

        Gizmo.activeGizmo = nil
        self._isActive = false
        self._threadRunning = false
    end)
end


function Gizmo:deactivateAsync()
    local _promise = promise.new()

    Citizen.CreateThread(function()
        if self._isActive == false then
            _promise:resolve()
            return
        end

        self._isActive = false
        while self._threadRunning == true do
            Citizen.Wait(0)
        end

        _promise:resolve()
    end)

    return _promise
end


function Gizmo:nextMode(pressed)
    if pressed == true then
        local nextMode = self._mode

        if self._mode == Gizmo.Modes.TRANSLATE then
            nextMode = Gizmo.Modes.ROTATE
    
        elseif self._mode == Gizmo.Modes.ROTATE then
            if Gizmo.scaleEnabled == true then
                nextMode = Gizmo.Modes.SCALE
            else
                nextMode = Gizmo.Modes.TRANSLATE
            end
    
        elseif self._mode == Gizmo.Modes.SCALE then
            nextMode = Gizmo.Modes.TRANSLATE
    
        end
    
        if nextMode == Gizmo.Modes.TRANSLATE then
            ExecuteCommand(Gizmo.Commands.TRANSLATE.PRESSED)
    
        elseif nextMode == Gizmo.Modes.ROTATE then
            ExecuteCommand(Gizmo.Commands.ROTATE.PRESSED)
    
        elseif nextMode == Gizmo.Modes.SCALE then
            ExecuteCommand(Gizmo.Commands.SCALE.PRESSED)
        
        end
    
        self._mode = nextMode
    else
        if self._mode == Gizmo.Modes.TRANSLATE then
            ExecuteCommand(Gizmo.Commands.TRANSLATE.RELEASED)
    
        elseif self._mode == Gizmo.Modes.ROTATE then
            ExecuteCommand(Gizmo.Commands.ROTATE.RELEASED)
    
        elseif self._mode == Gizmo.Modes.SCALE then
            ExecuteCommand(Gizmo.Commands.SCALE.RELEASED)
        
        end
    end
end


function Gizmo:getInstructionButtons()
    return {
        InstructionalButton.New(
            "Confirm",
            1,
            nil,
            nil,
            Input.getCommandInputString("+_propGizmoConfirm")
        ),
        InstructionalButton.New(
            "Cancel",
            1,
            nil,
            nil,
            Input.getCommandInputString("+_propGizmoCancel")
        ),
        InstructionalButton.New(
            "Toggle Local Gizmo",
            1,
            nil,
            nil,
            Input.getCommandInputString("+_propGizmoToggleLocal")
        ),
        InstructionalButton.New(
            "Cycle Mode",
            1,
            nil,
            nil,
            Input.getCommandInputString("+_propGizmoCycleMode")
        ),
        InstructionalButton.New("Move Camera", 1, -1, 25, -1),
        InstructionalButton.New(
            "Grab Gizmo",
            1,
            nil,
            nil,
            Input.getCommandInputString("+_propGizmoSelect")
        ),
    }
end


Citizen.CreateThread(function()
    -- Register gizmo keybindings
    RegisterKeyMapping("+_propGizmoCycleMode", "Cycles gizmo mode", "KEYBOARD", "1")
    
    RegisterCommand("+_propGizmoCycleMode", function()
        if Gizmo.activeGizmo == nil then
            return
        end
        
        Gizmo.from(Gizmo.activeGizmo):nextMode(true)
    end)
    
    RegisterCommand("-_propGizmoCycleMode", function()
        if Gizmo.activeGizmo == nil then
            return
        end
        
        Gizmo.from(Gizmo.activeGizmo):nextMode(false)
    end)
    

    RegisterKeyMapping("+_propGizmoToggleLocal", "Toggles local gizmo", "KEYBOARD", "2")

    RegisterCommand("+_propGizmoToggleLocal", function()
        if Gizmo.activeGizmo == nil then
            return
        end
        
        Gizmo.localMode = not Gizmo.localMode
        ExecuteCommand(Gizmo.Commands.LOCAL.PRESSED)
    end)

    RegisterCommand("-_propGizmoToggleLocal", function()
        if Gizmo.activeGizmo == nil then
            return
        end

        ExecuteCommand(Gizmo.Commands.LOCAL.RELEASED)
    end)
    

    RegisterKeyMapping("+_propGizmoSelect", "Interact with the gizmo", "MOUSE_BUTTON", "MOUSE_LEFT")
    
    RegisterCommand("+_propGizmoSelect", function()
        if Gizmo.activeGizmo == nil then
            return
        end

        ExecuteCommand(Gizmo.Commands.SELECT.PRESSED)
    end)
    
    RegisterCommand("-_propGizmoSelect", function()
        if Gizmo.activeGizmo == nil then
            return
        end

        ExecuteCommand(Gizmo.Commands.SELECT.RELEASED)
    end)
    

    RegisterKeyMapping("+_propGizmoCancel", "Cancel the current gizmo", "KEYBOARD", "BACK")
    
    RegisterCommand("+_propGizmoCancel", function()
        if Gizmo.activeGizmo == nil then
            return
        end

        Gizmo.from(Gizmo.activeGizmo):destroy()
    end)
    
    RegisterCommand("-_propGizmoCancel", function()
        if Gizmo.activeGizmo == nil then
            return
        end
    end)
    

    RegisterKeyMapping("+_propGizmoConfirm", "Confirm the current gizmo", "KEYBOARD", "RETURN")
    
    RegisterCommand("+_propGizmoConfirm", function()
        if Gizmo.activeGizmo == nil then
            return
        end

        Gizmo.from(Gizmo.activeGizmo):destroy()
    end)
    
    RegisterCommand("-_propGizmoConfirm", function()
        if Gizmo.activeGizmo == nil then
            return
        end
    end)
end)