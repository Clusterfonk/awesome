-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local widget = require("wibox.widget")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")

local popup = require("ui.popup.calendar")


_clock = { mt = {} }

function _clock:focus()
    local span = string.format("<span foreground='%s'>", self.focus_color)
    self.markup = span .. self.text .. "</span>" 

    self._private.old_wibox = mouse.current_wibox
    self._private.old_wibox.cursor = "hand2"
end

function _clock:unfocus()
    self.markup = self.text  

    if self._private.old_wibox then
        self._private.old_wibox.cursor = "left_ptr"
        self._private.old_wibox = nil
    end
end

--
function _clock.new(args)
    args = args or {}
    local ret = widget({
        widget = widget.textclock,
        format = args.format,
        font = args.font
    })
    gtable.crush(ret, _clock, true)
    ret.focus_color = args.focus_color or bt.border_focus
     
    ret:connect_signal("mouse::enter", _clock.focus)
    ret:connect_signal("mouse::leave", _clock.unfocus)
    
    ret._private.popup = popup(args)
    ret:connect_signal("button::press", function()
        ret._private.popup:emit_signal("request::show", args.screen)
    end)
    return ret
end

function _clock.mt:__call(...)
    return _clock.new(...)
end

return setmetatable(_clock, _clock.mt)
