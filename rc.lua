--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
---------------------------------------------------------------
--  Sections:
--      -> Debug
--      -> Garbage-Collection
--      -> Error-Handling
--      -> Theme
--      -> Autostart
--      -> Configuration
--      -> Userinterface
---------------------------------------------------------------
pcall(require, "luarocks.loader")
local bt = require("beautiful")
local gfilesystem = require("gears.filesystem")


local capi = {
    awesome = awesome
}

---------------------------------------------------------------
-- => Debug
---------------------------------------------------------------
if os.getenv("AWMTT_DEBUG") then
    DEBUG = true
end

---------------------------------------------------------------
-- => Garbage-Collection
---------------------------------------------------------------
collectgarbage("incremental", 110, 1000)

local memory_last_check_count = collectgarbage("count")
local memory_last_run_time = os.time()
local memory_growth_factor = 1.1        -- 10% over last
local memory_long_collection_time = 300 -- five minutes in seconds
if DEBUG then
    memory_long_collection_time = 10
end

local gtimer = require("gears.timer")
gtimer.start_new(5, function()
    local cur_memory = collectgarbage("count")

    local elapsed = os.time() - memory_last_run_time
    local waited_long = elapsed >= memory_long_collection_time
    local grew_enough = cur_memory > (memory_last_check_count * memory_growth_factor)

    if DEBUG then
        -- Output memory statistics
        print(string.format(
            "[DEBUG] Memory: %.2f KB | Elapsed: %d sec | Grew Enough: %s | Waited Long: %s",
            cur_memory, elapsed, tostring(grew_enough), tostring(waited_long)
        ))
    end
    if grew_enough or waited_long then
        if DEBUG then
            print("[DEBUG] Running garbage collection...")
        end
        collectgarbage("collect")
        collectgarbage("collect")
        memory_last_run_time = os.time()
        if DEBUG then
            -- Output memory after garbage collection
            local post_memory = collectgarbage("count")
            print(string.format("[DEBUG] Memory after GC: %.2f KB", post_memory))
        end
    end
    memory_last_check_count = collectgarbage("count")
    return true
end)

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
require("configuration.keys.colemak")
require("configuration.mouse")

require("configuration.clients")
require("configuration.screens")

require("configuration.layout")
require("configuration.tags")

---------------------------------------------------------------
-- => Userinterface
---------------------------------------------------------------
require("ui")
