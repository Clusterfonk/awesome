-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")

local mouse = require("util.mouse")


local ibutton = { mt = {} }

local function on_enter(self)
    self.index = 2
    self:get_widget():get_widget().image = self.icons[self.index]
    self:emit_signal("widget::redraw_needed")
    mouse.set_cursor("hand2")
end

local function on_leave(self)
    self.index = 1
    -- needs to know which icon +2 or not
    self:get_widget():get_widget().image = self.icons[self.index]
    self:emit_signal("widget::redraw_needed")
    mouse.set_cursor("left_ptr")
end

function ibutton.new(args)
    local ret = wibox.widget {
        screen = args.screen,
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        widget = wibox.widget {
            {

                {
                    widget = args.widget
                },
                widget = wibox.container.place,
                valign = "center",
                halign = "center"
            },
            widget = wibox.container.margin,
            margins = args.margins
        }
    }
    ret._private = ret._private or {}
    ret._private.popup = args.popup
    ret._private.screen = args.screen
    ret._private.placement = args.placement

    ibutton.index = 1
    ibutton.icons = args.icons

    gtable.crush(ret, ibutton, true)

    ret:connect_signal("mouse::enter", on_enter)
    ret:connect_signal("mouse::leave", on_leave)

    return ret
end

function ibutton.mt:__call(...)
    return ibutton.new(...)
end

return setmetatable(ibutton, ibutton.mt)
