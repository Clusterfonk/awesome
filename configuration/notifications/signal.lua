local bt       = require("beautiful")
local cst      = require("naughty.constants")
local naughty  = require("naughty")
local nbox     = require("ui.widgets.nbox")

local _debug = require("_debug")
local center   = require("ui.popups.notification_center")
local template = require("ui.widgets.notification")

capi           = {
    screen = screen
}


local active_notifications = {}
local multi_screen = capi.screen.count() > 1 -- TODO: implement update logic when screen added / removed

center.signal:connect_signal("property::visible", function()
    local to_remove = {}
    for i, box in ipairs(active_notifications) do
        to_remove[i] = box
    end

    active_notifications = {}

    for _, box in pairs(to_remove) do
        if box then
            box:emit_signal("destroyed")
        end
    end
end)

naughty.connect_signal("request::display", function(n)
    if _debug.gc_finalize then
        _debug.attach_finalizer(n, "notification")
    end

    if bt.notification_dnd then
        return n:destroy(cst.notification_closed_reason.silent)
    end

    if multi_screen and n.screen == capi.screen.primary then
        n.screen = capi.screen.instances()[2]
    end

    n.app_name = n.app_name or "System"
    n.icon = n.icon or bt.icon.wlan
    n.message = n.message or 'No message provided'
    n.title = n.title or 'System Notification'

    center.add(n, os.time())
    if center.instance and center.instance.visible then return end

    local box = nbox {
        notification = n,
        ontop = true,
        widget_template = template
    }

    table.insert(active_notifications, box)
    box:connect_signal("box::destroyed", function(self)
        for i, b in ipairs(active_notifications) do
            if b == self then
                table.remove(active_notifications, i)
            end
        end
    end)
end)
