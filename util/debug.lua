-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
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

return setmetatable(_debug, debug.mt)
