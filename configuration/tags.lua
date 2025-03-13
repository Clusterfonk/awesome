-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")

local capi = {
    screen = screen
}

local multi_monitor = capi.screen.count() > 1

awful.screen.connect_for_each_screen(function(s)
    if multi_monitor and s == capi.screen.primary then
        awful.tag.add("1", {
            screen = s,
            layout = awful.layout.layouts[1],
            layouts = {table.unpack(awful.layout.layouts, 1, 2)},
            gap_single_client = false,
            selected = true
        })
    else
        awful.tag({ "1", "2", "3", "4", "7", "8", "9", "0"},
            s,
            awful.layout.layouts[1])
        assert(#s.tags % 2 == 0, "the amount of tags should be even")
    end

    awful.tag.attached_connect_signal(s, "property::selected",
        function(t)
            if t.screen.marked_for_removal then return end
            if t.selected then
                t:emit_signal("request::select", "view_change")
            else
                t:emit_signal("request::deselect")
            end
        end)

    -- prevents unnecessary emits
    s:connect_signal("removed", function(screen) screen.marked_for_removal = true end)
end)

