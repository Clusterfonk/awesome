-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")


--
-- Configure Tag Properties
--
awful.screen.connect_for_each_screen(function(s)
    -- Make sure there are an even number of tags
    awful.tag({ "1", "2", "3", "4", "7", "8", "9", "0"},
        s,
        awful.layout.layouts[1])

    awful.tag.attached_connect_signal(s, "property::selected",
        function(t)
            if t.screen.marked_for_removal then return end
            if t.selected then
                t:emit_signal("request::select", "view_change")
            else
                t:emit_signal("request::deselect")
            end
        end)

    -- messy but prevents unnessecary emits
    s:connect_signal("removed", function(screen) screen.marked_for_removal = true end)

end)

