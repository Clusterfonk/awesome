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
local notify = require("ui.widgets.notify")
local tray = require("ui.widgets.tray")

local capi = {
    client = client,
    screen = screen
}

return function(args)
    local s = args.screen
    local geo = args.geometry

    local function bar_placement(c)
        awful.placement.top_right(c, {
            margins = { top = geo.top, right = geo.side },
        })
    end

    local info_bar = awful.popup {
        screen = s,
        ontop = true,
        border_width = bt.bars.border_width,
        border_color = bt.bars.border_color,
        minimum_height = args.height,
        maximum_height = args.height,
        bg = bt.bg_normal,
        widget = wibox.widget.base.empty_widget(),
        placement = bar_placement
    }

    local function attach_to_bar(popup)
        awful.placement.next_to(popup, {
            preferred_positions = "bottom",
            preferred_anchor = "front",
            offset = { x = 0, y = bt.useless_gap * 2 },
            attach = true,
            geometry = info_bar,
        })
    end

    local widgets = {
        audio {
            screen = s,
            height = args.height,
            margins = { left = bt.useless_gap },
            color = bt.progressbar.audio_bg,
            attach = attach_to_bar
        },
        microphone {
            screen = s,
            height = args.height,
            color = bt.progressbar.mic_bg,
            attach = attach_to_bar,
        },
        network {
            screen = s,
            height = args.height,
            attach = attach_to_bar,
        },
        sync {
            height = args.height,
            attach = attach_to_bar,
        },
        notify {
            screen = s,
            height = args.height,
            attach = attach_to_bar,
        },
        tray {
            screen = s,
            height = args.height,
            margins = { right = bt.useless_gap },
            attach = attach_to_bar
        }
    }

    info_bar:connect_signal("property::geometry", function(geometry)
        for _, w in ipairs(widgets) do
            w:emit_signal("bar::geometry", geometry)
        end
    end)

    info_bar:setup {
        layout = wibox.layout.fixed.horizontal,
        spacing = 2 * bt.useless_gap,
        table.unpack(widgets)
    }

    -- hiding
    info_bar:connect_signal("clear::popups", function()
        --for i = #widgets, 1, -1 do
        --    widgets[i]:emit_signal("popup::hide")
        --end
    end)

    local function hide_popups_on_lbutton(_, _, _, button)
        if button == 1 then
            --for i = #widgets, 1, -1 do
            --    widgets[i]:emit_signal("popup::hide")
            --end
        end
    end

    -- screens
    s:connect_signal("property::geometry", function(screen)
        awful.placement.top_right(info_bar, {
            margins = { top = geo.top, right = geo.side },
            parent = screen
        })
    end)

    s:connect_signal("fullscreen_changed", function(_, has_fullscreen)
        if info_bar then
            info_bar.visible = not has_fullscreen
        end
    end)

    capi.client.connect_signal("button::press", hide_popups_on_lbutton)
    s:connect_signal("removed", function(_)
        capi.client.disconnect_signal("button::press", hide_popups_on_lbutton)
        for i = #widgets, 1, -1 do
            local w = widgets[i]
            w.visible = false
            w:emit_signal("bar::removed")
            table.remove(widgets, i)
        end
        widgets = nil

        info_bar.visible = false
        info_bar = nil
    end)

    if DEBUG then
        local debug = require("util.debug")
        debug.attach_finalizer(info_bar, "info_bar")
        debug.attach_finalizer(widgets[1], "audio")
        debug.attach_finalizer(widgets[2], "microphone")
        debug.attach_finalizer(widgets[3], "network")
        debug.attach_finalizer(widgets[4], "sync")
        debug.attach_finalizer(widgets[5], "notify")
        debug.attach_finalizer(widgets[6], "tray")
    end
    return info_bar
end
