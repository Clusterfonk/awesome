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
    return wibox.widget.base.empty_widget()
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
    print("hiding")
    if not self._private.hide_anim.state then
        self._private.hide_anim:set({
            target = dpi(0, s),
            pos = self.widget.forced_height
        })
        self._private.hide_anim:connect_signal("ended", function() 
            self.cleanup()
        end)
    end
end

function _widget_popup.new(args)
    print("creation")
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

    ret._private.hide_anim:connect_signal("started", 
    function() 
        ret._private.show_anim:stop()
    end)

    local hide_widget = function() ret:hide() end
    local hide_button = awful.button({ }, 1, hide_widget)
    local hide_rbutton = awful.button({ }, 3, hide_widget)
    local hide_except_on_self = function(w, _, _, button) 
        if w ~= ret then -- MAYBE: could get a list of widgets that dont clear it ?
            if button == 1 or button == 3 then
                ret:hide() 
            end
        end 
    end 
    
    ret._private.hide_anim:connect_signal("started", function()
        ret._private.keygrabber:stop()
        for _, button in pairs({hide_button, hide_rbutton}) do
            awful.mouse.remove_global_mousebinding(button)
            awful.mouse.remove_client_mousebinding(button)
        end            
        wibox.disconnect_signal("button::press", hide_except_on_self)
    end)

    ret:connect_signal("property::visible", 
        function(w)
            if w.visible then
                for _, button in pairs({hide_button, hide_rbutton}) do
                    awful.mouse.append_global_mousebinding(button)
                    awful.mouse.append_client_mousebinding(button)
                end    
                wibox.connect_signal("button::press", hide_except_on_self)
            end
        end)

    ret._private.keygrabber = awful.keygrabber {
        allowed_keys = {},
        stop_callback = hide_widget
    }

    return ret
end

function _widget_popup.mt:__call(...)
    return _widget_popup.new(...)
end

return setmetatable(_widget_popup, _widget_popup.mt)
