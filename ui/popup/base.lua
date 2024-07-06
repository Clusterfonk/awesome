-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local gears = require("gears")
local gtable = gears.table
local animation = require("modules.animation")
local dpi = bt.xresources.apply_dpi


_widget_popup = { mt = {} }

function _widget_popup:create_widget(s)
end

function _widget_popup:show(s)
    if not self.visible then
        _widget = self:create_widget(s)
        self:set_widget(wibox.widget({
            {
                widget = _widget
            },
            widget = wibox.container.constraint,
            forced_height = 0,
            strategy = "exact"
        }))

        if s then self:set_screen(s) end
        self._private.show_anim:set({
            target = dpi(_widget.height_needed, s),
            pos = self.widget.forced_height
        })
    end
end

function _widget_popup:hide()
    if not self._private.hide_anim.state then
        self._private.hide_anim:set({
            target = dpi(0, s),
            pos = self.widget.forced_height
        })
    end
end

function _widget_popup.new(args)
    args = args or {}
    local ret = awful.popup({
        preferred_positions = "bottom",
        bg = args.bg or bt.bg_normal,
        fg = args.fg or bt.fg_normal,
        border_color = bt.border_normal,
        border_width = dpi(2, s),
        ontop = true,
        visible = false,
        widget = {},
    })

    ret:set_widget(nil)
    gtable.crush(ret, _widget_popup, true)

    ret:connect_signal("request::show", ret.show, ret)

    ret._private.show_anim = animation:new {
        easing = animation.easing.outExpo,
        duration = 0.6,
        update = function(self, pos)
            ret.widget:set_forced_height(pos)
        end
    }

    ret._private.show_anim:connect_signal("started", function()
        ret._private.hide_anim:stop()
        ret.visible = true
        ret._private.keygrabber:start()
    end)

    ret._private.hide_anim = animation:new {
        easing = animation.easing.inExpo,
        duration = 0.3,
        update = function(self, pos)
            ret.widget:set_forced_height(pos)
        end
    }

    ret._private.hide_anim:connect_signal("ended",
    function()
        ret.visible = false
        ret.widget:set_widget(nil)
    end)

    local hide_on_click = function()
        if ret.visible then
            ret:hide()
        end
    end

    local hide_except_on_self = function(w, _, _, button)
        if w ~= ret then
            if button == awful.button.names.LEFT
            or button == awful.button.names.RIGHT then
                ret:hide()
            end
        end
    end

    local lbutton = awful.button({}, awful.button.names.LEFT, hide_on_click)
    local rbutton = awful.button({}, awful.button.names.RIGHT, hide_on_click)
    -- TODO: mousebindings are not being removed
    root.buttons(awful.util.table.join(lbutton, rbutton))

    ret:connect_signal("property::visible",
        function(w)
            if w.visible then
                awful.mouse.append_client_mousebindings({lbutton, rbutton})
                wibox.connect_signal("button::press", hide_except_on_self)
            end
        end)

    ret._private.hide_anim:connect_signal("started",
    function()
        ret._private.show_anim:stop()
        awful.mouse.remove_client_mousebinding(lbutton)
        awful.mouse.remove_client_mousebinding(rbutton)
        wibox.disconnect_signal("button::press", hide_except_on_self)
    end)

    ret._private.hide_anim:connect_signal("started", function()
        ret._private.keygrabber:stop()
    end)

    ret._private.keygrabber = awful.keygrabber {
        keypressed_callback = hide_on_click
    }

    return ret
end

function _widget_popup.mt:__call(...)
    return _widget_popup.new(...)
end

return setmetatable(_widget_popup, _widget_popup.mt)
