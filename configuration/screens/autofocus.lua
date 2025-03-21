-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local permissions = require "awful.permissions"
require "awful.autofocus"


local capi = {
    awesome = awesome,
    screen = screen
}

permissions.add_activate_filter(function(c)
    if capi.awesome.startup then
        return c.screen == capi.screen.primary
    end
    return true
end, "screen.focus")

permissions.add_activate_filter(function()
    return false
end, "autofocus.check_focus_tag")
