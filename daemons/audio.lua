local lgi = require("lgi")
local Gio = lgi.Gio
local GLib = lgi.GLib
local gears = require("gears")
local awful = require("awful")


local bus = Gio.bus_get_sync(Gio.BusType.SESSION)

--bus:signal_subscribe(
--    "org.PulseAudio1",               -- Service name
--    "org.PulseAudio.Core1.Device",   -- Interface
--    "VolumeUpdated",                 -- Signal name
--    "/org/pulseaudio/core1",         -- Object path
--    nil,                             -- Match all member names
--    Gio.DBusSignalFlags.NONE,
--    function()
--        -- Fetch the new volume level
--        awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@", function(out)
--            local volume = out:match("(%d+)%%") -- Extract volume percentage
--            print(volume)
--            awesome.emit_signal("daemon::volume_changed", volume)
--        end)
--    end
--)
