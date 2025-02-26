-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local gtable = require("gears.table")
local dpi = bt.xresources.apply_dpi

local base = require("ui.popups.base")

local capi = {
    awesome = awesome
}


local systray = { mt = {} }


function systray:show(screen, placement, ...)
    self.widget:get_children_by_id("systray")[1].screen = screen
    self._parent.show(self, screen, nil, ...) -- placement on every update
    self._private.placement = placement
end

function systray.update_width(self, width)
    self.widget:get_children_by_id("constrainer")[1].width = width
    self:geometry({width = width})
end

function systray.new(args)
    args = args or {}
    args.widget = {
        {
            {
                {
                    id = "systray",
                    widget = wibox.widget.systray,
                    margins = bt.useless_gap,
                    reverse = true,
                    horizontal = false,
                    base_size = args.height - 2,
                },
                id = "constrainer",
                widget = wibox.container.constraint,
                strategy = "max",
            },
            widget = wibox.container.place,
            valign = "center",
            halign = "right"
        },
        widget = wibox.container.margin,
        margins = { top = 1, bottom = 1, left = bt.useless_gap, right = bt.useless_gap },
    }
    local ret = base(args)
    rawset(ret, "_parent", { show = ret.show })
    gtable.crush(ret, systray, true)

    -- NOTE: calls for every item in the systray
    capi.awesome.connect_signal("systray::update", function()
        if ret._private.placement then
            ret._private.placement()
        end
    end)

    ret:connect_signal("bar::width", systray.update_width)
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
