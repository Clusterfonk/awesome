--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
local bt                   = require("beautiful")
local dpi                  = bt.xresources.apply_dpi
local naughty              = require("naughty")
local wibox                = require("wibox")


return {
    {
        {
            id            = "progress",
            value         = 0,
            forced_height = dpi(30),
            forced_width  = 100,
            paddings      = 0,
            border_width  = 0,
            color         = bt.notification_progress_color,
            widget        = wibox.widget.progressbar,
        },
        {
            {
                {
                    {
                        {
                            widget = naughty.widget.icon,
                        },
                        widget = wibox.container.place
                    },
                    widget = wibox.container.constraint,
                    strategy = "max",
                    width = dpi(20)
                },
                {
                    {
                        {
                            widget = naughty.widget.title,
                        },
                        widget = wibox.container.place
                    },
                    widget = wibox.container.constraint,
                },
                {
                    {
                        {
                            {
                                widget = naughty.widget.message,
                            },
                            layout = wibox.container.scroll.horizontal,
                            max_size = 400,
                            step_function = wibox.container.scroll.step_functions
                                .waiting_nolinear_back_and_forth,
                            speed = 25,
                        },
                        widget = wibox.container.place
                    },
                    widget = wibox.container.constraint,
                },
                spacing = bt.useless_gap,
                layout = wibox.layout.fixed.horizontal,
            },
            margins = { top = 2, bottom = 2, left = bt.useless_gap, right = bt.useless_gap },
            widget  = wibox.container.margin,
        },
        widget = wibox.layout.stack
    },
    id     = "background_role",
    widget = naughty.container.background,
}
