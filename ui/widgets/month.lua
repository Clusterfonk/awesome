-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local bt = require("beautiful")

local button = require("ui.widgets.button")


month = { mt = {} }

local function on_lmb_press(self)
    print("month pressed")

    self._private.stack:insert(1, wibox.widget {
        wibox.widget.textbox
    })
end

function month:set(text)
    self:get_widget():set_text(text)
end

local function new(args)
    local text_widget = wibox.widget {
        text = "iraentiern",
        font = bt.calendar.header_font,
        widget = wibox.widget.textbox
    }

    local button_widget = button {
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        widget = text_widget
    }
    button_widget._private.stack = args.stack

    button_widget:connect_signal("button::lmb_press", on_lmb_press)

    gtable.crush(button_widget, month, true)
    return button_widget
end

function month.mt:__call(...)
    return new(...)
end

return setmetatable(month, month.mt)
