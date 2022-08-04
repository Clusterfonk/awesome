-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>

local logpop = require(... .. ".logpop")({
    widget_margins = {
        left = 25,
        right = 25,
        top = 25,
        bottom = 5,
    },
    icon_size = 40,
    icon_margin = 10,
    icon_spacing = 15
})

return {
    logpop = logpop,
}