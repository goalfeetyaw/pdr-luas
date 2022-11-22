local orint = print
local function string_vec(a)
    return string.format("Vector( %d , %d , %d )" , a.x , a.y , a.z and a.z or 0)
end
local function string_col(a)
    return string.format("Color( %d , %d , %d , %d )" , a:r() , a:g() , a:b() , a:a())
end
print = function (a)
    if type(a) == "number" then 
        orint(tostring(a))
    elseif type(a) == "userdata" and a.x then 
        orint(string_vec(a))
    elseif type(a) == "userdata" and a:r() then 
        orint(string_col(a))
    elseif type (a) == "table" then 
        local str = "Table { "
        for k , v in pairs(a) do
            if type(v) == "userdata" and v.x then 
                v = string_vec(v)
            elseif type(v) == "userdata" and v:r() then
                v = string_col(v)
            else
                v = tostring(v)
            end
            str = str .. k.." = "..v.." "
        end
        orint(str.."}")
    end
end
