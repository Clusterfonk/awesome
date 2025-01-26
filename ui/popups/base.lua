-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local gtable = require("gears.table")
local dpi = bt.xresources.apply_dpi


popup = { mt = {} }

function popup:create_widget()
end

function popup:show()
    if self:get_widget() == nil then
        self:create_widget()
        --self.auto_hide_timer:again()
    end
    self.visible = true
end

function popup:hide()
    if self:get_widget() ~= nil then
        self:set_widget(nil)
    end
    self.visible = false
end

local function new(args)
    local ret = awful.popup {
        screen = args.screen,
        bg = bt.bg_normal,
        fg = bt.fg_normal,
        border_color = bt.border_normal,
        border_width = dpi(2),
        ontop = true,
        visible = false,
        widget = {}
    }
    ret:set_widget(nil)
    local gtimer = require "gears.timer"
    ret.auto_hide_timer = gtimer({
            timeout = 0.5,
            single_shot = true,
            callback = function()
                ret:emit_signal("popup::hide")
            end,
    })

    awful.placement.top_left(ret, {margins = {top = args.top, left = args.left}})

    ret:connect_signal("mouse::leave", function()
        ret.auto_hide_timer:again()
	end)

	ret:connect_signal("mouse::enter", function()
		ret.auto_hide_timer:stop()
	end)

    ret:connect_signal("popup::show", function() ret:show() end)
    ret:connect_signal("popup::hide", function() ret:hide() end)

    gtable.crush(ret, popup, true)

    return ret
end

function popup.mt:__call(...)
    return new(...)
end

return setmetatable(popup, popup.mt)
