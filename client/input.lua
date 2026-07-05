local inputStore = {}
Input = {}

function Input.registerInput(inputName, command, keybindOptions)
    if nil ~= inputStore[inputName] then
        logger.warn("attempted to register input \"%s\" when it was already registered", inputName)
        return
    end

    inputStore[inputName] = {}
    inputStore[inputName]["isPressed"] = false
    inputStore[inputName]["data"] = {
        command = command,
        keybindOptions = keybindOptions
    }

    RegisterCommand("+" .. command, function()
        inputStore[inputName]["isPressed"] = true
    end)

    RegisterCommand("-" .. command, function()
        inputStore[inputName]["isPressed"] = false
    end)

    if nil ~= keybindOptions then
        RegisterKeyMapping(
            "+" .. command,
            keybindOptions["description"],
            keybindOptions["mapper"],
            keybindOptions["defaultPrimary"]
        )

        if
            nil ~= keybindOptions["defaultSecondary"]
            and "" ~= keybindOptions["defaultSecondary"]
        then
            RegisterKeyMapping(
                "~!+" .. command,
                keybindOptions["description"],
                keybindOptions["mapper"],
                keybindOptions["defaultSecondary"]
            )
        end
    end
end


function Input.isPressed(inputName)
    return true == inputStore[inputName]["isPressed"]
end


function Input.getCommandInputString(cmd)
    local hexStr = ("%x"):format(joaat(cmd))
    local formattedHex = hexStr:sub(-8):upper()

    return "INPUT_" .. formattedHex
end


function Input.getUserInputAsync(key, title, default, maxLength)
    AddTextEntry(key, title .. ":\t(Max " .. maxLength .. " Characters)")
    DisplayOnscreenKeyboard(1, key, "", default, "", "", "", maxLength)

    Citizen.Wait(0)

    while true do
        local keyboardStatus = UpdateOnscreenKeyboard()

        if 3 == keyboardStatus or 2 == keyboardStatus then
            return nil
        end
        
        if 1 == keyboardStatus then
            return GetOnscreenKeyboardResult()
        end

        Citizen.Wait(0)
    end
end