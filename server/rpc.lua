local Logger = exports["ddj_lib"]:getLogger()
local logger = Logger.new("ddj_lib_rpc")

local registered = {}
local pendingRequests = {}
local nextRequestId = 0

local function register(rpcName, cb)
    registered[rpcName] = cb 
    
    logger:debug(
        "Server RPC \"%s\" registered by resource %s",
        rpcName,
        GetCurrentResourceName() or "unknown"
    )
end


local function invoke(player, rpcName, cb, ...)
    pendingRequests[nextRequestId] = cb
    
    TriggerClientEvent(
        "DevDaddyJacob:Lib_RPC:Client:Invoke",
        player,
        rpcName,
        nextRequestId,
        GetInvokingResource() or "unknown",
        ...
    )

    nextRequestId = nextRequestId + 1
end


RegisterNetEvent("DevDaddyJacob:Lib_RPC:Server:Invoke", function(rpcName, requestId, invoker, ...)
    local source = source
  
    if not registered[rpcName] then
        logger:error(
            "Server RPC not registered, name: \"%s\", invoker resource: %s",
            rpcName,
            invoker
        )

        return
    end
  
    registered[rpcName](source, function(...)
        TriggerClientEvent("DevDaddyJacob:Lib_RPC:Client:Return", source, requestId, invoker, ...)
    end, ...)
end)


RegisterNetEvent("DevDaddyJacob:Lib_RPC:Server:Return", function(requestId, invoker, ...)
    if not pendingRequests[requestId] then
        logger:error(
            "Client RPC return with requestId %s was called by %s but doesn't exist",
            requestId,
            invoker
        )

        return
    end
  
    pendingRequests[requestId](...)
    pendingRequests[requestId] = nil
end)


exports("getRPC", function()
    rpc = {}
    
    rpc.register = register
    rpc.registerServerRPC = register

    rpc.invoke = invoke
    rpc.invokeClientRPC = invoke

	return rpc
end)
