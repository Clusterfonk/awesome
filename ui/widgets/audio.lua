-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")

local ibutton = require("ui.widgets.ibutton")
local progressbar = require("ui.popups.progressbar")


local audio = { mt = {} }

audio.icons = {
    normal = bt.icon.speaker,
    normal_focus = gcolor.recolor_image(bt.icon.speaker, bt.fg_focus),
    active = bt.icon.headphones,
    active_focus = gcolor.recolor_image(bt.icon.headphones, bt.fg_focus)
}

-- information is retrievable from the bus (which will be cached by the daemon)
local command = "amixer -c 0 get Headphone | grep '\\[on\\]'"

local function on_press(self, _, _, btn, mods)
    if btn == 1 then
        self._private.active = not self._private.active -- TODO: actual logice
        self:update_icon()
        awful.spawn.easy_async_with_shell(command, function(out)
            if out == "" then
                --awful.spawn.with_shell("amixer -c 0 sset Headphone toggle >> /dev/null 2>&1")
            else
                --awful.spawn.with_shell("amixer -c 0 sset Headphone toggle >> /dev/null 2>&1")
            end
        end)
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
            -- daemon pactl @DEFAULT_SINK - 5
            self.value = self.value - 5 -- daemon signal <----
            self:request_show()
        end
    end
end

function audio.volume_change(self, volume)
    if self._popup.instance then
        if volume ~= self.value then
            self._popup.instance:emit_signal("update::value")
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

function audio:take_ownership(instance)
    instance.owner = self
    instance:init(self._private.args)
end

function audio:request_show()
    local instance = self._popup.instance

    if not instance then
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

function audio.new(args)
    args.icons = audio.icons
    args.popup = progressbar

    local ret = ibutton(args)
    gtable.crush(ret, audio, true)
    ret._private.args = {
        height = args.height,
        color = args.color,
        screen = args.screen
    }
    ret.value = 50 ---- <- this will be managed by a signal completly
    -- even able to say ret.value == nil -> not ready now or not reachable

    ret:connect_signal("button::press", on_press)
    ret:connect_signal("bar::geometry", on_geometry_change)
    ret:connect_signal("bar::removed", on_remove)
    return ret
end

function audio.mt:__call(...)
    return audio.new(...)
end

return setmetatable(audio, audio.mt)
