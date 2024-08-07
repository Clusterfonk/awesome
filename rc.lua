--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
---------------------------------------------------------------
--  Sections:
--      -> Theme
--      -> Autostart
--      -> Configuration
--      -> Modules
--      -> UI
--      -> Garbage-Collection
--      -> Error-Handling
---------------------------------------------------------------
pcall(require, "luarocks.loader")
local gears = require("gears")
local bt = require("beautiful")


---------------------------------------------------------------
-- => Autostart
---------------------------------------------------------------
require("autostart")

---------------------------------------------------------------
-- => Theme
---------------------------------------------------------------
 local theme_dir = gears.filesystem.get_configuration_dir() .. "theme/gruvbox/"
 bt.init(theme_dir .. "theme.lua")

---------------------------------------------------------------
-- => Configuration
---------------------------------------------------------------
require("configuration")

---------------------------------------------------------------
-- => Modules
---------------------------------------------------------------
require("modules.sloppy-focus")
require("modules.set_wallpaper")
require("modules.center_mouse")

---------------------------------------------------------------
-- => UI
---------------------------------------------------------------
require("ui")

---------------------------------------------------------------
-- => Garbage-Collection
---------------------------------------------------------------
collectgarbage("setstepmul", 1000)
gears.timer({
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
            collectgarbage("collect")
    end,
})

---------------------------------------------------------------
-- => Error Handling
---------------------------------------------------------------
local naughty = require("naughty")
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Error!",
                         text = tostring(err) })
        in_error = false
    end)
end
