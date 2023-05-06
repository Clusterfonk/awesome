-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi
local setmetatable = setmetatable
local wibox = require("wibox")

local animation = require("modules.animation")
local icon_widget = require("ui.widgets.iconbox")


_systray = { mt = {} }
local instance = nil



local function new(s)
    local stray = wibox.widget
    {
        {   
            {
                {
                    widget = wibox.widget.systray
                },
                widget = wibox.container.place
            },
            widget = wibox.container.margin,
            margins={top=dpi(4, s), bottom=dpi(4, s)}
        },
        widget = wibox.container.constraint,
        strategy = "max",
        width = dpi(0, s)
    }


    local _animation = animation:new {
        easing = animation.easing.linear,
        duration = 0.3,
        update = function(self, pos)
            stray.width = pos
        end
    }

    local toggle_state = true
    local function on_press(self) 
        -- if capi.awesome.systray() == 0 then return end
        if toggle_state then
            _animation:set(100)
            self:set_icon(bt.icon.menu_right)
        else
            _animation:set(0)
            self:set_icon(bt.icon.menu_left)
        end
        toggle_state = not toggle_state
    end

    local ibox = icon_widget({icon = bt.icon.menu_left, on_press = on_press})

    local w = wibox.widget({
        {   
            {
                {
                    {   id = "icon",
                        widget = ibox
                    },
                    widget = wibox.container.place,
                    forced_height = dpi(15, s),
                    forced_width = dpi(15, s)
                },
                {
                    widget = stray,
                    visible = true,
                },
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(10, s)
            },
            id = "container",
            widget = wibox.container.place,
        },
        widget = wibox.container.background,
    })
    return w
end

function _systray.mt:__call(...)
    if not instance then
        instance = new(...)
    end
    return instance
end

return setmetatable(_systray, _systray.mt)