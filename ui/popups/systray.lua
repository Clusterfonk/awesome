-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local bt = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")

local base = require("ui.popups.base")

local capi = {
    awesome = awesome
}


local systray = { mt = {} }

function systray.update_width(self, width)
    self.widget:get_children_by_id("constrainer")[1].width = width
    self:geometry({width = width})
end

function systray:set_screen(screen)
    self._private.screen = screen
    self.widget:get_children_by_id("systray")[1].screen = screen
end

function systray.destroy(self)
    self._parent:destroy()
    systray.instance = nil

    gtimer.delayed_call(function()
        collectgarbage("collect")
        collectgarbage("collect")
    end)
end

function systray.new(args)
    args = args or {}
    local ret = base(args)
    gtable.crush(ret, systray, true)

    ret.minimum_height = args.height
    ret.minimum_width = args.width
    ret.maximum_width = args.width
    ret.widget = wibox.widget.base.make_widget_declarative {
        id = "constrainer",
        widget = wibox.container.constraint,
        strategy = "max",
        {
            widget = wibox.container.margin,
            margins = { top = 2, bottom = 2, left = bt.useless_gap, right = bt.useless_gap },
            {
                widget = wibox.container.place,
                valign = "center",
                halign = "right",
                {
                    id = "systray",
                    widget = wibox.widget.systray,
                    margins = bt.useless_gap,
                    reverse = true,
                    horizontal = false,
                    base_size = args.height,
                }
            }
        }
    }

    ret:connect_signal("update::width", systray.update_width)

    local _debug = require("_debug")
    if _debug.gc_finalize then
        _debug.attach_finalizer(ret, "systray")
    end
    return ret
end

function systray.mt:__call(...)
    if systray.instance then
        return systray.instance
    end
    systray.instance = systray.new(...)
    return systray.instance
end

return setmetatable(systray, systray.mt)
