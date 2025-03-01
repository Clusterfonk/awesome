-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")
local center = require("ui.popups.notification_center")


local notify = { mt = {} }

notify.icons = {
    normal = bt.icon.notification,
    normal_focus = gcolor.recolor_image(bt.icon.notification, bt.fg_focus),
    active = bt.icon.notification_muted,
    active_focus = gcolor.recolor_image(bt.icon.notification_muted, bt.fg_focus),
    unread = bt.icon.notification_unread,
    unread_focus = gcolor.recolor_image(bt.icon.notification_unread, bt.fg_focus)
}

local function on_press(self, _, _, btn, mods)
    if btn == 1 then
        local instance = self._popup.instance
        if instance then
            --instance:show()
        end
    end
end

local function on_remove(self)
    if not self._popup.instance then return end
    local instance = self._popup.instance

    local is_same_screen = instance._private.screen == self._private.screen
    local is_owner = instance.owner == self

    if is_owner then instance.owner = nil end

    if is_same_screen then
        instance:detach()
        if is_owner then instance:emit_signal("popup::hide") end
    end
end

function notify.new(args)
    args.icons = notify.icons
    args.popup = center

    local ret = ibutton(args)
    gtable.crush(ret, notify, true)

    ret:connect_signal("button::press", on_press)
    ret:connect_signal("bar::removed", on_remove)
    return ret
end

function notify.mt:__call(...)
    return notify.new(...)
end

return setmetatable(notify, notify.mt)
