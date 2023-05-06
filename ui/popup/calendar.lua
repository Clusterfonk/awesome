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


_calendar_popup = { mt= {} }

local function day_name_widget(name) -- TODO: different function name
    return wibox.widget({
            widget = wibox.widget.textbox, -- TODO: create text widget
            align = "center",
            font = bt.font_bold,
            markup = name,
        })
end

-- create single date (1, 2, 3, ...)
local function date_widget(s, date, is_current, is_another_month)
    local fg = bt.fg_normal
    if is_current then
        fg = bt.calendar_current_date_fg 
    elseif is_another_month then
        fg = bt.calendar_another_month_fg
    end

    return wibox.widget({
        {
            widget = textbox({text = date, size = 10, fg_normal=fg, fg_focus=fg}) -- TODO: bg color
        },
        widget = wibox.container.background,
        forced_width = dpi(30, s),
        forced_height = dpi(30, s),
        shape = gshape.circle,
        bg = is_current and bt.calendar_day_focus_bg,
    })
end

local function month_year_text(s) -- TODO: same spacing regardless of text
    local month_year = textbox({ 
        text = os.date("%B %Y"),
        font = bt.font_name,
        size = 16,
    })
    month_year.date = os.date("*t")
    
    local function set_date(month_year, summand)
        local time = os.time{
            year = month_year.date.year,
            month = month_year.date.month + summand, 
            day=1}
        month_year:set_text(os.date("%B %Y", time))
        month_year.date = os.date("*t", time)
        month_year:emit_signal("date_changed")
    end

    local left = iconbox({
        icon = bt.icon.menu_left,
        size = 10,
        on_press = function() 
            set_date(month_year, -1)
        end
        })

        local right = iconbox({
        icon = bt.icon.menu_right,
        size = 10,
        on_press = function() 
            set_date(month_year, 1)
        end
    })

    return wibox.widget({
        { 
            {
                {   
                    widget = left,
                },
                widget = wibox.container.place,
                forced_height = 10,
                forced_width = 10

            },
            {
                {   
                    id = "month_year",
                    widget = month_year,
                },
                widget = wibox.container.place
            },
            {
                {   
                    widget = right
                },
                widget = wibox.container.place,
                forced_height = 10,
                forced_width = 10
            },
            layout = wibox.layout.align.horizontal,
        },
        widget = wibox.container.place
    })

end

local function days_grid(s, spacing)
    return wibox.widget({
        layout = wibox.layout.grid,
        forced_num_rows = 5,
        forced_num_cols = 7,
        spacing = spacing,
        expand = true
    })
end

local function weekdays_grid(s, spacing, weekdays)
    grid =  wibox.widget({
        layout = wibox.layout.grid,
        forced_num_rows = 1,
        forced_num_cols = 7,
        spacing = spacing, 
        expand = true
    })
    for _, day in pairs(weekdays) do
        grid:add(day_name_widget(day))
    end
    return grid
end

function _calendar_popup:populate_days_grid(s, month, year, d_grid)
    d_grid:reset()


    local first_day = os.date("*t", os.time({ year = year, month = month, day = 1 }))
	local last_day = os.date("*t", os.time({ year = year, month = month + 1, day = 0 }))
    local month_days = last_day.day

    local start_on_sunday = self.start_on_sunday == true and 0 or self.start_on_sunday == false and 1
    local infront = first_day.wday - 1 - start_on_sunday
    local at_end = 35 - last_day.day - infront -- 7 days * 5 rows

    local previous_month_last_day = os.date("*t", os.time{year = year, month = month, day = 0}).day

	for day = previous_month_last_day - infront, previous_month_last_day - 1, 1 do
		d_grid:add(date_widget(s, day, false, true))
	end

    local current_date = os.date("*t")
	for day = 1, month_days do
		local is_current = day == current_date.day and month == current_date.month
		d_grid:add(date_widget(s, day, is_current, false))
	end

	for day = 1, at_end do
		d_grid:add(date_widget(s, day, false, true))
	end
end

function _calendar_popup:create_widget(s)
    grid_spacing = dpi(5, s)
    wd_grid = weekdays_grid(s, grid_spacing, self._private.weekdays)
    
    d_grid = days_grid(s, grid_spacing)
    month_year = month_year_text(s)
    
    local my = month_year:get_children_by_id("month_year")[1]
    my:connect_signal("date_changed", 
        function(my)
            self:populate_days_grid(s, my.date.month, my.date.year, d_grid)
        end
    )
    self:populate_days_grid(s, my.date.month, my.date.year, d_grid)
    ret = wibox.widget({ -- TODO: bg 
        {   
            month_year,
            {
                wd_grid,
                d_grid,
                layout = wibox.layout.fixed.vertical,
                spacing = grid_spacing,
            },
            layout = wibox.layout.fixed.vertical,
            spacing = 2*grid_spacing
        },
        widget = wibox.container.constraint,
        forced_width = self._private.width,
    })
    rawset(ret, "height_needed", 250)
    return ret
end

function _calendar_popup.new(args)
    args = args or {}
    local ret = base_popup(args)
    ret._private.width = args.width
    ret.placement = function(w)
        awful.placement.top_left(w, {
            margins = {top = args.bar_height + 2*dpi(bt.taglist_border_width, s) + args.bar_offset + bt.useless_gap + 2*w.border_width,
                       left = 2 * dpi(bt.useless_gap, s)}
        })
    end
    gtable.crush(ret, _calendar_popup, true)

    local weekdays = {"M", "T", "W", "T", "F", "S"}
    ret.start_on_sunday = args.start_on_sunday or false
    if ret.start_on_sunday then
        table.insert(weekdays, 1, "S")
    else
        table.insert(weekdays, "S")
    end
    ret._private.weekdays = weekdays

    return ret
end

function _calendar_popup.mt:__call(...)
    return _calendar_popup.new(...)
end

return setmetatable(_calendar_popup, _calendar_popup.mt)
