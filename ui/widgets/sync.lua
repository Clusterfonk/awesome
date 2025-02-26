-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")


local sync = { mt = {} }

--TODO: can use syncthing cli show pending devices/folder
-- or status and such
local function on_lmb_press(self, _, _, btn)
    if btn == 1 then
        print("pressed sync widget")
    end
end

function sync.new(args)
    local ret = ibutton {
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        margins = args.margins,
        icons = { bt.icon.sync_ok, gcolor.recolor_image(bt.icon.sync_ok, bt.fg_focus),
            bt.icon.sync_notif, gcolor.recolor_image(bt.icon.sync_notif, bt.fg_focus)},
        widget = wibox.widget {
            widget = wibox.widget.imagebox,
            image = bt.icon.sync_ok, -- TODO: set nil
            forced_height = args.height - 2 * dpi(2, args.screen),
            forced_width = args.height - 2 * dpi(2, args.screen)
        }
    }

    ret:connect_signal("button::press", on_lmb_press)

    gtable.crush(ret, sync, true)
    return ret
end

function sync.mt:__call(...)
    return sync.new(...)
end

return setmetatable(sync, sync.mt)
