-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")
local systray = require("ui.popups.systray")


local capi = {
    awesome = awesome
}

local tray = { mt = {} }

local function on_press(self, _, _, btn)
    if btn == 1  and capi.awesome.systray() > 0 then
        self._private.popup:show(self._private.screen, self._private.placement)
    end
end

local function get_icons()
    return {
        bt.icon.menu_down,
        gcolor.recolor_image(bt.icon.menu_down, bt.fg_focus),

        bt.icon.menu_up,
        gcolor.recolor_image(bt.icon.menu_up, bt.fg_focus)
    }
end

function tray.new(args)
    args.popup = systray(args)
    args.widget = wibox.widget {
        widget = wibox.widget.imagebox,
        image = bt.icon.menu_down,
        forced_height = args.height - 2 * dpi(2, args.screen),
        forced_width = args.height - 2 * dpi(2, args.screen)
    }

    args.icons = get_icons()
    local ret = ibutton(args)

    ret:connect_signal("button::press", on_press)

    gtable.crush(ret, tray, true)
    return ret
end

function tray.mt:__call(...)
    return tray.new(...)
end

return setmetatable(tray, tray.mt)
