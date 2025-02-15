-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi


local audio = require("ui.widgets.audio")
local microphone = require("ui.widgets.microphone")
local network = require("ui.widgets.network")
local sync = require("ui.widgets.sync")
local notification = require("ui.widgets.notification")
local systray = require("ui.widgets.systray")

-- TODO: add slider for vol or maybe let it handle a diff. widget
return function(args)
    local s = args.screen

    local geometry = {top = args.strut_offset, right = dpi(bt.useless_gap,s) * 2}
    geometry.bottom = geometry.top + args.height + 2 * dpi(bt.taglist_border_width, s)

    local audio_w = audio {
        height = args.height,
        margins = {left = bt.useless_gap}
    }
    local microphone_w = microphone {
        height = args.height
    }
    local network_w = network {
        height = args.height
    }
    local sync_w = sync {
        height = args.height
    }
    local notification_w = notification {
        height = args.height
    }
    local systray_w = systray {
        height = args.height,
        margins = {right = bt.useless_gap}
    }

    s.info_bar = awful.popup {
        screen = s,
        ontop = true,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        minimum_height = args.height,
        maximum_height = args.height,
        bg = bt.colors.background,
        widget = {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2 * bt.useless_gap,
            audio_w,
            microphone_w,
            network_w,
            sync_w,
            notification_w,
            systray_w
        },
        placement = function(c)
            awful.placement.top_right(c, {margins = { top = geometry.top, right = geometry.right}})
        end,
    }

    client.connect_signal("property::fullscreen", function(client)
        if s ~= client.screen then
            return
        end

        has_fullscreen_clients = false
        for _, c in pairs(s.clients) do
            has_fullscreen_clients = has_fullscreen_clients or c.fullscreen
        end
        s.info_bar.visible = not has_fullscreen_clients
    end)

    s.info_bar:connect_signal("clear::popups", function()
        --audio_w:emit_signal("popup::hide")
        --microphone_w:emit_signal("popup::hide")
        --network_w:emit_signal("popup::hide")
        --sync_w:emit_signal("popup::hide")
        --notification_w:emit_signal("popup::hide")
        --systray_w:emit_signal("popup::hide")
    end)

    client.connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            --audio_w:emit_signal("popup::hide")
            --microphone_w:emit_signal("popup::hide")
            --network_w:emit_signal("popup::hide")
            --sync_w:emit_signal("popup::hide")
            --notification_w:emit_signal("popup::hide")
            --systray_w:emit_signal("popup::hide")
        end
    end)
end
