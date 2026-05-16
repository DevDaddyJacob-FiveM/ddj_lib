local LogLevel = {}
LogLevel.OFF = 0
LogLevel.FATAL = 100
LogLevel.ERROR = 200
LogLevel.WARN = 300
LogLevel.INFO = 400
LogLevel.DEBUG = 500
LogLevel.TRACE = 600
LogLevel.ALL = math.maxinteger

local Logger = {}
Logger._level = LogLevel.INFO
Logger._overrideConvar = false
Logger._resourceIdentifier = GetCurrentResourceName() or "DevDaddyJacob"

local function fetchLogLevelConvar()
    local globalConvar = "ddj_log_level"
    local resourceConvar = globalConvar .. Logger._resourceIdentifier

    local rawResourceLevel = GetConvar(resourceConvar, "UNKNOWN")
    if "OFF" == rawResourceLevel then return LogLevel.OFF end
    if "FATAL" == rawResourceLevel then return LogLevel.FATAL end
    if "ERROR" == rawResourceLevel then return LogLevel.ERROR end
    if "WARN" == rawResourceLevel then return LogLevel.WARN end
    if "INFO" == rawResourceLevel then return LogLevel.INFO end
    if "DEBUG" == rawResourceLevel then return LogLevel.DEBUG end
    if "TRACE" == rawResourceLevel then return LogLevel.TRACE end

    local resourceLevel = GetConvarInt(resourceConvar, -1)
    if -1 ~= resourceLevel then
        return resourceLevel
    end

    
    local rawGlobalLevel = GetConvar(globalConvar, "UNKNOWN")
    if "OFF" == rawGlobalLevel then return LogLevel.OFF end
    if "FATAL" == rawGlobalLevel then return LogLevel.FATAL end
    if "ERROR" == rawGlobalLevel then return LogLevel.ERROR end
    if "WARN" == rawGlobalLevel then return LogLevel.WARN end
    if "INFO" == rawGlobalLevel then return LogLevel.INFO end
    if "DEBUG" == rawGlobalLevel then return LogLevel.DEBUG end
    if "TRACE" == rawGlobalLevel then return LogLevel.TRACE end

    local globalLevel = GetConvarInt(globalConvar, -1)
    if -1 ~= globalLevel then
        return globalLevel
    end

    return nil
end

local function canLogLevel(targetLevel)
    local level = Logger.getLogLevel()

    if LogLevel.OFF == level then
        return false
    end

    if LogLevel.ALL == level then
        return true
    end

    return targetLevel <= level
end

local function printInternal(level, prefix, message)
    if not canLogLevel(level) then
        return
    end

    local fullMsg = "[" .. Logger._resourceIdentifier .. "]"

    if nil ~= prefix then
        fullMsg = fullMsg .. " " .. prefix .. ": "
    end

    print(fullMsg .. message)
end

function Logger.getLogLevel()
    if Logger._overrideConvar then
        return Logger._level
    end

    local convarLevel = fetchLogLevelConvar()
    if nil ~= convarLevel then
        return convarLevel
    end

    return LogLevel.INFO
end

function Logger.setLogLevel(level)
    if nil == level then
        Logger._overrideConvar = false
        return
    end

    Logger._level = level
    Logger._overrideConvar = true
end

function Logger.setResourceIdentifier(ident)
    if nil == ident then
        Logger._resourceIdentifier = GetCurrentResourceName() or "DevDaddyJacob"
        return
    end

    Logger._resourceIdentifier = ident
end

function Logger.fatal(message, ...)
    printInternal(LogLevel.FATAL, "FATAL", string.format(message, ...))
end

function Logger.fatalIf(condition, message, ...)
    if condition then
        Logger.fatal(message, ...)
    end
end

function Logger.error(message, ...)
    printInternal(LogLevel.ERROR, "ERROR", string.format(message, ...))
end

function Logger.errorIf(condition, message, ...)
    if condition then
        Logger.error(message, ...)
    end
end

function Logger.warn(message, ...)
    printInternal(LogLevel.WARN, "WARN", string.format(message, ...))
end

function Logger.warnIf(condition, message, ...)
    if condition then
        Logger.warn(message, ...)
    end
end

function Logger.info(message, ...)
    printInternal(LogLevel.INFO, "INFO", string.format(message, ...))
end

function Logger.infoIf(condition, message, ...)
    if condition then
        Logger.info(message, ...)
    end
end

function Logger.debug(message, ...)
    printInternal(LogLevel.DEBUG, "DEBUG", string.format(message, ...))
end

function Logger.debugIf(condition, message, ...)
    if condition then
        Logger.debug(message, ...)
    end
end

function Logger.trace(message, ...)
    printInternal(LogLevel.TRACE, "TRACE", string.format(message, ...))
end

function Logger.traceIf(condition, message, ...)
    if condition then
        Logger.trace(message, ...)
    end
end

function Logger.custom(logLevel, message, ...)
    printInternal(logLevel, nil, string.format(message, ...))
end

function Logger.customIf(condition, logLevel, message, ...)
    if condition then
        Logger.custom(logLevel, message, ...)
    end
end

exports("getLogLevels", function()
    return LogLevel
end)

exports("getLogger", function()
    return Logger
end)