-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")

local template = require(... .. ".tag_template")
local partial_taglist = require(... .. ".partial_taglist")


return function(args)
    local s = args.screen

    -- create layoutbox
    local layoutbox = awful.widget.layoutbox({
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

    -- create partial taglists
    local tag_template = template(s, args.width, args.height)
    local taglist = {
        left_half = partial_taglist(s, left_half_filter(), tag_template),
        right_half = partial_taglist(s, right_half_filter(), tag_template)
    }

    local taglist_bar = awful.popup {
        index = "taglist_bar",
        screen   = s,
        stretch  = false,
        width    = args.width,
        border_width = bt.bars.border_width,
        border_color = bt.bars.border_color,
        bg = bt.taglist_bg_normal,
        height = args.height,
        visible = true,
        widget   = {
            {
                {
                    layout = wibox.layout.align.horizontal,
                    taglist.left_half,
                },
                {
                    layout = wibox.layout.align.horizontal,
                    layoutbox,
                },
                {
                    layout = wibox.layout.align.horizontal,
                    taglist.right_half,
                },
                layout = wibox.layout.align.horizontal,
            },
            widget = wibox.container.constraint,
            strategy = "exact",
            width = args.width,
            height = args.height
        },
        placement = function(wdg)
            awful.placement.align(wdg , {position = "top", margins = {top = args.strut_offset}})
        end
    }
    taglist_bar:struts({top = taglist_bar:geometry().height + 2 * bt.useless_gap})

    s:connect_signal("removed", function(_)
        taglist_bar.visible = false
        taglist_bar = nil
    end)

    if DEBUG then
        local debug = require("util.debug")
        debug.attach_finalizer(taglist_bar, "taglist_bar")
    end
    return taglist_bar
end
