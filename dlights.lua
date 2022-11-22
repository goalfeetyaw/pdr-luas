local ffi = require("ffi")

ffi.cdef[[
    typedef struct
    {
        unsigned char r, g, b;
        signed char exponent;
    } ColorRGBExp32;

    typedef struct
    {
        float x;
        float y;
        float z;
    } vec3_t;

    typedef struct
    {
        float x;
        float y;
    } vec2_t;

    typedef struct
    {
        int        flags;
        vec3_t    origin;
        float    radius;
        ColorRGBExp32    color;
        float    die;
        float    decay;
        float    minlight;
        int        key;
        int        style;
        vec3_t    m_Direction;
        float    m_InnerAngle;
        float    m_OuterAngle;
    } dlight_t, *dlight_ptr_t;
]]

local engine_effects = client.create_interface("engine.dll", "VEngineEffects001")
local engine_effects_class = ffi.cast(ffi.typeof("void***"), engine_effects)
local alloc_dlight = ffi.cast("dlight_ptr_t(__thiscall*)(void*, int)", engine_effects_class[0][4])

local enable = ui.add_checkbox("Enable")
local cfg_dlights = ui.add_cog("Enable", true , true)
local mode = ui.add_dropdown("Mode" , {"Continuous" , "Peek assist style"})
local cfg_dlights_radius = ui.add_slider_float("Dlights Radius", 200.0, 500.0)
local cfg_dlights_exponent = ui.add_slider("Dlights Exponent", 1, 20)
local cfg_dlights_style = ui.add_slider("Dlights Style", 0, 11)

local dlight = nil
local get_origin = true
local origin = vector.new(0,0,0)

callbacks.register("paint", function()
    
    local localPlayerIdx = engine.get_local_player()

    local localEntity = entity_list.get_client_entity(localPlayerIdx)

    if not cfg_dlights:get_key() or not enable:get() or not localEntity then 
        dlight = nil 
        get_origin = false
        origin = vector.new(0,0,0)
        return
    end

    if not dlight then dlight = alloc_dlight(engine_effects_class, localPlayerIdx) end


    if get_origin or origin == vector.new(0,0,0) then
        origin = localEntity:origin()
        get_origin = false
    end

    if mode:get() == 0 then 
        origin = localEntity:origin()
    end

    local color = cfg_dlights:get_color()
    local position = {origin.x, origin.y, origin.z}

    dlight.flags = 0x2
    dlight.style = cfg_dlights_style:get()
    dlight.key = localPlayerIdx
    dlight.radius = cfg_dlights_radius:get()
    dlight.origin = position
    dlight.m_Direction = position
    dlight.die = global_vars.curtime + 0.05
    dlight.color.r = color:r()
    dlight.color.g = color:g()
    dlight.color.b = color:b()
    dlight.color.exponent = cfg_dlights_exponent:get()
end)
