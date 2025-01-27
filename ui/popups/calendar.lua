-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local button= require("ui.widgets.button")
local base = require("ui.popups.base")

calendar = { mt = {} }

local month_lut = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}

local function years_widget(name)
    return wibox.widget {
        {
            widget = wibox.widget.textbox,
            text = name,
            font = bt.calendar.months_font,
            halign = "center",
            valign = "center"
        },
        forced_height = dpi(15),
        forced_width = dpi(15),
        shape = gshape.circle,
        widget = wibox.container.background
    }
end

local function years_grid(year)
    local years = {}
    local start_year = year - 14
    local end_year = year + 5
    for y = start_year, end_year do
        table.insert(years, years_widget(y))
    end

    return wibox.widget {
        layout = wibox.layout.grid,
        id = "months",
        forced_num_rows = 3,
        forced_num_cols = 4,
        homogenous = true,
        expand = true,
        spacing = dpi(5),
        table.unpack(years)
    }
end

local function month_widget(name)
    return wibox.widget {
        {
            widget = wibox.widget.textbox,
            text = name,
            font = bt.calendar.months_font,
            halign = "center",
            valign = "center"
        },
        forced_height = dpi(15),
        forced_width = dpi(15),
        shape = gshape.circle,
        widget = wibox.container.background
    }
end

local function months_grid()
    local months = {}
    for i, m in pairs(month_lut) do
        months[i] = month_widget(m)
    end

    return wibox.widget {
        layout = wibox.layout.grid,
        id = "months",
        forced_num_rows = 3,
        forced_num_cols = 4,
        homogenous = true,
        expand = true,
        spacing = dpi(5),
        table.unpack(months)
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

local function create_years(month_h, year)
    local yg = years_grid(year)

    return wibox.widget {
        {
            {
                widget = wibox.container.margin(month_h, 10, 10, 5, 5)
            },
            valign = "center",
            halign = "center",
            widget = wibox.container.place
        },
        {
            widget = wibox.container.margin(yg, 10, 10, 5, 5)
        },
        layout = wibox.layout.align.vertical
    }
end

local function create_months(year_h)
    local mg = months_grid()

    return wibox.widget {
        {
            {
                widget = wibox.container.margin(year_h, 10, 10, 5, 5)
            },
            valign = "center",
            halign = "center",
            widget = wibox.container.place
        },
        {
            widget = wibox.container.margin(mg, 10, 10, 5, 5)
        },
        layout = wibox.layout.align.vertical
    }
end

local function create_calendar(self, header_w)
    local dg = days_grid()

    local w = wibox.widget {
        {
            widget=wibox.container.margin(header_w, 10, 10, 5, 5)
        },
        {
            widget=wibox.container.margin(dg, 10, 10, 5, 5)
        },
        layout = wibox.layout.align.vertical
    }

    for day = 1, 42 do
        dg:get_children_by_id("days")[1]:add(day_widget(self, day))
    end

    return w
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


    local month_button = button {
        widget = wibox.widget {
            id = "header_month",
            widget = wibox.widget.textbox,
            font = bt.calendar.header_font,
        }
    }

    ret:connect_signal("header_month::updated", function(self, m)
        month_button:get_widget():set_text(month_lut[m])
    end)


    local year_button = button {
        widget = wibox.widget {
            id = "header_year",
            widget = wibox.widget.textbox,
            font = bt.calendar.header_font,
        }
    }

    ret:connect_signal("header_year::updated", function(self, y)
        year_button:get_widget():set_text(y)
    end)


    local header_w = wibox.widget {
        {
            month_button,
            year_button,
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    }

    local cal_w = create_calendar(ret, header_w)
    local months_w = create_months(year_button)
    local years_w = create_years(month_button, os.date("*t").year)

    ret:set_widget(wibox.widget {
        cal_w,
        months_w,
        years_w,
        top_only = true,
        layout = wibox.layout.stack
    })

    month_button:connect_signal("button::lmb_press", function()
        ret:get_widget():raise_widget(months_w)
    end)

    year_button:connect_signal("button::lmb_press", function()
        ret:get_widget():raise_widget(years_w)
    end)

    ret:connect_signal("popup::hide", function()
        ret:get_widget():raise_widget(cal_w)
    end)

    ret:set_date(os.date("*t"))

    return ret
end

function calendar.mt:__call(...)
    return new(...)
end

return setmetatable(calendar, calendar.mt)
