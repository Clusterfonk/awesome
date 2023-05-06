-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local widget = require("wibox.widget")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")


textbox = { mt = {} }

function textbox:focus()
    self.in_focus = true 

    local span = string.format("<span foreground='%s'>", self._private.fg_focus)
    self.markup = span .. self.text .. "</span>"

    if self._private.old_wibox then
        self._private.old_wibox = mouse.current_wibox
        self._private.old_wibox.cursor = "hand2"
    end
end

function textbox:unfocus()
    self.in_focus = false

    local span = string.format("<span foreground='%s'>", self._private.fg_normal)
    self.markup = span .. self.text .. "</span>"

    if self._private.old_wibox then
        self._private.old_wibox.cursor = "left_ptr"
        self._private.old_wibox = nil
    end
end

function textbox:set_text(text)
    local span
    if in_focus then
        span = string.format("<span foreground='%s'>", self._private.fg_focus)
    else
        span = string.format("<span foreground='%s'>", self._private.fg_normal)
    end
    
    self.markup = span .. text .. "</span>"
end

function textbox:press(lx, ly, button, ...)
    if button == 1 then
        self._private.on_press(self)
    end
end

function textbox:release(lx, ly, button, ...)
    if button == 1 then
        self._private.on_release(self)
    end
end

--
function textbox.new(args)
    args = args or {}
    args.font = args.font or bt.font_name
    args.size = args.size or bt.font_size
    args.ignore_markup = args.ignore_markup or false
    
    local span = string.format("<span foreground='%s'>", args.fg_normal or bt.fg_normal)
    args.text = span .. args.text .. "</span>"

    local ret = widget.textbox(args.text, args.ignore_markup)
    ret.font = args.font .. " " .. args.size
    ret.align = args.align or "center"
    ret.valign = args.valign or "center"
    gtable.crush(ret, textbox, true)
    
    ret._private.fg_normal = args.fg_normal or bt.fg_normal 
    ret._private.fg_focus = args.fg_focus or bt.border_focus

    ret.in_focus = false
    ret:connect_signal("mouse::enter", textbox.focus)
    ret:connect_signal("mouse::leave", textbox.unfocus)

    if on_press then
        ret._private.on_press = on_press
        ret:connect_signal("button::press", textbox.press)
    end

    if on_release then
        ret._private.on_release = on_release
        ret:connect_signal("button::release", textbox.release)
    end
    return ret
end

function textbox.mt:__call(...)
    return textbox.new(...)
end

return setmetatable(textbox, textbox.mt)
