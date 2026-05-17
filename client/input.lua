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
            keybindOptions["defaultPrimary"],
        )

        if
            nil ~= keybindOptions["defaultSecondary"]
            and "" ~= keybindOptions["defaultSecondary"]
        then
            RegisterKeyMapping(
                "~!+" .. command,
                keybindOptions["description"],
                keybindOptions["mapper"],
                keybindOptions["defaultSecondary"],
            )
        end
    end
end

function Input.isPressed(inputName)
    return true == inputStore[inputName]["isPressed"]
end
