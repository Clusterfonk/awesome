-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local naughty = require("naughty")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi


local entry = { mt = {} }


local function format_time(time)
    local diff = os.time() - time

    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        local mins = math.floor(diff / 60)
        return mins .. (mins == 1 and " min ago" or " mins ago")
    elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        return hours .. (hours == 1 and " hour ago" or " hours ago")
    else
        local days = math.floor(diff / 86400)
        return days .. (days == 1 and " day ago" or " days ago")
    end
end

function entry.new(args)
    local header = {
        {
            {
                { -- app icon
                    id = "app_icon",
                    widget = wibox.widget.imagebox,
                    halign = "center",
                    valign = "center"
                },
                widget = wibox.container.place
            },
            widget = wibox.container.constraint,
            strategy = "max",
            width = dpi(15, args.screen)
        },
        { -- app name
            id = "napp_name",
            widget = naughty.widget.title,
            font = bt.notification_header_font,
            halign = "left",
            valign = "center"
        },
        { -- Time
            id = "time",
            widget = wibox.widget.textbox,
            font = bt.notification_header_font,
            halign = "right",
            valign = "center"
        },
        layout = wibox.layout.fixed.horizontal,
        spacing = bt.useless_gap,
        fill_space = true
    }

    local message = wibox.widget {
        widget = naughty.widget.message,
        halign = "left",
        valign = "center",
        font = bt.notification_message_font,
    }

    local title = wibox.widget {
        widget = naughty.widget.title,
        font = bt.notification_title_font,
        halign = "left",
        valign = "center"
    }

    local body = { -- Body
        {          -- Image
            {
                {
                    id = "nicon",
                    widget = naughty.widget.icon,
                    halign = "center",
                    valign = "center",
                },
                widget = wibox.container.place
            },
            widget = wibox.container.constraint,
            strategy = "max",
            width = dpi(40, args.screen)
        },
        {
            title,
            {
                {
                    message,
                    layout = wibox.container.scroll.horizontal,
                    max_size = dpi(280, args.screen),
                    step_function = wibox.container.scroll.step_functions
                        .waiting_nolinear_back_and_forth,
                    speed = 25,
                },
                widget = wibox.container.constraint,
                strategy = "exact",
                width = dpi(300, args.screen),
                height = dpi(50, args.screen)
            },
            layout = wibox.layout.fixed.vertical,
        },
        layout = wibox.layout.fixed.horizontal,
        spacing = bt.useless_gap * 2
    }

    local ret = wibox.widget {
        {
            {
                {
                    {
                        header,
                        widget = wibox.container.margin,
                        margins = { left = 10, right = 10, top = bt.useless_gap, bottom = bt.useless_gap }
                    },
                    widget = wibox.container.background,
                    border_width = 2
                },
                {
                    body,
                    widget = wibox.container.margin,
                    margins = { left = 10, right = 10, bottom = bt.useless_gap }
                },
                layout = wibox.layout.fixed.vertical,
                spacing = bt.useless_gap,
            },
            widget = wibox.container.background,
            border_width = 2,
            bg = bt.bg_normal
        },
        widget = wibox.container.constraint,
        strategy = "max",
        width = dpi(600, args.screen),
        height = args.entry_height
    }

    ret:connect_signal("entry::init", function(self, n, t)
        local app_icon = self:get_children_by_id("app_icon")[1]
        local ntime = self:get_children_by_id("time")[1]
        local napp_name = self:get_children_by_id("napp_name")[1]

        local nicon = self:get_children_by_id("nicon")[1]

        title.notification = n
        title:emit_signal("widget::redraw_needed")

        app_icon.image = n.app_icon
        nicon.notification = n

        message.notification = n
        message:emit_signal("widget::redraw_needed")

        napp_name.notification = n
        napp_name.text = n.app_name
        napp_name.font = bt.notification_header_font

        ntime.t = t
        ntime.text = format_time(t)

        gtimer.weak_start_new(60, function()
            ntime:set_text(format_time(ntime.t))
        end)
    end)

    gtable.crush(ret, entry, true)
    return ret
end

function entry.mt:__call(...)
    return entry.new(...)
end

return setmetatable(entry, entry.mt)
