local awful = require("awful")
local ruled = require("ruled")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi
local naughty = require("naughty")
local nbox = require("ui.widgets.nbox")
local debug = require("util.debug")


local capi = {
    screen = screen
}

-- NOTE: notification builder
notification_builder = { mt = {} }

ruled.notification.connect_signal("request::rules", function() -- TODO: /configuration/ folder
    --ruled.notification.append_rule({
    --	rule = {
    --		app_name = "blueman",
    --	},
    --	properties = {
    --		icon = bt.get_svg_icon({ "blueman-device" }),
    --	},
    --})
end)

naughty.connect_signal("request::display", function(n)
    local side_toggle = true -- will be turned into "left" "right"
    local dnd = bt.notification_dnd

    if dnd then
        n:destroy("dnd")
    end
    n.app_name = n.app_name or "System"
    n.icon = n.icon or bt.icon.wlan
    n.message = n.message or 'No message provided'
    n.title = n.title or 'System Notification'

    local notification = wibox.widget {
        {
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
                                widget = naughty.widget.message,
                            },
                            widget = wibox.container.place
                        },
                        widget = wibox.container.constraint,
                    },
                    spacing = bt.useless_gap,
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = {top = 2, bottom = 2, left = bt.useless_gap, right = bt.useless_gap},
                widget  = wibox.container.margin,
            },
            id     = "background_role",
            widget = naughty.container.background,
        },
        strategy = "exact",
        height   = dpi(30),
        widget   = wibox.container.constraint,
    }

    local screen = n.screen or awful.screen.focused
    local side = "left"

    if side_toggle then
        n.max_width = dpi(444) - bt.useless_gap
        -- check if one was already fired or have a toggle var
        local box = nbox {
            notification = n,
            position = "top_right",
            widget_template = notification
        }
    else
        n.max_width = dpi(600)
        local box = nbox {
            notification = n,
            position = "top_left",
            widget_template = notification
        }
    end

    side_toggle = not side_toggle
end)

function notification_builder.new(args)
end

function notification_builder.mt:__call(...)
    return notification_builder.new(...)
end

return setmetatable(notification_builder, notification_builder.mt)
