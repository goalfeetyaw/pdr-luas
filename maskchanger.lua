local ffi = require "ffi"
local bit = require "bit"
local __thiscall = function(func, this)
    return function(...) return func(this, ...) end
end

local interface_ptr = ffi.typeof("void***")

local vtable_bind = function(module, interface, index, typedef)
    local addr = ffi.cast("void***",client.create_interface(module, interface)) or error(interface .. " was not found")
    return __thiscall(ffi.cast(typedef, addr[0][index]), addr)
end

local vtable_entry = function(instance, i, ct)
    return ffi.cast(ct, ffi.cast(interface_ptr, instance)[0][i])
end

local vtable_thunk = function(i, ct)
    local t = ffi.typeof(ct)
    return function(instance, ...)
        return vtable_entry(instance, i, t)(instance, ...)
    end
end

local set_model_index = vtable_thunk(75, "void(__thiscall*)(void*,int)")

local get_client_entity_from_handle = vtable_bind("client.dll", "VClientEntityList003", 4, "void*(__thiscall*)(void*,void*)")
local get_model_index = vtable_bind("engine.dll", "VModelInfoClient004", 2, "int(__thiscall*)(void*, const char*)")

local rawientitylist =client.create_interface("client.dll", "VClientEntityList003") or error("VClientEntityList003 was not found", 2)

local ientitylist = ffi.cast(interface_ptr, rawientitylist) or error("rawientitylist is nil", 2)
local get_client_entity = ffi.cast("void*(__thiscall*)(void*, int)", ientitylist[0][3]) or error("get_client_entity was not found", 2)

local client_string_table_container = ffi.cast(interface_ptr,client.create_interface("engine.dll", "VEngineClientStringTable001")) or error("VEngineClientStringTable001 was not found", 2)
local find_table = vtable_thunk(3, "void*(__thiscall*)(void*, const char*)")

local model_info = ffi.cast(interface_ptr,client.create_interface("engine.dll", "VModelInfoClient004")) or error("VModelInfoClient004 wasnt found", 2)

ffi.cdef [[
    typedef void(__thiscall* find_or_load_model_t)(void*, const char*);
]]

local add_string = vtable_thunk(8, "int*(__thiscall*)(void*, bool, const char*, int length, const void* userdata)")
local find_or_load_model = ffi.cast("find_or_load_model_t", model_info[0][43]) -- vtable thunk crashes (?)

local function _precache(szModelName)
    if szModelName == "" then return end -- don"t precache empty strings (crash)
    if szModelName == nil then return end
    szModelName = string.gsub(szModelName, [[\]], [[/]])

    local m_pModelPrecacheTable = find_table(client_string_table_container, "modelprecache")
    if m_pModelPrecacheTable ~= nil then
        find_or_load_model(model_info, szModelName)
        add_string(m_pModelPrecacheTable, false, szModelName, -1, nil)
    end
end

local list_names =
{   "None",
    "Dallas",
    "Battle Mask",
    "Evil Clown",
    "Anaglyph",
    "Boar",
    "Bunny",
    "Bunny Gold",
    "Chains",
    "Chicken",
    "Devil Plastic",
    "Hoxton",
    "Pumpkin",
    "Samurai",
    "Sheep Bloody",
    "Sheep Gold",
    "Sheep Model",
    "Skull",
    "Template",
    "Wolf",
    "Doll",
}

local enable = ui.add_checkbox( "Maks changer" )
local masks = ui.add_dropdown("Mask", list_names)


