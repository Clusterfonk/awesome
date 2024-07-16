-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi


calendar = { mt = {} }

-- NOTE:: should be without year (clicking on it will fan out all years)
local function date_title(name)
    return wibox.widget {

    }
end

local function days_in_month(month)
    return wibox.widget {

    }
end

local function years()
    return wibox.widget {

    }
end

-- NOTE: should contain the year from the year widget not the current
-- if year widget isnt available use current or use a parameter for it
function calendar:set_date(date)
    --
end

local function new(args)
    -- TODO: this should be very flexible (switchable widget)
    local popup = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(15)
        {
            layout = wibox.layout.fixed.horizontal,
            forced_height = dpi(40),
                {
                    text = "Satureday",
                    widget = wibox.widget.textbox
                }
        }
    }

    gtable.crush(popup, calendar, true)

    return popup
end

function calendar.mt:__call(...)
    return new(...)
end

setmetatable(calendar, calendar.mt)
