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

local SECONDARY_SCREEN <const> = 2

-- BUG: global usage!
-- The notification placement is dependent on the bars not changing in size(x)!
by_pos_bar = {}

capi.screen.connect_signal("request::desktop_decoration", function(s) -- created
    by_pos_bar[s] = setmetatable({}, { __mode = "k" })                -- screen is weak

    local taglist_bar_width = dpi(350)
    local bar_height = dpi(24)
    local bar_offset = bt.useless_gap

    local geometry = { top = bar_offset, side = 2 * bt.useless_gap }
    geometry.bottom = geometry.top + bar_height + 2 * bt.taglist_border_width

    by_pos_bar[s] = setmetatable({ "left", "middle", "right" }, { __mode = "v" }) -- this may be wrong bars should be weak

    time_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

    by_pos_bar[s].right = info_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

    by_pos_bar[s].middle = taglist_bar {
        screen = s,
        height = bar_height,
        width = taglist_bar_width,
        strut_offset = bar_offset
    }
end)

notification_builder(by_pos_bar)

awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
        --:emit_signal("clear::popups") TODO: popups will no longer be screen dependent
    end)
})

if DEBUG then
    local gtimer = require("gears.timer")

    gtimer {
        timeout = 2,
        autostart = true,
        single_shot = true,
        callback = function()
            local geo = capi.screen[1].geometry
            local new_width = math.ceil(geo.width / 2)
            local new_width2 = geo.width - new_width
            capi.screen[1]:fake_resize(geo.x, geo.y, new_width, geo.height)
            capi.screen.fake_add(geo.x + new_width, geo.y, new_width2, geo.height)
        end,
    }

    gtimer {
        timeout = 5,
        autostart = true,
        single_shot = true,
        callback = function()
            if capi.screen[2] then
                capi.screen[2]:fake_remove()
                local geo = capi.screen[1].geometry
                local new_width = geo.width * 2
                capi.screen[1]:fake_resize(geo.x, geo.y, new_width, geo.height)
            end
        end,
    }
end


--[[
    local tl_b = by_pos_bar[s].middle

    --notification_builder:emit_signal("screen::init", {
    --    screen = s,
    --    left = time_bar,
    --    middle = taglist_bar,
    --    right = info_bar
    --})

    local tb = by_pos_bar[s].left

    local tb_geo = tb:geometry()
    local tag_geo = by_pos_bar[s].middle:geometry()

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
--]]
