-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local icon_widget = require("ui.widgets.iconbox") -- probably gone once all widgets placed
local clock_widget = require("ui.widgets.clock")
local systray = require(... .. ".systray")


return function(s, bar_width, bar_height, bar_offset)
    local clock = clock_widget({
        screen = s,
        format = "%H:%M:%S",
        refresh = 1,
        font = bt.font_bold,
        width = bar_width,
        bar_height = bar_height,
        bar_offset = bar_offset,
    })

    local notification = wibox.widget({
        {
            id = "icon",
            widget = icon_widget({icon = bt.icon.notification})
        },
        widget = wibox.container.place
    })

    local microphone = wibox.widget({
        {
            id = "icon",
            widget = icon_widget({icon = bt.icon.mic})
        },
        widget = wibox.container.place,
    })

    local volume = wibox.widget({
        {
            id = "icon",
            widget = icon_widget({icon = bt.icon.vol_mid})
        },
        widget = wibox.container.place
    })

    local switch_out_widget = wibox.widget({
        {
                widget = volume
        },
        widget = wibox.container.background
    })

    local border_widget = wibox.widget({
        widget = wibox.container.background,
        bg = bt.border_normal,
        {
            widget = wibox.container.place,
            forced_height = dpi(bt.taglist_border_width, s)
        }
    })

    s.info_bar = wibox({
        position = "top",
        screen   = s,
        width    = bar_width,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        height = bar_height,
        visible = true,
        widget   =
        {
            {
                {
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(10, s),
                        notification,
                        clock,
                        volume,
                        microphone,
                        systray(s),
                    },
                    widget = wibox.container.place,
                    halign = "left",
                    forced_height = bar_height
                },
                widget = wibox.container.margin,
                right = dpi(10, s),
                left = dpi(10, s)
            },
            {
                widget = border_widget
            },
            {
                widget = switch_out_widget
            },
            layout = wibox.layout.fixed.vertical
        }})

        awful.placement.align(s.info_bar, {position = "top_left", margins = {top = bar_offset, left = dpi(bt.useless_gap, s) * 2}})

        s.info_bar:struts({
            top = bar_height + 2*dpi(bt.taglist_border_width) + bar_offset
        })
    end

