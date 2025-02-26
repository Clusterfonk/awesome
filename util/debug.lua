-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local naughty = require("naughty")
local debug = require("gears.debug")
local gtable = require("gears.table")

--naughty.notify({
--    preset = naughty.config.presets.critical,
--    title = "DEBUGGER",
--    message = "Debugger is Running!",
--    timeout = 0,
--})

local _debug = { mt = {} }

local weak_objects = setmetatable({}, { __mode = "k" }) -- Ephemeron table

function _debug.dump(t, tag, d)
    debug.dump(t, tag, d)
end

function _debug.dump_matching_key(t, key)
    local res = gtable.find_keys(t, function(k, v) return k:match(key) end)
    debug.dump(res)
end

function _debug.dump_to_file(t, filename)
    local file, err = io.open("/tmp/awmtt/" .. (filename or "output"), "w")
    if file then
        file:write(debug.dump_return(t))
        file:close()
    else
        print("error:", err)
    end
end

function _debug.output_local_vars(scope)
local i = 1
    while true do
        -- level 1 refers to the current function's scope
        local name, value = debug.getlocal(scope or 1, i)
        if not name then break end
        print(name, value)
        i = i + 1
    end
end

function _debug.find_global_var(partial_name)
    for name, value in pairs(_G) do
        if name:find(partial_name) and not name:match("^[a-z]+$") then
            print("Found:", name, "=", value)
        end
    end
end

function _debug.attach_finalizer(obj, msg)
    local gc_proxy = setmetatable({}, {
        __gc = function()
            print(msg .. " has been garbage-collected")
        end
    })
    -- Associate gc_proxy with popup
    weak_objects[obj] = gc_proxy -- Only the key is weak; the value keeps gc_proxy alived
end

return setmetatable(_debug, debug.mt)
