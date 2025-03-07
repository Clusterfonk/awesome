-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")

local ibutton = require("ui.widgets.ibutton")
local progressbar = require("ui.popups.progressbar")


local microphone = { mt = {} }

microphone.icons = {
    normal = bt.icon.mic,
    normal_focus = gcolor.recolor_image(bt.icon.mic, bt.fg_focus),
    active = bt.icon.mic_muted,
    active_focus = gcolor.recolor_image(bt.icon.mic_muted, bt.fg_focus)
}

local function on_press(self, _, _, btn, mods)
    if btn == 1 then
        self._private.active = not self._private.active
        self:update_icon()
    elseif btn == 4 then
        if mods[1] == "Shift" then
            self.value = self.value + 1 -- daemon signal <----
            self:request_show()
        else
            self.value = self.value + 5 -- daemon signal <----
            self:request_show()
        end
    elseif btn == 5 then
        if mods[1] == "Shift" then
            self.value = self.value - 1 -- daemon signal <----
            self:request_show()
        else
            self.value = self.value - 5 -- daemon signal <----
            self:request_show()
        end
    end
end

local function on_geometry_change(self, geometry)
    local width = geometry.width + 2 * bt.border_width
    self._private.args.width = width

    if self._popup.instance and self._popup.instance.owner and
        self._popup.instance.owner == self then
        self._popup.instance:emit_signal("update::width", width)
    end
end

function microphone:take_ownership(instance)
    instance.owner = self
    instance:init(self._private.args)
end


function microphone:request_show()
    local instance = self._popup.instance

    if not instance then -- create new one
        instance = self._popup(self._private.args)
        instance.owner = self
    elseif instance.owner ~= self then
        self:take_ownership(instance)
    end

    if instance._private.screen ~= self._private.screen then
        instance._private.screen = self._private.screen
        self._private.attach(instance) -- auto detaches
    end
    instance:show()
end

function microphone:on_remove()
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

function microphone.new(args)
    args.icons = microphone.icons
    args.popup = progressbar

    local ret = ibutton(args)
    gtable.crush(ret, microphone, true)
    ret._private.args = {
        height = args.height,
        color = args.color,
    }
    ret.value = 50 ---- <- this will be managed by a signal completly

    ret:connect_signal("button::press", on_press)
    ret:connect_signal("bar::geometry", on_geometry_change)
    ret:connect_signal("bar::removed", microphone.on_remove)
    return ret
end

function microphone.mt:__call(...)
    return microphone.new(...)
end

return setmetatable(microphone, microphone.mt)
