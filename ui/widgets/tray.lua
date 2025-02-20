-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")
local popup = require("ui.popups.systray")

local capi = {
    awesome = awesome
}

tray = { mt = {} }

local function on_lmb_press(self)
    if capi.awesome.systray() > 0 then
        self.popup:show()
    end
end

function tray.new(args)
    local ret = ibutton {
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

    ret.popup = popup(args)
    ret:connect_signal("button::press", on_lmb_press)

    gtable.crush(ret, tray, true)
    return ret
end

function tray.mt:__call(...)
    return tray.new(...)
end

return setmetatable(tray, tray.mt)
