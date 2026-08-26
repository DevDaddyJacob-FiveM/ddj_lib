logger = Logger.new("ddj_lib")

Config = {
    --[[
        When enabled checks the version of all DevDaddyJacob scripts
    ]]
    VersionCheck = false,

    --[[
        When `true`, the script won't attempt to hook into baseevents even if
        it's running.
    ]]
    DisableBaseEventsHook = false,
}