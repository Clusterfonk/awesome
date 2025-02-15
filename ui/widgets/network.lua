-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")


network = { mt = {} }

local function on_lmb_press(self, _, _, btn)
    if btn == 1 then
        print("pressed network widget")
    end
end

local function new(args)
    local button_widget = ibutton {
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        margins = args.margins,
        icons = { bt.icon.ethernet, gcolor.recolor_image(bt.icon.ethernet, bt.fg_focus),
            bt.icon.wlan, gcolor.recolor_image(bt.icon.wlan, bt.fg_focus)},
        widget = wibox.widget {
            widget = wibox.widget.imagebox,
            image = bt.icon.ethernet, -- TODO: set nil
            forced_height = args.height - 2 * dpi(2, args.screen),
            forced_width = args.height - 2 * dpi(2, args.screen)
        }
    }

    button_widget:connect_signal("button::press", on_lmb_press)

    gtable.crush(button_widget, network, true)
    return button_widget
end

function network.mt:__call(...)
    return new(...)
end

return setmetatable(network, network.mt)
