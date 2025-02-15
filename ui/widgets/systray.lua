-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")


systray = { mt = {} }

local function on_lmb_press(self, _, _, btn)
    if btn == 1 then
        print("pressed systray widget")
    end
end

local function new(args)
    local button_widget = ibutton {
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        margins = args.margins,
        icons = { bt.icon.menu_down, gcolor.recolor_image(bt.icon.menu_down, bt.fg_focus),
            bt.icon.menu_up, gcolor.recolor_image(bt.icon.menu_up, bt.fg_focus)},
        widget = wibox.widget {
            widget = wibox.widget.imagebox,
            image = bt.icon.menu_down, -- TODO: set nil
            forced_height = args.height - 2 * dpi(2, args.screen),
            forced_width = args.height - 2 * dpi(2, args.screen)
        }
    }

    button_widget:connect_signal("button::press", on_lmb_press)

    gtable.crush(button_widget, systray, true)
    return button_widget
end

function systray.mt:__call(...)
    return new(...)
end

return setmetatable(systray, systray.mt)
