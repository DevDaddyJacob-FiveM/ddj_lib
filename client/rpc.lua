local Logger = exports["ddj_lib"]:getLogger()
local logger = Logger.new("ddj_lib_rpc")

local registered = {}
local pendingRequests = {}
local nextRequestId = 0

local function register(rpcName, cb)
    registered[rpcName] = cb 
    
    logger:debug(
        "Client RPC \"%s\" registered by resource %s",
        rpcName,
        GetCurrentResourceName() or "unknown"
    )
end


local function invoke(rpcName, cb, ...)
    pendingRequests[nextRequestId] = cb
    
    TriggerServerEvent(
        "DevDaddyJacob:Lib_RPC:Server:Invoke",
        rpcName,
        nextRequestId,
        GetInvokingResource() or "unknown",
        ...
    )

    nextRequestId = nextRequestId + 1
end


RegisterNetEvent("DevDaddyJacob:Lib_RPC:Client:Invoke", function(rpcName, requestId, invoker, ...)
    local source = source
  
    if not registered[rpcName] then
        logger:error(
            "Client RPC not registered, name: \"%s\", invoker resource: %s",
            rpcName,
            invoker
        )

        return
    end
  
    registered[rpcName](function(...)
        TriggerServerEvent("DevDaddyJacob:Lib_RPC:Server:Return", requestId, invoker, ...)
    end, ...)
end)


RegisterNetEvent("DevDaddyJacob:Lib_RPC:Client:Return", function(requestId, invoker, ...)
    if not pendingRequests[requestId] then
        logger:error(
            "Server RPC return with requestId %s was called by %s but doesn't exist",
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
    rpc.registerClientRPC = register

    rpc.invoke = invoke
    rpc.invokeServerRPC = invoke

	return rpc
end)
