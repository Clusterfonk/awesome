-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local bt = require("beautiful")
local naughty = require("naughty")
local dpi = bt.xresources.apply_dpi

local button = require("ui.widgets.button")
local base = require("ui.popups.base")

-- Notification storage module (separate from popup instance)
local notification_store = {}
notification_store.notifications = {}
notification_store.next_id = 1

-- Add a notification to the store
function notification_store.add(notification)
    local id = notification_store.next_id
    notification_store.next_id = notification_store.next_id + 1

    local stored_notification = {
        id = id,
        title = notification.title or "",
        message = notification.message or "",
        app_name = notification.app_name or "",
        icon = notification.icon,
        timeout = notification.timeout,
        timestamp = os.time(),
        urgency = notification.urgency or "normal"
    }

    table.insert(notification_store.notifications, 1, stored_notification)

    -- Emit signal to notify listeners that a notification has been added
    awesome.emit_signal("notification_store::added", stored_notification)
    return id
end

-- Remove a notification from the store
function notification_store.remove(id)
    for i, notification in ipairs(notification_store.notifications) do
        if notification.id == id then
            table.remove(notification_store.notifications, i)
            awesome.emit_signal("notification_store::removed", id)
            return true
        end
    end
    return false
end

-- Get all notifications
function notification_store.get_all()
    return notification_store.notifications
end

-- Clear all notifications
function notification_store.clear_all()
    notification_store.notifications = {}
    awesome.emit_signal("notification_store::cleared")
end

-- Create the notification center module
local notification_center = { mt = {} }
setmetatable(notification_center, { __index = base })

-- Template for text widgets
local function create_text_widget(text, font, halign)
    return wibox.widget {
        text = text or "",
        font = font,
        widget = wibox.widget.textbox,
        halign = halign or "left"
    }
end

-- Template for container widgets
local function create_container(widget, bg, fg, margins, shape_fn)
    local container = wibox.widget {
        {
            widget,
            margins = margins or dpi(10),
            widget = wibox.container.margin
        },
        bg = bg,
        fg = fg,
        widget = wibox.container.background
    }

    if shape_fn then
        container.shape = shape_fn
    end

    return container
end

-- Time formatting function
local function format_time(timestamp)
    local diff = os.time() - timestamp

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

-- Create a single notification widget
local function create_notification_widget(notification)
    -- Create close button
    local close_button = button {
        widget = create_text_widget(
            "×",
            bt.notification_close_font or "sans 14",
            "center"
        )
    }
    close_button.forced_width = dpi(30)
    close_button.forced_height = dpi(30)

    -- Time widget that will be updated periodically
    local time_widget = create_text_widget(
        format_time(notification.timestamp),
        bt.notification_time_font or "sans 10",
        "right"
    )

    -- Update time periodically
    local time_timer = gtimer {
        timeout = 60,
        autostart = true,
        call_now = false,
        callback = function()
            time_widget:set_text(format_time(notification.timestamp))
        end
    }

    -- App name widget
    local app_widget = create_text_widget(
        notification.app_name or "",
        bt.notification_app_font or "sans bold 10"
    )

    -- Title widget
    local title_widget = create_text_widget(
        notification.title or "",
        bt.notification_title_font or "sans bold 11"
    )

    -- Message widget
    local message_widget = create_text_widget(
        notification.message or "",
        bt.notification_message_font or "sans 10"
    )

    -- Layout structure
    local widget = wibox.widget {
        create_container(
            {
                {
                    app_widget,
                    time_widget,
                    layout = wibox.layout.align.horizontal
                },
                {
                    title_widget,
                    close_button,
                    layout = wibox.layout.align.horizontal
                },
                message_widget,
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(4)
            },
            notification.urgency == "critical" and bt.notification_critical_bg or bt.notification_bg or bt.bg_normal,
            notification.urgency == "critical" and bt.notification_critical_fg or bt.notification_fg or bt.fg_normal,
            dpi(10),
            function(cr, width, height)
                gshape.rounded_rect(cr, width, height, dpi(6))
            end
        ),
        margins = dpi(5),
        widget = wibox.container.margin,
        id = "notification_" .. notification.id
    }

    close_button:connect_signal("button::press", function(_, _, _, btn)
        if btn == 1 then
            notification_store.remove(notification.id)
        end
    end)

    -- Stop the timer when the widget is destroyed
    widget:connect_signal("destroy", function()
        if time_timer.started then
            time_timer:stop()
        end
    end)

    -- Store a reference to the timer for later cleanup
    widget.time_timer = time_timer

    return widget
