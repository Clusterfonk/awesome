-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local month = require("ui.widgets.month")
local base = require("ui.popups.base")

calendar = { mt = {} }


local function header_widget(self, stack)
    local month_widget = month {
        text = "Feb",
        font = bt.calendar.header_font,
        stack = stack
    }

    local year = wibox.widget {
        text = "2025",
        widget = wibox.widget.textbox,
        font = bt.calendar.header_font
    }


    self:connect_signal("header_month::updated", function(self, m)
        local month_names = {
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        }
        month_widget:set(month_names[m])
    end)

    self:connect_signal("header_year::updated", function(self, y)
        year:set_text(y)
    end)

    return wibox.widget {
        {
            month_widget,
            year,
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    }
end

local function day_name_widget(name)
    return wibox.widget {
        {
            widget = wibox.widget.textbox,
            text = name,
            halign = "center",
            valign = "center"
        },
        forced_height = dpi(25),
        forced_width = dpi(25),
        shape = gshape.circle,
        widget = wibox.container.background
    }
end

local function days_grid()
    return wibox.widget {
        layout = wibox.layout.grid,
        id = "days",
        forced_num_rows = 6,
        forced_num_cols = 7,
        homogenous = true,
        spacing = dpi(5),
        day_name_widget "Su",
        day_name_widget "Mo",
        day_name_widget "Tu",
        day_name_widget "We",
        day_name_widget "Th",
        day_name_widget "Fr",
        day_name_widget "Sa"
    }
end

local function day_widget(self, day)
    local text = wibox.widget {
        widget = wibox.widget.textbox,
        text = day,
        font = bt.calendar.grid_font,
        halign  = "center",
        valign = "center",
    }
    local btext = wibox.container.background(text)

    local widget = wibox.widget {
        {
            widget = btext
        },
        shape = gshape.circle,
        forced_height = dpi(25),
        forced_width = dpi(25),
        widget = wibox.container.background
    }

    self:connect_signal(day .. "::updated", function(self, date, is_current, is_off_month)
        text:set_text(date)
        if is_current == true then
            widget.bg = bt.calendar.day_focus_bg
            btext:set_fg(bt.calendar.day_fg)
        elseif is_off_month == true then
            btext:set_fg(bt.calendar.day_off_fg)
        else
            btext:set_fg(bt.calendar.day_fg)
        end
    end)

    return widget
end

function calendar:create_widget()
    local dg = days_grid()
    local stack = wibox.widget {
        top_only = true,
        layout = wibox.layout.stack
    }
    -- prob. better to use stack:connect_sig
    stack:setup{
                wibox.container.margin(header_widget(self, stack), 10, 10, 5 , 5),
                wibox.container.margin(dg, 10, 10, 5, 5),
                layout = wibox.layout.align.vertical
    }
    self:set_widget(stack)

    for day = 1, 42 do
        dg:get_children_by_id("days")[1]:add(day_widget(self, day))
    end

    self:set_date(os.date("*t"))
end


function calendar:set_date(date)
    self:emit_signal("header_month::updated", date.month)
    self:emit_signal("header_year::updated", date.year)

    local first_day = os.date("*t", os.time{
        year = date.year,
        month = date.month,
        day = 1
    })

    local last_day = os.date("*t", os.time {
        year = date.year,
        month = date.month + 1,
        day = 0
    })
    local month_days = last_day.day

    local index = 1
    local days_to_add_at_month_start = first_day.wday - 1
    local days_to_add_at_month_end = 42 - last_day.day - days_to_add_at_month_start

    local previous_month_last_day = os.date("*t", os.time{
        year = date.year,
        month = date.month,
        day = 0}). day
    for day = previous_month_last_day - days_to_add_at_month_start, previous_month_last_day - 1 do
        self:emit_signal(index .. "::updated", day, false, true)
        index = index + 1
    end

    local current_date = os.date("*t")
    for day = 1, month_days do
        local is_current = day == current_date.day and date.month == current_date.month
        and date.year == current_date.year
        self:emit_signal(index .. "::updated", day, is_current, false)
        index = index + 1
    end

    for day = 1, days_to_add_at_month_end do
        self:emit_signal(index .. "::updated", day, false, true)
        index = index + 1
    end
end

local function new(args)
    local ret = base(args)

    gtable.crush(ret, calendar, true)

    ret:emit_signal("popup::show")
    return ret
end

function calendar.mt:__call(...)
    return new(...)
end

return setmetatable(calendar, calendar.mt)
