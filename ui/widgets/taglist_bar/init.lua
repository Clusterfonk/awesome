-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local template = require(... .. ".tag_template")
local partial_taglist = require(... .. ".partial_taglist")


return function(s, bar_width, bar_height, bar_offset)
    -- create layoutbox
    s.layoutbox = awful.widget.layoutbox({
        screen = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end)
        }
    })

    local function left_half_filter(s)
        return function(t)
            return t.index <= (#s.tags / 2)
        end
    end
    
    local function right_half_filter(s)
        return function(t)
            return t.index > (#s.tags / 2)
        end
    end

    local tag_template = template(s, bar_width, bar_height)
    -- create partial taglists
    s.taglist = {
        left_half = partial_taglist(s, left_half_filter(s), tag_template),
        right_half = partial_taglist(s, right_half_filter(s), tag_template)
    }  
    
    --create the bar
    s.taglist_bar = wibox({
        index = "taglist_bar",
        screen   = s,
        stretch  = false,
        width    = bar_width,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        bg = bt.taglist_bg_normal,
        height = bar_height,
        visible = true,
        widget   = {
            {
                layout = wibox.layout.align.horizontal,
                s.taglist.left_half,
            },
            {
                layout = wibox.layout.align.horizontal,
                s.layoutbox,
            },
            {
                layout = wibox.layout.align.horizontal,
                s.taglist.right_half,
            },
            layout = wibox.layout.align.horizontal,
        }
    })

    awful.placement.align(s.taglist_bar, {position = "top", margins = {top = bar_offset}})

    s.taglist_bar:struts({
        top = bar_height + 2*dpi(bt.taglist_border_width) + bar_offset
    })
end