end

-- Create the notifications container
local function create_notifications_container()
    local container = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(2),
    }

    -- Populate with existing notifications
    local notifications = notification_store.get_all()
    for _, notification in ipairs(notifications) do
        container:add(create_notification_widget(notification))
    end

    -- Connect signals to update container when notifications change
    awesome.connect_signal("notification_store::added", function(notification)
        local widget = create_notification_widget(notification)
        container:insert(1, widget)
    end)

    awesome.connect_signal("notification_store::removed", function(id)
        for i, child in ipairs(container.children) do
            if child.id == "notification_" .. id then
                if child.time_timer and child.time_timer.started then
                    child.time_timer:stop()
                end
                container:remove(i)
                break
            end
        end
    end)

    awesome.connect_signal("notification_store::cleared", function()
        -- Stop all timers before clearing
        for _, child in ipairs(container.children) do
            if child.time_timer and child.time_timer.started then
                child.time_timer:stop()
            end
        end
        container:reset()
    end)

    return container
end

-- Create a placeholder widget for when there are no notifications
local function create_empty_placeholder()
    return create_container(
        create_text_widget(
            "No notifications",
            bt.notification_empty_font or "sans 12",
            "center"
        ),
        bt.notification_empty_bg or bt.bg_normal,
        bt.notification_empty_fg or bt.fg_normal,
        dpi(50)
    )
end

-- Setup notification handling with naughty
naughty.connect_signal("request::display", function(n)
    print("adding notification to the store")
    -- Store the notification
    local notification = {
        title = n.title,
        message = n.message,
        app_name = n.app_name,
        icon = n.icon,
        timeout = n.timeout,
        urgency = n.urgency
    }
    notification_store.add(notification)
end)

-- Destroy function
function notification_center:destroy()
    -- Disconnect all signals
    for _, child in ipairs(self.widget:get_all_children()) do
        if child.time_timer and child.time_timer.started then
            child.time_timer:stop()
        end
    end

    self._parent.destroy(self)
    notification_center.instance = nil

    -- Garbage collection
    gtimer.delayed_call(function()
        collectgarbage("collect")
        collectgarbage("collect")
    end)
end

-- Create the notification center
function notification_center.new(args)
    args = args or {}
    args.ontop = args.ontop or true
    args.visible = args.visible or false
    args.destroy_timeout = 20

    local ret = base(args)
    rawset(ret, "_parent", { destroy = ret.destroy })
    gtable.crush(ret, notification_center, true)

    -- Create notifications container
    local notifications_container = create_notifications_container()

    -- Create empty placeholder
    local empty_placeholder = create_empty_placeholder()

    -- Create scrollbox
    local scrollbox = wibox.widget {
        notifications_container,
        id = "scrollbox",
        layout = wibox.container.scroll.vertical,
        step = 50,
        fps = 60
    }

    -- Main container
    local main_container = wibox.widget {
        layout = wibox.layout.stack,
        top_only = true,
        empty_placeholder,
        scrollbox
    }

    -- Update visibility of placeholder based on notifications
    local function update_placeholder_visibility()
        if #notification_store.notifications == 0 then
            main_container:raise_widget(empty_placeholder)
        else
            main_container:raise_widget(scrollbox)
        end
    end

    awesome.connect_signal("notification_store::added", update_placeholder_visibility)
    awesome.connect_signal("notification_store::removed", update_placeholder_visibility)
    awesome.connect_signal("notification_store::cleared", update_placeholder_visibility)

    -- Initial visibility check
    update_placeholder_visibility()

    -- Create main widget
    ret.widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        {
            main_container,
            widget = wibox.container.constraint,
            height = dpi(500),
            width = dpi(350)
        }
    }

    -- Handle scrolling
    ret:connect_signal("button::press", function(_, _, _, button)
        if button == 3 then -- right click
            notification_store:clear_all()
        end
        if button == 4 then     -- Scroll up
            scrollbox:scroll(-30)
        elseif button == 5 then -- Scroll down
            scrollbox:scroll(30)
        end
    end)

    local _debug = require("_debug")
    if _debug.gc_finalize then
        _debug.attach_finalizer(ret, "notification_center")
    end

    return ret
end

function notification_center.mt:__call(...)
    if notification_center.instance then
        return notification_center.instance
    end
    notification_center.instance = notification_center.new(...)
    return notification_center.instance
end

return setmetatable(notification_center, notification_center.mt)
