-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")
local systray = require("ui.popups.systray")


local capi = {
    awesome = awesome
}

local tray = { mt = {} }

tray.icons = {
    normal = bt.icon.menu_down,
    normal_focus = gcolor.recolor_image(bt.icon.menu_down, bt.fg_focus),
    active = bt.icon.menu_up,
    active_focus = gcolor.recolor_image(bt.icon.menu_up, bt.fg_focus)
}

local function on_press(self, _, _, btn)
    if btn == 1 then
        self:request_show()
    end
end

function tray:request_show()
    local instance = self._popup.instance
    if not instance then
        instance = self._popup(self._private.args)
    end

    if instance._private.screen ~= self._private.screen then
        instance:set_screen(self._private.screen)
        self._private.attach(instance)     -- auto detaches
    end

    instance:show()
end

local function on_remove(self)
    if not self._popup then return end

    local instance = self._popup.instance
    if instance and instance._private.screen == self._private.screen then
        instance:detach()
        instance:emit_signal("popup::hide")
    end
end

local function on_geometry_change(self, geometry)
    local width = geometry.width + 2 * bt.border_width
    self._private.args.width = width

    local instance = self._popup.instance
    if not instance then return end
    print("geo change tray")

    if instance._private.screen == self._private.screen then
        instance:emit_signal("update::width", width)
    end
end

function tray.new(args)
    args.icons = tray.icons
    args.popup = systray

    local ret = ibutton(args)
    gtable.crush(ret, tray, true)
    ret._private.args = {
        height = args.height,
    }

    ret:connect_signal("button::press", on_press)
    ret:connect_signal("bar::geometry", on_geometry_change)
    ret:connect_signal("bar::removed", on_remove)
    return ret
end

function tray.mt:__call(...)
    return tray.new(...)
end

return setmetatable(tray, tray.mt)
