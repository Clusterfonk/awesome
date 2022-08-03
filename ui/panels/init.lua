-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>

local logpop = require(... .. ".logpop")({
    widget_margins = {
        left = 15,
        right = 15,
        top = 25,
        bottom = 5,
    },
    icon_size = 40,
    icon_margin = 10,
    icon_spacing = 22
})

return {
    logpop = logpop,
}