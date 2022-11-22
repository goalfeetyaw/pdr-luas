local rawivengineclient = client.create_interface("engine.dll", "VEngineClient014")
local ivengineclient = ffi.cast("void***", rawivengineclient)
local get_net_channel_info = ffi.cast("void*(__thiscall*)(void*)", ivengineclient[0][78])
local INetChannelInfo = ffi.cast("void***", get_net_channel_info(ivengineclient))
local ptr = INetChannelInfo
INetChannelInfo = INetChannelInfo[0]

local lib = {}

lib.sequence_nr = function ()
    return ffi.cast("int(__thiscall*)(void*, int)", INetChannelInfo[17])(ptr, 1)
end

lib.loopback = function ()
    return ffi.cast("bool(__thiscall*)(void*)", INetChannelInfo[6])(ptr)
end

lib.timing_out = function ()
    return ffi.cast("bool(__thiscall*)(void*)", INetChannelInfo[7])(ptr)
end

lib.current_latency = function (flow)
    return ffi.cast("float(__thiscall*)(void*, int)", INetChannelInfo[9])(ptr, flow)
end

lib.average_latency = function (flow)
    return ffi.cast("float(__thiscall*)(void*, int)", INetChannelInfo[10])(ptr, flow)
end

lib.packet_loss = function ()
    return ffi.cast("float(__thiscall*)(void*, int)", INetChannelInfo[11])(ptr, 1)
end

lib.choke = function ()
    return ffi.cast("float(__thiscall*)(void*, int)", INetChannelInfo[12])(ptr, 1)
end

lib.received_bytes = function ()
    return ffi.cast("float(__thiscall*)(void*, int)", INetChannelInfo[13])(ptr, 1)
end

lib.sent_bytes = function ()
    return ffi.cast("float(__thiscall*)(void*, int)", INetChannelInfo[12])(ptr, 1)
end

lib.valid_packet = function ()
    return ffi.cast("bool(__thiscall*)(void*, int, int)", INetChannelInfo[18])(ptr, 1, lib.sequence_nr() -1)
end

return lib
