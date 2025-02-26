-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")
local progressbar = require("ui.popups.progressbar")


local microphone = { mt = {} }

local function on_press(self, _, _, btn, mods)
    if btn == 1 then
        print("pressed mic")
    elseif btn == 4 then
        if mods[1] == "Shift" then
            self._private.popup:emit_signal("progress::change",
                1, self._private.screen, self._private.placement)
        else
            self._private.popup:emit_signal("progress::change",
                5, self._private.screen, self._private.placement)
        end
    elseif btn == 5 then
        if mods[1] == "Shift" then
            self._private.popup:emit_signal("progress::change",
                -1, self._private.screen, self._private.placement)
        else
            self._private.popup:emit_signal("progress::change",
                -5, self._private.screen, self._private.placement)
        end
    end
end

local function get_icons()
    return {
        bt.icon.mic,
        gcolor.recolor_image(bt.icon.mic, bt.fg_focus),

        bt.icon.mic_muted,
        gcolor.recolor_image(bt.icon.mic_muted, bt.fg_focus)
    }
end

function microphone.new(args)
    args.popup = progressbar("mic", args)
    args.widget = wibox.widget {
        widget = wibox.widget.imagebox,
        image = bt.icon.mic, -- TODO: set nil
        forced_height = args.height - 2 * dpi(2, args.screen),
        forced_width = args.height - 2 * dpi(2, args.screen)
    }

    args.icons = get_icons()

    local ret = ibutton(args)
    ret:connect_signal("button::press", on_press)

    gtable.crush(ret, microphone, true)
    return ret
end

function microphone.mt:__call(...)
    return microphone.new(...)
end

return setmetatable(microphone, microphone.mt)
