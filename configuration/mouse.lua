-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")

local keys = require("configuration.keys.defaults")


local capi = {
    awesome = awesome,
    screen = screen,
    mouse = mouse
}

local MODKEY <const> = keys.alt

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        --- left click
        awful.button({}, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        -- Move client
        awful.button({ MODKEY }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        -- Resize client
        awful.button({ MODKEY }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

local function center_mouse()
    local s = capi.screen.primary
    awful.screen.focus(s)
    awful.placement.centered(capi.mouse, s)
end

capi.awesome.connect_signal("startup", center_mouse)
