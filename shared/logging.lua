LogLevel = {}
LogLevel.OFF = 0
LogLevel.FATAL = 100
LogLevel.ERROR = 200
LogLevel.WARN = 300
LogLevel.INFO = 400
LogLevel.DEBUG = 500
LogLevel.TRACE = 600
LogLevel.ALL = math.maxinteger

Logger = {}
Logger.__index = Logger


function Logger._fetchLogLevelConvar(self)
    local globalConvar = "ddj_log_level"
    local resourceConvar = globalConvar .. self._resourceIdentifier

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


function Logger.setResourceIdentifier(self, ident)
    if nil == ident then
        self._resourceIdentifier = GetCurrentResourceName() or "DevDaddyJacob"
        return
    end

    self._resourceIdentifier = ident
end


function Logger.getLogLevel(self)
    if self._overrideConvar then
        return self._level
    end

    local convarLevel = self:_fetchLogLevelConvar()
    if nil ~= convarLevel then
        return convarLevel
    end

    return LogLevel.INFO
end

function Logger.setLogLevel(self, level)
    if nil == level then
        self._overrideConvar = false
        return
    end

    self._level = level
    self._overrideConvar = true
end


function Logger.canLogLevel(self, targetLevel)
    local level = self:getLogLevel()

    if LogLevel.OFF == level then
        return false
    end

    if LogLevel.ALL == level then
        return true
    end

    return targetLevel <= level
end


function Logger._print(self, level, prefix, message)
    if not self:canLogLevel(level) then
        return
    end

    local fullMsg = "[" .. self._resourceIdentifier .. "]"

    if nil ~= prefix then
        fullMsg = fullMsg .. " " .. prefix .. ": "
    end

    print(fullMsg .. message)
end


function Logger.fatal(self, message, ...)
    self:_print(LogLevel.FATAL, "FATAL", string.format(message, ...))
end

function Logger.fatalIf(self, condition, message, ...)
    if condition then
        self:fatal(message, ...)
    end
end


function Logger.error(self, message, ...)
    self:_print(LogLevel.ERROR, "ERROR", string.format(message, ...))
end


function Logger.errorIf(self, condition, message, ...)
    if condition then
        self:error(message, ...)
    end
end


function Logger.warn(self, message, ...)
    self:_print(LogLevel.WARN, "WARN", string.format(message, ...))
end


function Logger.warnIf(self, condition, message, ...)
    if condition then
        self:warn(message, ...)
    end
end


function Logger.info(self, message, ...)
    self:_print(LogLevel.INFO, "INFO", string.format(message, ...))
end


function Logger.infoIf(self, condition, message, ...)
    if condition then
        self:info(message, ...)
    end
end


function Logger.debug(self, message, ...)
    self:_print(LogLevel.DEBUG, "DEBUG", string.format(message, ...))
end


function Logger.debugIf(self, condition, message, ...)
    if condition then
        self:debug(message, ...)
    end
end


function Logger.trace(self, message, ...)
    self:_print(LogLevel.TRACE, "TRACE", string.format(message, ...))
end


function Logger.traceIf(self, condition, message, ...)
    if condition then
        self:trace(message, ...)
    end
end


function Logger.custom(self, logLevel, message, ...)
    self:_print(logLevel, nil, string.format(message, ...))
end


function Logger.customIf(self, condition, logLevel, message, ...)
    if condition then
        self:custom(logLevel, message, ...)
    end
end


function Logger.new(resourceIdentifier, logLevel)
    local newLogger = {}
    setmetatable(newLogger, Logger)

    newLogger._resourceIdentifier = resourceIdentifier
        or GetCurrentResourceName() or "DevDaddyJacob"

    newLogger._level = logLevel or LogLevel.INFO
    newLogger._overrideConvar = false

    newLogger._fetchLogLevelConvar = Logger._fetchLogLevelConvar
    newLogger.setResourceIdentifier = Logger.setResourceIdentifier
    newLogger.getLogLevel = Logger.getLogLevel
    newLogger.setLogLevel = Logger.setLogLevel
    newLogger.canLogLevel = Logger.canLogLevel
    newLogger._print = Logger._print
    newLogger.fatal = Logger.fatal
    newLogger.fatalIf = Logger.fatalIf
    newLogger.error = Logger.error
    newLogger.errorIf = Logger.errorIf
    newLogger.warn = Logger.warn
    newLogger.warnIf = Logger.warnIf
    newLogger.info = Logger.info
    newLogger.infoIf = Logger.infoIf
    newLogger.debug = Logger.debug
    newLogger.debugIf = Logger.debugIf
    newLogger.trace = Logger.trace
    newLogger.traceIf = Logger.traceIf
    newLogger.custom = Logger.custom
    newLogger.customIf = Logger.customIf

    return newLogger
end
