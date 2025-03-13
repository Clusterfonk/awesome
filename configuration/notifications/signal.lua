local bt                   = require("beautiful")
local cst                  = require("naughty.constants")
local naughty              = require("naughty")
local nbox                 = require("ui.widgets.nbox")

local template = require("ui.widgets.notification")

capi = {
    screen = screen
}


-- TODO: implement update logic when screen added / removed
local multi_screen = capi.screen.count() > 1

naughty.connect_signal("request::display", function(n)
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

    local box = nbox {
        notification = n,
        ontop = true,
        widget_template = template
    }

    local _debug = require("_debug")
    if _debug.gc_finalize then
        _debug.attach_finalizer(box, "nbox")
    end
end)
