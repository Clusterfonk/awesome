-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi
local os = os

local base_popup = require("ui.popup.base")
local textbox = require("ui.widgets.textbox")
local iconbox = require("ui.widgets.iconbox")


_test_popup = { mt= {} }

function _test_popup:create_widget(s)
    ret = wibox.widget({
        {   
            widget=wibox.widget.textbox("asd")
        },
        widget = wibox.container.constraint,
        forced_width = self._private.width,
    })
    rawset(ret, "height_needed", 250)
    return ret
end

function _test_popup:cleanup()
end

function _test_popup.new(args)
    args = args or {}
    local ret = base_popup(args)
    ret._private.width = args.width
    ret.placement = function(w)
        awful.placement.top_left(w, {
            margins = {top = args.bar_height + 2*dpi(bt.taglist_border_width, s) + args.bar_offset + bt.useless_gap + 2*w.border_width,
                       left = 2 * dpi(bt.useless_gap, s)}
        })
    end
    gtable.crush(ret, _test_popup, true)
    return ret
end

function _test_popup.mt:__call(...)
    return _test_popup.new(...)
end

return setmetatable(_test_popup, _test_popup.mt)