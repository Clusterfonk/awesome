-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local template = require(... .. ".tag_template")
local partial_taglist = require(... .. ".partial_taglist")

-- s, bar_width, bar_height, bar_offset
return function(args)
    local s = args.screen
    -- create layoutbox
    s.layoutbox = awful.widget.layoutbox({
        screen = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end)
        }
    })

    local function left_half_filter()
        return function(t)
            return t.index <= (#s.tags / 2)
        end
    end

    local function right_half_filter()
        return function(t)
            return t.index > (#s.tags / 2)
        end
    end

    local tag_template = template(s, args.width, args.height)
    -- create partial taglists
    s.taglist = {
        left_half = partial_taglist(s, left_half_filter(), tag_template),
        right_half = partial_taglist(s, right_half_filter(), tag_template)
    }

    --create the bar
    s.taglist_bar = wibox({
        index = "taglist_bar",
        screen   = s,
        stretch  = false,
        width    = args.width,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        bg = bt.taglist_bg_normal,
        height = args.height,
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

    awful.placement.align(s.taglist_bar, {position = "top", margins = {top = args.strut_offset}})

    s.taglist_bar:struts({
        top = args.height + 2*dpi(bt.taglist_border_width) + args.strut_offset
    })
end
