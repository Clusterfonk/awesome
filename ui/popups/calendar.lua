-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local button = require("ui.widgets.button")
local base = require("ui.popups.base")


calendar = { mt = {} }
setmetatable(calendar, { __index = popup })

local month_lut = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}
local month_short_lut = {
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
}

local weekdays = { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" }

function calendar.destroy(self)
    if self.midnight_timer then
        self.midnight_timer:stop()
        self.midnight_timer = nil
    end

    self._parent.destroy(self)
    calendar.instance = nil

    -- TODO: call function of the garbage collector -> will reset
    gtimer.delayed_call(function()
        collectgarbage("collect")
        collectgarbage("collect")
    end)
end

-- Function to calculate the number of seconds until midnight
local function seconds_until_midnight()
    local now = os.date("*t") -- Get the current time as a table

    local midnight = os.time {
        year = now.year,
        month = now.month,
        day = now.day + 1, -- Next day
        hour = 0,
        min = 0,
        sec = 0
    }

    return midnight - os.time({
        year = now.year,
        month = now.month,
        day = now.day,
        hour = now.hour,
        min = now.min,
        sec = now.sec
    })
end

-- Function to set up the midnight timer
local function setup_midnight_timer(calendar)
    local timeout = seconds_until_midnight()

    calendar.midnight_timer = gtimer {
        timeout = timeout,
        autostart = true,
        call_now = false,
        one_shot = true,
        callback = function()
            calendar:set_date(os.date("*t"))
            setup_midnight_timer(calendar) -- keeps a reference to calendar (upvalue)
        end
    }
end

-- Template for creating widgets
local function create_widget_template(text, height, width)
    return wibox.widget {
        {
            id = "textbox",
            widget = wibox.widget.textbox,
            text = text,
            font = bt.calendar.grid_font,
            halign = "center",
            valign = "center",
        },
        shape = gshape.circle,
        forced_height = dpi(height),
        forced_width = dpi(width),
        widget = wibox.container.background
    }
end

-- Day widget
local function day(self, d)
    local widget = create_widget_template(d, 25, 25)

    self:connect_signal(d .. "::day_updated", function(_, date, is_current, is_off_month)
        local tb = widget:get_children_by_id("textbox")[1]
        tb:set_text(date)
        if is_current then
            widget.bg = bt.calendar.day_focus_bg
            widget.fg = bt.calendar.day_fg
        elseif is_off_month then
            widget.bg = bt.bg_normal
            widget.fg = bt.calendar.day_off_fg
        else
            widget.bg = bt.bg_normal
            widget.fg = bt.calendar.day_fg
        end
    end)

    return widget
end

-- Month widget
local function month(self, m)
    local widget = create_widget_template(m, 15, 15)

    self:connect_signal(m .. "::month_updated", function(_, date, is_current)
        widget:get_children_by_id("textbox")[1]:set_text(date)
        if is_current then
            widget.bg = bt.calendar.day_focus_bg
            widget.fg = bt.calendar.day_fg
        else
            widget.fg = bt.calendar.day_fg
        end
    end)

    return widget
end

-- Year widget
local function year(self, y)
    local widget = create_widget_template(y, 15, 15)

    self:connect_signal(y .. "::year_updated", function(_, date, is_current)
        widget:get_children_by_id("textbox")[1]:set_text(date)
        if is_current then
            widget.bg = bt.calendar.day_focus_bg
            widget.fg = bt.calendar.day_fg
        else
            widget.fg = bt.calendar.day_fg
        end
    end)

    return widget
end

-- Generic grid creation
local function create_grid(widgets, rows, cols, spacing)
    return wibox.widget {
        id = "grid",
        layout = wibox.layout.grid,
        forced_num_rows = rows,
        forced_num_cols = cols,
        homogenous = true,
        expand = true,
        spacing = spacing,
        table.unpack(widgets)
    }
end

local function create_day_grid(self)
    days = {}
    for _, w in ipairs(weekdays) do
        table.insert(days, create_widget_template(w, 25, 25))
    end

    for d = 1, 42 do
        table.insert(days, day(self, d))
    end
    return create_grid(days, 7, 7, dpi(5))
end

local function create_month_grid(self)
    local widgets = {}
    for _, m in ipairs(month_short_lut) do
        table.insert(widgets, month(self, m))
    end
    return create_grid(widgets, 3, 4, dpi(20))
end

local function create_year_grid(self)
    local widgets = {}
    local current_year = os.date("*t").year
    for y = current_year - 14, current_year + 5 do
        table.insert(widgets, year(self, y))
    end
    return create_grid(widgets, 3, 4, dpi(5))
end

local function create_header(self)
    local header_month = button {
        widget = wibox.widget {
            id = "header_month",
            widget = wibox.widget.textbox,
            font = bt.calendar.header_font,
        }
    }
    local header_year = button {
        widget = wibox.widget {
            id = "header_year",
            widget = wibox.widget.textbox,
            font = bt.calendar.header_font,
        }
    }
    self:connect_signal("header_month::updated", function(_, m)
        header_month:get_widget():set_text(month_lut[m])
    end)
    self:connect_signal("header_year::updated", function(_, y)
        header_year:get_widget():set_text(y)
    end)

    header_month:connect_signal("button::press", function(_, _, _, btn) -- TODO: move to header const.
        if btn == 1 then
            local w = self.widget:get_children_by_id("month_view")[1]
            self.widget:raise_widget(w)
        end
    end)

    header_year:connect_signal("button::press", function(_, _, _, btn)
        if btn == 1 then
            local w = self.widget:get_children_by_id("year_view")[1]
            self.widget:raise_widget(w)
        end
    end)
    return { header_month, header_year }
end

local function is_leap_year(year)
    return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
end

local function get_days_in_month(year, month)
    if month == 2 then
        return is_leap_year(year) and 29 or 28
    elseif month == 4 or month == 6 or month == 9 or month == 11 then
        return 30
    else
        return 31
    end
end

-- Zeller's Congruence
-- 0 = Saturday, 1 = Sunday, ..., 6 = Friday
local function get_day_of_week(y, m, d)
    if m < 3 then
        m = m + 12
        y = y - 1
    end
    local k = y % 100
    local j = y // 100
    return (d + ((13 * (m + 1)) // 5) + k + (k // 4) + (j // 4) + (5 * j)) % 7
end

local function update_days(self, date)
    local current_date = os.date("*t")
    local total_days_in_month = get_days_in_month(date.year, date.month)
    local first_day_of_week = get_day_of_week(1, date.month, date.year)
    local days_from_previous_month = (first_day_of_week - 1) % 7
    local days_from_next_month = 42 - (total_days_in_month + days_from_previous_month)

    local cell_index = 1

    -- Days from the previous month
    local previous_month_days = get_days_in_month(date.year, date.month - 1)
    for previous_month_day = previous_month_days - days_from_previous_month + 1, previous_month_days do
        self:emit_signal(cell_index .. "::day_updated", previous_month_day, false, true)
        cell_index = cell_index + 1
    end

    -- Days in the current month
    for current_month_day = 1, total_days_in_month do
        local is_current_day = current_month_day == current_date.day and date.month == current_date.month and date.year == current_date.year
        self:emit_signal(cell_index .. "::day_updated", current_month_day, is_current_day, false)
        cell_index = cell_index + 1
    end

    -- Days from the next month
    for next_month_day = 1, days_from_next_month do
        self:emit_signal(cell_index .. "::day_updated", next_month_day, false, true)
        cell_index = cell_index + 1
    end
end

-- Update months and years
local function update_months_years(self, date)
    for m = 1, 12 do
        local is_crt_month = m == date.month
        local month_name = month_short_lut[m]
        self:emit_signal(month_name .. "::month_updated", month_name, is_crt_month)
    end

    for y = date.year - 14, date.year + 5 do
        local is_crt_year = y == date.year
        self:emit_signal(y .. "::year_updated", y, is_crt_year)
    end
end

-- Set the current date
function calendar:set_date(date)
    self:emit_signal("header_month::updated", date.month)
    self:emit_signal("header_year::updated", date.year) -- TODO: might be able to combine
    update_days(self, date)
    update_months_years(self, date)
end

function calendar.new(args)
    args = args or {}
    args.destroy_timeout = 20
    local ret = base(args)
    rawset(ret, "_parent", { destroy = ret.destroy })
    gtable.crush(ret, calendar, true)

    local header = create_header(ret)

    ret.widget = wibox.widget.base.make_widget_declarative {
        layout = wibox.layout.stack,
        top_only = true,
        {
            id = "main_view",
            widget = wibox.container.background
                {
                    layout = wibox.layout.align.vertical,
                    {
                        widget = wibox.container.margin,
                        margins = { left = 10, right = 10, top = 5, bottom = 5 },
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            halign = "center",
                            {
                                layout = wibox.layout.fixed.horizontal,
                                spacing = dpi(10),
                                table.unpack(header)
                            }
                        }
                    },
                    {
                        widget = wibox.container.margin,
                        margins = { left = 10, right = 10, top = 5, bottom = 5 },
                        {
                            widget = create_day_grid(ret)
                        },
                    }
                }
        },
        {
            -- month view
            id = "month_view",
            widget = wibox.container.background
                {
                    layout = wibox.layout.align.vertical,
                    {
                        widget = wibox.container.place,
                        valign = "center",
                        halign = "center",
                        {
                            widget = wibox.container.margin,
                            margins = { left = 10, right = 10, top = 5, bottom = 5 },
                            {
                                widget = header[2]     -- year_header
                            },
                        },
                    },
                    {
                        widget = wibox.container.margin,
                        margins = { left = 10, right = 10, top = 5, bottom = 5 },
                        {
                            widget = create_month_grid(ret)
                        }
                    }
                }
        },
        {
            -- year view
            id = "year_view",
            widget = wibox.container.background
                {
                    layout = wibox.layout.align.vertical,
                    {
                        widget = wibox.container.place,
                        valign = "center",
                        halign = "center",
                        {
                            widget = wibox.container.margin,
                            margins = { left = 10, right = 10, top = 5, bottom = 5 },
                            {
                                widget = header[1]     -- month_header
                            },
                        },
                    },
                    {
                        widget = wibox.container.margin,
                        margins = { left = 10, right = 10, top = 5, bottom = 5 },
                        {
                            widget = create_year_grid(ret)
                        }
                    }
                }
        }
    }

    local month_view = ret.widget:get_children_by_id("month_view")[1]
    local year_view = ret.widget:get_children_by_id("year_view")[1]

    ret:connect_signal("popup::hide", function()
        local w = ret.widget:get_children_by_id("main_view")[1]
        ret.widget:raise_widget(w)
    end)


    month_view:connect_signal("button::press", function(_, _, _, btn)
        if btn == 3 then
            local w = ret.widget:get_children_by_id("main_view")[1]
            ret.widget:raise_widget(w)
        end
    end)

    year_view:connect_signal("button::press", function(_, _, _, btn)
        if btn == 3 then
            local w = ret.widget:get_children_by_id("main_view")[1]
            ret.widget:raise_widget(w)
        end
    end)

    ret:connect_signal("button::press", function(self, _, _, btn)
        -- TODO: add scroll support
    end)

    ret:set_date(os.date("*t"))
    setup_midnight_timer(ret)

    if DEBUG then
        local debug = require("util.debug")
        debug.attach_finalizer(ret, "calendar")
    end
    return ret
end

function calendar.mt:__call(...)
    if calendar.instance then
        return calendar.instance
    end
    calendar.instance = calendar.new(...)
    return calendar.instance
end

return setmetatable(calendar, calendar.mt)
