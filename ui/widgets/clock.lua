-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local widget = require("wibox.widget")
local gtable = require("gears.table")
local bt = require("beautiful")

local popup = require("ui.popup.calendar")


_clock = { mt = {} }

function _clock:focus()
    local span = string.format("<span foreground='%s'>", self.focus_color)
    self.markup = span .. self.text .. "</span>"
end

function _clock:unfocus()
    self.markup = self.text
end

function _clock.new(args)
    args = args or {}
    local ret = widget({
        widget = widget.textclock,
        format = args.format,
        refresh = args.refresh,
        font = args.font
    })
    gtable.crush(ret, _clock, true)
    --ret.focus_color = args.focus_color or bt.border_focus
    ret.focus_color = "#b8bb26"

    ret:connect_signal("mouse::enter", _clock.focus)
    ret:connect_signal("mouse::leave", _clock.unfocus)

    --ret._private.popup = popup(args)
    ret:connect_signal("button::press", function()
        --ret._private.popup:emit_signal("request::show", args.screen)
    end)

    return ret
end

function _clock.mt:__call(...)
    return _clock.new(...)
end

return setmetatable(_clock, _clock.mt)
