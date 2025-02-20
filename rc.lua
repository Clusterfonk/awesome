--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
---------------------------------------------------------------
--  Sections:
--      -> Garbage-Collection
--      -> Error-Handling
--      -> Theme
--      -> Autostart
--      -> Configuration
--      -> Modules
--      -> UI
---------------------------------------------------------------
pcall(require, "luarocks.loader")
local gears = require("gears")
local bt = require("beautiful")

local capi = {
    awesome = awesome
}

---------------------------------------------------------------
-- => Garbage-Collection
---------------------------------------------------------------
collectgarbage("incremental", 110, 1000)

local memory_last_check_count = collectgarbage("count")
local memory_last_run_time = os.time()
local memory_growth_factor = 1.1 -- 10% over last
local memory_long_collection_time = 300 -- five minutes in seconds

local gtimer = require("gears.timer")
gtimer.start_new(5, function()
	local cur_memory = collectgarbage("count")
	-- instead of forcing a garbage collection every 5 seconds
	-- check to see if memory has grown enough since we last ran
	-- or if we have waited a sificiently long time
	local elapsed = os.time() - memory_last_run_time
	local waited_long = elapsed >= memory_long_collection_time
	local grew_enough = cur_memory > (memory_last_check_count * memory_growth_factor)
	if grew_enough or waited_long then
		collectgarbage("collect")
		collectgarbage("collect")
		memory_last_run_time = os.time()
	end
	-- even if we didn't clear all the memory we would have wanted
	-- update the current memory usage.
	-- slow growth is ok so long as it doesn't go unchecked
	memory_last_check_count = collectgarbage("count")
	return true
end)

---------------------------------------------------------------
-- => Error Handling
---------------------------------------------------------------
local naughty = require("naughty")
if capi.awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Errors during startup!",
                     text = capi.awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    capi.awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Error!",
                         text = tostring(err) })
        in_error = false
    end)
end

---------------------------------------------------------------
-- => Theme
---------------------------------------------------------------
local theme_dir = gears.filesystem.get_configuration_dir() .. "theme/gruvbox/"
bt.init(theme_dir .. "theme.lua")

---------------------------------------------------------------
-- => Autostart
---------------------------------------------------------------
require("autostart")
--require("daemons.audio")
--require("daemons.networkd")

---------------------------------------------------------------
-- => Configuration
---------------------------------------------------------------
require("configuration")

---------------------------------------------------------------
-- => Modules
---------------------------------------------------------------
require("modules.set_wallpaper")
require("modules.sloppy-focus")
require("modules.center_mouse")
require("modules.autofocus")

---------------------------------------------------------------
-- => UI
---------------------------------------------------------------
require("ui")
