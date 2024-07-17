local naughty = require("naughty")
local debug = require("gears.debug")
local gtable = require("gears.table")

naughty.notify({
    preset = naughty.config.presets.critical,
    title = "DEBUGGER",
    message = "Debugger is Running!",
    timeout = 0,
})

_debug = { mt = {} }

function _debug.dump(t)
    debug.dump(t)
end

function _debug.dump_matching_key(t, key)
    local res = gtable.find_keys(t, function(k, v) return k:match(key) end)
    debug.dump(res)
end

-- NOTE: "a" for append mode could make it where every start/restart clears the file and then appends with stamps or something
function _debug.dump_to_file(t, filename)
    local file, err = io.open("/tmp/awmtt/" .. (filename or "output"), "w")
    if file then
        file:write(debug.dump_return(t))
        file:close()
    else
        print("error:", err)
    end
end

return setmetatable(_debug, debug.mt)
