--// clipboard lip

ffi.cdef [[
    typedef int(__thiscall* get_clipboard_text_length)(void*);
    typedef void(__thiscall* set_clipboard_text)(void*, const char*, int);
    typedef void(__thiscall* get_clipboard_text)(void*, int, const char*, int);
]]

local VGUI_System = ffi.cast(ffi.typeof("void***"), client.create_interface("vgui2.dll", "VGUI_System010"))
local get_clipboard_text_length = ffi.cast("get_clipboard_text_length", VGUI_System[0][7])
local get_clipboard_text = ffi.cast("get_clipboard_text", VGUI_System[0][11])
local set_clipboard_text = ffi.cast("set_clipboard_text", VGUI_System[0][9])

local clipboard =  {}

clipboard.set = function (text)
    set_clipboard_text(VGUI_System, text, #text)
end

clipboard.get = function()
    local clipboard_text_length = get_clipboard_text_length(VGUI_System)

    if (clipboard_text_length > 0) then
        local buffer = ffi.new("char[?]", clipboard_text_length)

        get_clipboard_text(VGUI_System, 0, buffer, clipboard_text_length * ffi.sizeof("char[?]", clipboard_text_length))
        return ffi.string(buffer, clipboard_text_length - 1)
    end
end

return clipboard
