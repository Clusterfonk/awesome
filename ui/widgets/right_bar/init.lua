-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local gears = require("gears")
local dpi = bt.xresources.apply_dpi


return function(s, bar_width, bar_height, bar_offset)
    -- create clock widget
    local clock = wibox.widget {
        format = '%H:%M',
        widget = wibox.widget.textclock,
        font = bt.font_bold,
        screen = s,
    }
    
    -- TODO: no idea how it should look like
    -- local systray = wibox.widget {
    --     widget = wibox.widget.systray,
    --     screen = s,
    --     base_size = 0.8 * bar_height 
    -- }

    local systray = wibox.widget({
        {
            {
                id = "icon",
                image = bt.icon.menu_down,
                widget = wibox.widget.imagebox
            },
            id = "container",
            widget = wibox.container.place
        },
        widget = wibox.container.background,
    })
    -- TODO: basic signal wrapper for a widget ?
    systray.container.icon:connect_signal("mouse::enter", 
        function(self, ...)
            local image = self._private.image
            self:set_image(gears.color.recolor_image(image, bt.border_focus))
    end)
    
    systray.container.icon:connect_signal("mouse::leave", 
        function(self, ...) 
            self:set_image(bt.icon.menu_down)
    end)

    local notification = wibox.widget({
        {
            id = "icon",
            image = bt.icon.notification,
            widget = wibox.widget.imagebox
        },
        widget = wibox.container.place,
        forced_height = dpi(15, s),
        forced_width = dpi(15, s)
    })

    local microphone = wibox.widget({
        {
            id = "icon",
            image = bt.icon.mic,
            widget = wibox.widget.imagebox
        },
        widget = wibox.container.place,
        forced_height = dpi(18, s),
        forced_width = dpi(18, s)
    })

    local volume = wibox.widget({
        {
            id = "icon",
            image = bt.icon.vol_mid,
            widget = wibox.widget.imagebox
        },
        widget = wibox.container.place,
        forced_height = dpi(22, s),
        forced_width = dpi(22, s)
    })

    local actual_systray = wibox.widget({
        {
            id = "systray",
            widget = wibox.widget.systray(false)
        },
        layout = wibox.layout.flex.horizontal,
    })

    s.right_bar = wibox({
        position = "top",
        align = "right",
        screen   = s,
        stretch  = false,
        width    = bar_width,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        height = bar_height, 
        visible = true,
        widget   = 
        {   
            {
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(10, s),
                    systray,
                    microphone,
                    volume,
                    clock,
                    notification,
                },
                layout = wibox.container.margin,
                right = dpi(10, s),
            },
            layout = wibox.container.place,
            halign = "right",
        }
    })

    awful.placement.align(s.right_bar, {position = "top_right", margins = {top = bar_offset, right = bar_offset + dpi(bt.useless_gap, s) + dpi(bt.border_width, s)}})

    s.right_bar:struts({
        top = bar_height + 2*dpi(bt.taglist_border_width) + bar_offset
    })

-- TEMP

-- local test_widget = wibox.widget({
--     {
--         widget = notification
--     },
--     id = "popup_margin",
--     widget = wibox.container.margin,
-- })

-- s.right_popup = awful.popup({
--     screen   = s,
--     maximum_width = bar_width,
--     height = bar_height * 0.8,
--     visible = true,
--     -- bg = bt.right_extender_bg_normal, -- EXPORT
--     bg = "#504945",
--     widget = test_widget,
-- })
--     s.right_popup:move_next_to(s.right_bar)


--     local gears = require("gears")
--     local timer = gears.timer {
--         timeout = 0.5,
--         autostart = true,
--         callback = function(self)
--             local step = 50 -- grow function will be dependend on the distance missing to max
--             local margin = s.right_popup.widget:get_children_by_id("popup_margin")[1]
--             if margin.left + step > s.right_popup.maximum_width then
--                 -- self.stop()
--             else
--                 margin.left = margin.left + step
--                 s.right_popup:move_next_to(s.right_bar)
--             end
--         end
--     }
--     s.right_popup:connect_signal("toggle", function(self) self.visible = not self.visible end)
-- -------

end
