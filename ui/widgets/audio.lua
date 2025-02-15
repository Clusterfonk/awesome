-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")


audio = { mt = {} }

-- information is retrievable from the bus (which will be cached by the daemon)
local command = "amixer -c 0 get Headphone | grep '\\[on\\]'"

local function on_lmb_press(self, _, _, btn)
    if btn == 1 then
        awful.spawn.easy_async_with_shell(command, function(out)
            if out == "" then
                awful.spawn.with_shell("amixer -c 0 sset Headphone toggle >> /dev/null 2>&1")
                self.image = self.icons[self.index]
            else
                awful.spawn.with_shell("amixer -c 0 sset Headphone toggle >> /dev/null 2>&1")
                self.image = self.icons[self.index + 2]
            end
        end)
    end
end

local function new(args)
    local button_widget = ibutton {
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        margins = args.margins,
        icons = { bt.icon.speaker, gcolor.recolor_image(bt.icon.speaker, bt.fg_focus),
            bt.icon.headphones, gcolor.recolor_image(bt.icon.headphones, bt.fg_focus)},
        widget = wibox.widget {
            widget = wibox.widget.imagebox,
            image = bt.icon.speaker,
            forced_height = args.height - 2 * dpi(2, args.screen),
            forced_width = args.height - 2 * dpi(2, args.screen)
        }
    }
    -- TODO: every image setting should be done by the dbus emitted signal
    --awful.spawn.easy_async_with_shell(command, function(out)
    --    if out == "" then
    --        button_widget.image = audio.icons[audio.icon_index]
    --    else
    --        button_widget.image = audio.icons[audio.icon_index + 2]
    --    end
    --end)

    button_widget:connect_signal("button::press", on_lmb_press)
    --awesome:connect_signal("daemon::audio::refresh", func)
    --function will get the change msg

    gtable.crush(button_widget, audio, true)
    return button_widget
end

function audio.mt:__call(...)
    return new(...)
end

return setmetatable(audio, audio.mt)
