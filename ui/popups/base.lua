-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local gtimer = require("gears.timer")
local gtable = require("gears.table")

capi = {
    screen = screen
}


popup = { mt = {} }

function popup:show()
    if self.destory_timer then
        self.destroy_timer:stop()
    end

    self.hide_timer.timeout = self._private.timeout
    self.hide_timer:again()

    self.visible = true
end

function popup.hide(self)
    if self.visible then
        self.visible = false
        if self.destroy_timer then
            self.destroy_timer:again()
        end
    end

    if self.hide_timer then
        self.hide_timer:stop()
    end
end

function popup.mouse_leave(self)
    self.hide_timer.timeout = 0.4
    self.hide_timer:again()
end

function popup.mouse_enter(self)
    self.hide_timer:stop()
    if self.destroy_timer then
        self.destroy_timer:stop()
    end
end

function popup:destroy()
    if self.hide_timer then
        self.hide_timer:stop()
        self.hide_timer = nil
    end

    if self.destroy_timer then
        self.destroy_timer:stop()
        self.destroy_timer = nil
    end

    if self.detach_callback then
        self:detach_callback()
        self.detach_callback = nil
    end

    self.widget = nil
end

function popup:detach()
    if self.detach_callback then
        self:detach_callback()
        self.detach_callback = nil
    end
end

function popup.new(args)
    args = args or {}
    local ret = awful.popup {
        bg = args.bg or bt.bg_normal,
        fg = args.fg or bt.fg_normal,
        border_color = args.border_color or bt.border_normal,
        border_width = args.border_width or bt.border_width,
        ontop = args.ontop or true,
        visible = args.visible or false,
        widget = args.widget or {}
    }

    ret._private.screen = nil
    ret._private.timeout = args.timeout or 1
    ret.hide_timer = gtimer({
        timeout = args.timeout or 1,
        single_shot = true,
        callback = function()
            ret.hide(ret)
        end,
    })

    if args.destroy_timeout then
        ret.destroy_timer = gtimer({
            timeout = args.destroy_timeout,
            single_shot = true,
            callback = function()
                ret:destroy()
            end,
        })
    end

    ret:connect_signal("mouse::enter", popup.mouse_enter)
    ret:connect_signal("mouse::leave", popup.mouse_leave)
    ret:connect_signal("popup::hide", popup.hide)
    gtable.crush(ret, popup, true)
    return ret
end

function popup.mt:__call(...)
    return popup.new(...)
end

return setmetatable(popup, popup.mt)
