-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")
local progressbar = require("ui.popups.progressbar")


audio = { mt = {} }

-- information is retrievable from the bus (which will be cached by the daemon)
local command = "amixer -c 0 get Headphone | grep '\\[on\\]'"

local function on_press(self, _, _, btn, mods)
    if btn == 1 then
        print("left press")
        awful.spawn.easy_async_with_shell(command, function(out)
            if out == "" then
                awful.spawn.with_shell("amixer -c 0 sset Headphone toggle >> /dev/null 2>&1")
                self.image = self.icons[self.index]
            else
                awful.spawn.with_shell("amixer -c 0 sset Headphone toggle >> /dev/null 2>&1")
                self.image = self.icons[self.index + 2]
            end
        end)
    elseif btn == 4 then
        if mods[1] == "Shift" then
            self.popup:emit_signal("popup::increment", 1)
        else
            self.popup:emit_signal("popup::increment", 5)
        end
    elseif btn == 5 then
        if mods[1] == "Shift" then
            self.popup:emit_signal("popup::decrement", 1)
        else
            self.popup:emit_signal("popup::decrement", 5)
        end
    end
end

function audio.new(args)
    local ret = ibutton {
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
    --        ret.image = audio.icons[audio.icon_index]
    --    else
    --        ret.image = audio.icons[audio.icon_index + 2]
    --    end
    --end)

    ret.popup = progressbar(args) -- showing on scroll
    ret:connect_signal("button::press", on_press)
    --awesome:connect_signal("daemon::audio::refresh", func)
    --function will get the change msg

    gtable.crush(ret, audio, true)
    return ret
end

function audio.mt:__call(...)
    return audio.new(...)
end

return setmetatable(audio, audio.mt)
