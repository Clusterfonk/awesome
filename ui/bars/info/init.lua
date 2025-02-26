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

    local function popup_placement(d)
        print("lil bro gets placed")
        awful.placement.top_right(d, {
            margins = {top = geo.bottom + 2 * bt.useless_gap, right = geo.side},
            parent = s
        })
    end

    local audio_w = audio {
        screen = s,
        height = args.height,
        margins = {left = bt.useless_gap},
        color = bt.progressbar.audio_bg,
        placement = popup_placement
    }
    local microphone_w = microphone {
        screen = s,
        height = args.height,
        color = bt.progressbar.mic_bg,
        placement = popup_placement,
    }
    local network_w = network {
        height = args.height
    }
    local sync_w = sync {
        height = args.height
    }
    local notify_w = notify {
        screen = s,
        height = args.height,
        placement = popup_placement,
    }
    local systray_w = tray {
        screen = s,
        height = args.height,
        margins = {right = bt.useless_gap},
        placement = popup_placement
    }

    local info_bar = awful.popup {
        screen = s,
        ontop = true,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        minimum_height = args.height,
        maximum_height = args.height,
        bg = bt.bg_normal,
        widget = {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2 * bt.useless_gap,
            audio_w,
            microphone_w,
            network_w,
            sync_w,
            notify_w,
            systray_w
        },
        placement = function(c)
            awful.placement.top_right(c, {margins = { top = geo.top, right = geo.side}})
        end,
    }

    local bar_geo = info_bar:geometry()
    audio_w._private.popup:emit_signal("bar::width", bar_geo.width)
    microphone_w._private.popup:emit_signal("bar::width", bar_geo.width)
    systray_w._private.popup:emit_signal("bar::width", bar_geo.width)

    info_bar:connect_signal("clear::popups", function()
        --audio_w:emit_signal("popup::hide")
        --microphone_w:emit_signal("popup::hide")
        --network_w:emit_signal("popup::hide")
        --sync_w:emit_signal("popup::hide")
        --notification_w:emit_signal("popup::hide")
        --systray_w:emit_signal("popup::hide")
    end)

    --audio_w._private.popup:emit_signal("bar::geometry_init", info_bar:geometry())

    capi.client.connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            --audio_w:emit_signal("popup::hide")
            --microphone_w:emit_signal("popup::hide")
            --network_w:emit_signal("popup::hide")
            --sync_w:emit_signal("popup::hide")
            --notification_w:emit_signal("popup::hide")
            --systray_w:emit_signal("popup::hide")
        end
    end)

    local function hide_popups_on_lbutton(_, _, _, button)
        if button == 1 then
            --audio_w.popup:emit_signal("popup::hide")
        end
    end

    s:connect_signal("property::geometry", function(screen)
        awful.placement.top_right(info_bar, {
            margins = { top = geo.top, right = geo.side},
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
        -- TODO: have it all in a list then iterate
        info_bar.visible = false
        audio_w.visible = false
        microphone_w.visible = false
        network_w.visible = false
        sync_w.visible = false
        notify_w.visible = false
        systray_w.visible = false

        info_bar = nil
        audio_w = nil
        microphone_w = nil
        network_w = nil
        sync_w = nil
        notify_w = nil
        systray_w = nil
        -- TODO: might need to emit signals to let popups know ?
    end)

    if DEBUG then
        local debug =require("util.debug")
        debug.attach_finalizer(info_bar, "info_bar")
        debug.attach_finalizer(audio_w, "audio_w")
        debug.attach_finalizer(microphone_w, "microphone_w")
        debug.attach_finalizer(network_w, "audio_w")
        debug.attach_finalizer(sync_w, "sync_w")
        debug.attach_finalizer(notify_w, "notify_w")
        debug.attach_finalizer(systray_w, "systray_w")
    end
    return info_bar
end
