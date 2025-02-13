-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")


--
-- Configure Tag Properties
--
awful.screen.connect_for_each_screen(function(s)
    -- Make sure there are an even number of tags
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8"},
        s,
        awful.layout.layouts[1])

    awful.tag.attached_connect_signal(s, "property::selected",
        function(t)
            if t.selected then
                t:emit_signal("request::select")
            else
                t:emit_signal("request::deselect")
            end
        end)
end)
