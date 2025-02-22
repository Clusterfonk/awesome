-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local taglist_bar = require("ui.bars.taglist")
local time_bar = require("ui.bars.time")
local info_bar = require("ui.bars.info")
local notification_builder = require("ui.widgets.notification")


local capi = {
    screen = screen
}

local debug = require "util.debug"


local SECONDARY_SCREEN <const> = 2

-- The notification placement is dependent on the bars not changing in size(x)!
by_pos_bar = {}

capi.screen.connect_signal("added", function() print("ADDED")end)
capi.screen.connect_signal("removed", function() print("removed")end)

capi.screen.connect_signal("request::desktop_decoration", function(s)
    by_pos_bar[s] = setmetatable({}, {__mode = "k"}) -- screen is weak

    local taglist_bar_width = dpi(350)
    local bar_height = dpi(24)
    local bar_offset = bt.useless_gap

    local geometry = {top = bar_offset, side = bt.useless_gap * 2}
    geometry.bottom = geometry.top + bar_height + 2 * bt.taglist_border_width

    by_pos_bar[s] = setmetatable({"left", "right"},{__mode = "v"})

    by_pos_bar[s].left = time_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

    by_pos_bar[s].right = info_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

	local tag = taglist_bar {
        screen = s,
        height = bar_height,
        width = taglist_bar_width,
        strut_offset = bar_offset
    }

    local tb = by_pos_bar[s].left

    local tb_geo = tb:geometry()
    local tag_geo = tag:geometry()

    local wlx = tb_geo.x + tb_geo.width + bt.useless_gap + 2* bt.taglist_border_width
    local wl = tag_geo.x - wlx - bt.useless_gap - bt.taglist_border_width
    by_pos_bar[s].left.width = wl

    local test = {
        x = wlx,
        width = wl,
        height = bar_height,
        y = bt.useless_gap
    }

    local ib = by_pos_bar[s].right
    local ib_geo = ib:geometry()

    local wrx = tag_geo.x + tag_geo.width + 2 * bt.taglist_border_width + bt.useless_gap
    local wr = ib_geo.x  - wrx - 2 * bt.taglist_border_width - bt.useless_gap

    --local test = {
    --    x = wrx,
    --    width = wr,
    --    height = bar_height,
    --    y = bt.useless_gap
    --}

    local wibox = require("wibox")
    local gears = require("gears")

    local t = awful.popup {
        widget = {
            {
                {
                    {
                        text   = "foobar",
                        widget = wibox.widget.textbox
                    },
                    {
                        {
                            text   = "foobar",
                            widget = wibox.widget.textbox
                        },
                        bg     = "#ff00ff",
                        clip   = true,
                        shape  = gears.shape.rounded_bar,
                        widget = wibox.container.background
                    },
                    {
                        value         = 0.5,
                        widget        = wibox.widget.progressbar
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                margins = 10,
                widget  = wibox.container.margin,
            },
            widget = wibox.container.constraint,
            strategy = "exact",
            width = test.width,
            height = tb_geo.height
        },
        visible      = true,
        border_width = bt.taglist_border_width,
        border_color = bt.border_normal,
        --placement = function(wdg)
        --    awful.placement.next_to(wdg, {
        --        geometry = tb,
        --        margins = { left = bt.useless_gap },
        --        preferred_positions = {"right"},
        --        preferred_anchors = {"middle"}
        --    })
        --end
    }

    --s:connect_signal("removed", function()
    --    -- TODO: clean up all its widgets
    --end)

    t:geometry(test)
	if s.index == SECONDARY_SCREEN then
	end
end)

notification_builder {
    height = dpi(30)
}

awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
        --:emit_signal("clear::popups") TODO: popups will no longer be screen dependent
    end)
})

-- splits primary screen in 2 makes testing multiscreen testing easier
if DEBUG then
    local geo = capi.screen[1].geometry
    local new_width = math.ceil(geo.width/2)
    local new_width2 = geo.width - new_width
    capi.screen[1]:fake_resize(geo.x, geo.y, new_width, geo.height)
    capi.screen.fake_add(geo.x + new_width, geo.y, new_width2, geo.height)
end
