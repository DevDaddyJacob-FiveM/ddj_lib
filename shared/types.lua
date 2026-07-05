Types = {}
Types.__index = Types

Types.__standardTypes = {
    ["nil"] = true,
    ["boolean"] = true,
    ["number"] = true,
    ["string"] = true,
    ["function"] = true,
    ["table"] = true,
}


function Types.__hasSuffix(str, suffix)
    return str:sub(-#suffix) == suffix
end


function Types.__removeSuffix(str, suffix)
    return str:sub(0, -#suffix - 1)
end


function Types.check(expectedType, value)
    -- Handle standard types
    if true == Types.__standardTypes[expectedType] then
        return type(value) == expectedType
    end


    -- Handle nullable types
    if Types.__hasSuffix(expectedType, "?") then
        local newType = Types.__removeSuffix(expectedType, "?")
        
        return value == nil or Types.check(newType, value)
    end


    -- Handle array types
    if Types.__hasSuffix(expectedType, "[]") then
        local newType = Types.__removeSuffix(expectedType, "[]")
        
        if "table" ~= type(value) then
            return false
        end

        for key, _value in pairs(value) do
            if "number" ~= type(key) then
                return false
            end

            if not Types.check(newType, _value) then
                return false
            end
        end

        return true
    end

    return nil
end