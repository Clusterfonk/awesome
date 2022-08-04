-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gears = require("gears")
local bt = require("beautiful")


local button = { mt = {} }

-- Create a icon button widget. When clicked, invoke a callback
-- @tparam[opt] surface args.icon
-- @tparam[opt] number args.size
-- @tparam[opt] table args.margins
-- @tparam[opt] string args.bg 
-- @tparam[opt] callback args.callback 
-- @treturn A wibox.widget configured as a icon button
function button.new(args)
    args = args or {}
    local res = wibox.widget{
        {
            {
                {   
                    id = "icon",
                    image = args.icon,
                    forced_width = args.size,
                    forced_height = args.size,
                    widget = wibox.widget.imagebox,
                },
                widget = wibox.container.place
            },
            margins = args.margins,
            widget = wibox.container.margin
        },
        bg = args.bg or bt.bg_normal,
        widget = wibox.container.background,
        shape = gears.shape.circle,
        border_width = 1,
        border_color = bt.taglist_border_color
    }

    res.bg_normal = res.bg
    res.bg_focus = args.bg_focus or bt.bg_urgent
    res.hover_text = args.hover_text

    res:connect_signal("mouse::enter", function(b)        
        local icon = b:get_children_by_id("icon")[1]
        b:set_bg(b.bg_focus)
    end)
    res:connect_signal("mouse::leave", function(b)
        local icon = b:get_children_by_id("icon")[1]
        b:set_bg(b.bg_normal)
    end)

    res:connect_signal("button::press", args.callback or function() end)
    return res
end


function button.mt:__call(...)
    return button.new(...)
end

return setmetatable(button, button.mt)