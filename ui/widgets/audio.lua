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


local audio = { mt = {} }

-- information is retrievable from the bus (which will be cached by the daemon)
local command = "amixer -c 0 get Headphone | grep '\\[on\\]'"

local function on_press(self, _, _, btn, mods)
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
    elseif btn == 4 then
        if mods[1] == "Shift" then
            self._private.popup:emit_signal("progress::change",
                1, self.screen, self._private.placement)
        else
            self._private.popup:emit_signal("progress::change",
                5, self.screen, self._private.placement)
        end
    elseif btn == 5 then
        if mods[1] == "Shift" then
            self._private.popup:emit_signal("progress::change",
                -1, self.screen, self._private.placement)
        else
            self._private.popup:emit_signal("progress::change",
                -5, self.screen, self._private.placement)
        end
    end
end

local function get_icons()
    return {
        bt.icon.speaker,
        gcolor.recolor_image(bt.icon.speaker, bt.fg_focus),

        bt.icon.headphones,
        gcolor.recolor_image(bt.icon.headphones, bt.fg_focus)
    }
end


-- TODO: every image setting should be done by the dbus emitted signal
--awful.spawn.easy_async_with_shell(command, function(out)
--    if out == "" then
--        ret.image = audio.icons[audio.icon_index]
--    else
--        ret.image = audio.icons[audio.icon_index + 2]
--    end
function audio.new(args)
    args.popup = progressbar("audio", args)
    args.widget = wibox.widget {
        widget = wibox.widget.imagebox,
        image = bt.icon.speaker,
        forced_height = args.height - 2 * dpi(2, args.screen),
        forced_width = args.height - 2 * dpi(2, args.screen)
    }

    args.icons = get_icons()

    local ret = ibutton(args)
    ret:connect_signal("button::press", on_press)

    gtable.crush(ret, audio, true)
    return ret
end

function audio.mt:__call(...)
    return audio.new(...)
end

return setmetatable(audio, audio.mt)
