--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
---------------------------------------------------------------
--  Sections:
--      -> Garbage-Collection
--      -> Debug
--      -> Error-Handling
--      -> Theme
--      -> Autostart
--      -> Configuration
--      -> Modules
--      -> UI
---------------------------------------------------------------
pcall(require, "luarocks.loader")
local bt = require("beautiful")
local gfilesystem = require("gears.filesystem")


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
-- => Debug
---------------------------------------------------------------
if os.getenv("AWMTT_DEBUG") then
    DEBUG = true
end

---------------------------------------------------------------
-- => Theme
---------------------------------------------------------------
local theme_dir = gfilesystem.get_configuration_dir() .. "theme/gruvbox"
bt.init(theme_dir .. "/theme.lua")

---------------------------------------------------------------
-- => Error Handling
---------------------------------------------------------------
local naughty = require("naughty")

if capi.awesome.startup_errors then
    naughty.notification {
        preset = naughty.config.presets.critical,
        title = 'ERROR!',
        app_name = 'System Notification',
        message = capi.awesome.startup_errors,
        icon = theme_dir .. '/icons/error.svg',
    }
end

local in_error = false
capi.awesome.connect_signal('debug::error', function(err)
    if in_error then return end
    in_error = true

    naughty.notification {
        preset = naughty.config.presets.critical,
        title = 'ERROR',
        app_name = 'System Notification',
        message = tostring(err),
        icon = theme_dir .. 'icons/bug.svg',
    }

    gtimer {
        timeout = 3,
        autostart = true,
        single_shot = true,
        callback = function()
            in_error = false
        end,
    }
end)

capi.awesome.connect_signal('debug::deprecation', function(err)
    naughty.notification {
        preset = naughty.config.presets.critical,
        title = 'DEPRECATION',
        app_name = 'System Notification',
        message = tostring(err),
        icon = theme_dir .. 'icons/deprecation.svg',
    }
end)

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
