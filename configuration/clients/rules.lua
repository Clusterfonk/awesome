-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")


ruled.client.connect_signal("request::rules", function()
    --- Global
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			raise = true,
			size_hints_honor = false,
			screen = awful.screen.preferred,
			focus = awful.client.focus.filter,
			titlebars_enabled = beautiful.titlebar_enabled,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            previous_tag = nil
		},
        {
            id = "tasklist_order",
            rule = {},
            properties = {},
            callback = awful.client.setslave,
        },
	})

    -- Float
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = {
			},
			class = {
			},
			name = {
			},
			role = {
			},
			type = {
			},
		},
		properties = { floating = true },
	})
end)
