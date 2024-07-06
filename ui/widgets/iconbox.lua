-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local widget = require("wibox.widget")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")


iconbox = { mt = {} }

function iconbox:focus()
    self.in_focus = true
    self:set_image(self._private.icon_focus)

    if self._private.old_wibox then
        self._private.old_wibox = mouse.current_wibox
        self._private.old_wibox.cursor = "hand2"
    end
end

function iconbox:unfocus()
    self.in_focus = false
    self:set_image(self._private.icon_normal)

    if self._private.old_wibox then
        self._private.old_wibox.cursor = "left_ptr"
        self._private.old_wibox = nil
    end
end

function iconbox:set_icon(icon)
    self._private.icon_focus = gcolor.recolor_image(icon, self._private.fg_focus)
    self._private.icon_normal = gcolor.recolor_image(icon, self._private.fg_normal)

    if self.in_focus then
        self:set_image(self._private.icon_focus)
    else
        self:set_image(self._private.icon_normal)
    end
end

function iconbox:press(lx, ly, button, ...)
    if button == 1 then
        self._private.on_press(self)
    end
end

function iconbox:release(lx, ly, button, ...)
    if button == 1 then
        self._private.on_release(self)
    end
end

--
function iconbox.new(args)
    args = args or {}

    local ret = widget.imagebox(args.icon, args.resize_allowed, args.clip_shape)
    gtable.crush(ret, iconbox, true)

    if args.size then
        ret.forced_height = args.size
        ret.forced_width = args.size
    end

    ret._private.fg_normal = args.fg_normal or bt.fg_normal
    ret._private.fg_focus = args.fg_focus or bt.border_focus
    ret._private.icon_normal = gcolor.recolor_image(args.icon, ret._private.fg_normal)
    ret._private.icon_focus = gcolor.recolor_image(args.icon, ret._private.fg_focus)

    ret.in_focus = false
    ret:connect_signal("mouse::enter", iconbox.focus)
    ret:connect_signal("mouse::leave", iconbox.unfocus)

    if args.on_press then
        ret._private.on_press = args.on_press
        ret:connect_signal("button::press", iconbox.press)
    end

    if args.on_release then
        ret._private.on_release = args.on_release
        ret:connect_signal("button::release", iconbox.release)
    end
    return ret
end

function iconbox.mt:__call(...)
    return iconbox.new(...)
end

return setmetatable(iconbox, iconbox.mt)
