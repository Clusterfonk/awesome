-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local gtimer = require("gears.timer")
local gtable = require("gears.table")
local dpi = bt.xresources.apply_dpi


popup = { mt = {} }

function popup:show()
    self.auto_hide_timer.timeout = self._private.timeout
    self.auto_hide_timer:again()
    if not self.visible then
        self.visible = true
    end
end

function popup:hide()
    if self.visible then
        self.visible = false
    end
end

function popup.new(args)
    local ret = awful.popup {
        screen = args.screen,
        bg = args.bg or bt.bg_normal,
        fg = args.fg or bt.fg_normal,
        border_color = bt.border_normal,
        border_width = args.border_width or dpi(2, args.screen),
        ontop = true,
        visible = false,
        placement = args.placement or {},
        widget = args.widget or {}
    }

    ret._private.timeout = args.timeout or 1

    ret.auto_hide_timer = gtimer({
            timeout = args.timeout or 1,
            single_shot = true,
            callback = function()
                ret:emit_signal("popup::hide")
            end,
    })

    ret:connect_signal("mouse::leave", function(self)
        self.auto_hide_timer.timeout = 0.4
        self.auto_hide_timer:again()
	end)

	ret:connect_signal("mouse::enter", function(self)
		self.auto_hide_timer:stop()
	end)

    ret:connect_signal("popup::show", function(self) self:show() end)
    ret:connect_signal("popup::hide", function(self) self:hide() end)

    gtable.crush(ret, popup, true)
    return ret
end

function popup.mt:__call(...)
    return popup.new(...)
end

return setmetatable(popup, popup.mt)
