-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local widget = require("wibox.widget")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")


iconbox = { mt = {} }

function iconbox:focus()
    self:set_image(self._private.icon_focus)
end

function iconbox:unfocus()
    self:set_image(self._private.icon_normal)
end

--
function iconbox.new(icon, resize_allowed, clip_shape, ...)
    local ret = widget.imagebox(icon, resize_allowed, clip_shape, ...)
    gtable.crush(ret, iconbox, true)
    
    ret._private.icon_normal = icon
    ret._private.icon_focus = gcolor.recolor_image(icon, bt.border_focus)

    ret:connect_signal("mouse::enter", iconbox.focus, ret)
    ret:connect_signal("mouse::leave", iconbox.unfocus, ret)
    return ret
end

function iconbox.mt:__call(...)
    return iconbox.new(...)
end

return setmetatable(iconbox, iconbox.mt)