local models = {
    "",
    "models/player/holiday/facemasks/facemask_dallas.mdl",
    "models/player/holiday/facemasks/facemask_battlemask.mdl",
    "models/player/holiday/facemasks/evil_clown.mdl",
    "models/player/holiday/facemasks/facemask_anaglyph.mdl",
    "models/player/holiday/facemasks/facemask_boar.mdl",
    "models/player/holiday/facemasks/facemask_bunny.mdl",
    "models/player/holiday/facemasks/facemask_bunny_gold.mdl",
    "models/player/holiday/facemasks/facemask_chains.mdl",
    "models/player/holiday/facemasks/facemask_chicken.mdl",
    "models/player/holiday/facemasks/facemask_devil_plastic.mdl",
    "models/player/holiday/facemasks/facemask_hoxton.mdl",
    "models/player/holiday/facemasks/facemask_pumpkin.mdl",
    "models/player/holiday/facemasks/facemask_samurai.mdl",
    "models/player/holiday/facemasks/facemask_sheep_bloody.mdl",
    "models/player/holiday/facemasks/facemask_sheep_gold.mdl",
    "models/player/holiday/facemasks/facemask_sheep_model.mdl",
    "models/player/holiday/facemasks/facemask_skull.mdl",
    "models/player/holiday/facemasks/facemask_template.mdl",
    "models/player/holiday/facemasks/facemask_wolf.mdl",
    "models/player/holiday/facemasks/porcelain_doll.mdl",
}

local last_model = 0

local model_index = -1
local enabled = false

local function precache(modelPath)
    if modelPath == "" then return -1 end -- don"t crash.
    local local_model_index = get_model_index(modelPath)
    if local_model_index == -1 then
        _precache(modelPath)
    end
    return get_model_index(modelPath)
end

local function on_paint()
    masks:set_visible(enable:get())
    if not enable:get() then return end
    if not engine.in_game() then
        last_model = 0
        return
    end
    if last_model ~= masks:get() then
        last_model = masks:get()
        if last_model == 0 then
            enabled = false
        else
            enabled = true
            model_index = precache(models[last_model + 1])
        end
    end
end

local function get_player_address(lp)
    return get_client_entity(ientitylist, lp:index())
end

local function on_setup_command()
    if not enable:get() then return end

    if model_index == -1 then return precache(models[last_model + 1]) end

    local local_player = entity_list.get_client_entity(engine.get_local_player())
    if enabled then
        local lp_addr = ffi.cast("intptr_t*", get_player_address(local_player))
        local m_AddonModelsHead = ffi.cast("intptr_t*", lp_addr + 0x462F) -- E8 ? ? ? ? A1 ? ? ? ? 8B CE 8B 40 10
        local i, next_model = m_AddonModelsHead[0], -1

        while i ~= -1 do
            next_model = ffi.cast("intptr_t*", lp_addr + 0x462C)[0] + 0x18 * i -- this is the pModel (CAddonModel) afaik
            i = ffi.cast("intptr_t*", next_model + 0x14)[0]
            local m_pEnt = ffi.cast("intptr_t**", next_model)[0] -- CHandle<C_BaseAnimating> m_hEnt -> Get()
            local m_iAddon = ffi.cast("intptr_t*", next_model + 0x4)[0]
            if tonumber(m_iAddon) == 16 then -- face mask addon bits knife = 10
                local entity = get_client_entity_from_handle(m_pEnt)
                set_model_index(entity, model_index)
            end
        end
    end
end

local function on_frame_stage(stage)

    local local_player = entity_list.get_client_entity(engine.get_local_player())

    if not enable:get() then
        local addon_bit = local_player:get_prop("DT_CSPlayer" , "m_iAddonBits")
        if bit.band(addon_bit:get_int(), 0x10000) == 0x10000 then
            addon_bit:set_int(addon_bit:get_int() - 0x10000)
        end
        return
    end

    if stage ~= 5 then return end

    if local_player == nil then return end
    if enabled then
        local addon_bit = local_player:get_prop("DT_CSPlayer" , "m_iAddonBits")
        if bit.band(addon_bit:get_int(), 0x10000) ~= 0x10000 then
            addon_bit:set_int(0x10000 + addon_bit:get_int())
        end
    else
        local addon_bit = local_player:get_prop("DT_CSPlayer" , "m_iAddonBits")
        if bit.band(addon_bit:get_int(), 0x10000) == 0x10000 then
            addon_bit:set_int(addon_bit:get_int() - 0x10000)
        end
    end
end


callbacks.register("predicted_move", on_setup_command)
callbacks.register("paint", on_paint)
callbacks.register("post_frame_stage", on_frame_stage)
