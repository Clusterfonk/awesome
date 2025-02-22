-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")
local center = require("ui.popups.notification_center")


notify = { mt = {} }

local function on_press(self, _, _, btn, mods)
    if btn == 1 then
        self.popup:show()
    end
end

-- TODO: add icon for when there are new ones
function notify.new(args)
    local ret = ibutton {
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        margins = args.margins,
        icons = { bt.icon.notification, gcolor.recolor_image(bt.icon.notification, bt.fg_focus),
            bt.icon.notification_muted, gcolor.recolor_image(bt.icon.notification_muted, bt.fg_focus)},
        widget = wibox.widget {
            widget = wibox.widget.imagebox,
            image = bt.icon.notification, -- TODO: set nil
            forced_height = args.height - 2 * dpi(2, args.screen),
            forced_width = args.height - 2 * dpi(2, args.screen)
        }
    }

    ret.popup = center(args)
    ret:connect_signal("button::press", on_press)

    gtable.crush(ret, notify, true)
    return ret
end

function notify.mt:__call(...)
    return notify.new(...)
end

return setmetatable(notify, notify.mt)
