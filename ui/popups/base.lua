-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local gtable = require("gears.table")
local dpi = bt.xresources.apply_dpi

local debug = require("utilities.debug")


popup = { mt = {} }

local function create_widget(self)
    self:set_widget(
        wibox.widget {
                text = "Monday",
                widget = wibox.widget.textbox
        })

end

local function show(self)
    if self:get_widget() == nil then
        create_widget(self)

        awful.placement.next_to(self, {
            preferred_position = "bottom",
            preferred_anchor = "middle",
            self._private.anchor_geo
        })
    end
    self.visible = true
end

local function hide(self)
    if self:get_widget() ~= nil then
        self:set_widget(nil)
        --self:get_widget():reset()
    end
    self.visible = false
end

local function new(args)
    ret = awful.popup {
        bg = bt.bg_normal,
        fg = bt.fg_normal,
        border_color = bt.border_normal,
        border_width = dpi(2),
        ontop = true,
        visible = false,
        widget = {}
    }

    ret:set_widget(nil)
    rawset(ret._private, "anchor_geo", args.geometry)
    ret._private.anchor_geo = args.geometry

    ret:connect_signal("popup::show", show)
    ret:connect_signal("popup::hide", hide)

    gtable.crush(ret, popup, true)
    return ret
end

function popup.mt:__call(...)
    return new(...)
end

return setmetatable(popup, popup.mt)
