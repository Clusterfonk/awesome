-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local setmetatable = setmetatable
local button = require("awful.button")
local widget = require("awful.widget")
local gtable = require("gears.table")
local bt = require("beautiful")

local partial_taglist = { mt = {} }

-- Create a partial taglist widget. It contains a subset of the defined taglist
-- @tparam screen s The screen this widget will be attached to
-- @tparam function tag_filter The predicate function to filter the taglist
-- @tparam table tag_template The template to build the individual tags
-- @return The partial taglist
function partial_taglist.new(s, tag_filter, tag_template)
    local ret = widget.taglist {
        screen  = s,
        filter  = tag_filter,
        widget_template = tag_template,
        buttons = {
            button({ }, 1, function(t) t:view_only() end),
            button({ }, 3, function(t) t:view_only() end),
        },
    }

    gtable.crush(ret, partial_taglist, true)
    return ret
end

function partial_taglist.mt:__call(...)
    return partial_taglist.new(...)
end

return setmetatable(partial_taglist, partial_taglist.mt)