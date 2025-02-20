-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
---------------------------------------------------------------
--  Sections:
--      -> Colors
--      -> General
--      -> Icons
--      -> Notification
--      -> Calendar
--      -> Naughty
---------------------------------------------------------------
local gears = require("gears")
local gfilesystem = require("gears.filesystem")
local naughty = require("naughty")
local dpi = require("beautiful.").xresources.apply_dpi


local colors    = {
    black_1  = "#302302f",
    black_2  = "#928374",
    red_1    = "#cc241d",
    red_2    = "#fb4934",
    green_1  = "#98971a",
    green_2  = "#b8bb26",
    yellow_1 = "#d79921",
    yellow_2 = "#fabd2f",
    blue_1   = "#458588",
    blue_2   = "#83a598",
    purple_1 = "#b16286",
    purple_2 = "#d3869b",
    aqua_1   = "#689d6a",
    aqua_2   = "#8ec07c",
    white_1  = "#a89984",
    white_2  = "#ebdbb2",
    orange_1 = "#d65d0e",
    orange_2 = "#fe8019",

    bw_0_h   = "#1d2021",
    bw_0     = "#32302f",
    bw_0_s   = "#32302f",
    bw_1     = "#3c3836",
    bw_2     = "#504945",
    bw_3     = "#665c54",
    bw_4     = "#7c6f64",
    bw_5     = "#928374",
    bw_6     = "#a89984",
    bw_7     = "#bdae93",
    bw_8     = "#d5c4a1",
    bw_9     = "#ebdbb2",
    bw_10    = "#fbf1c7",
}

local theme     = {}
local root_dir  = gfilesystem.get_configuration_dir()
local theme_dir = root_dir .. "theme/gruvbox/"
theme.wallpaper = theme_dir .. "/wallpaper.png"

-- Font
function theme:create_font(args)
    args = args or {}
    args.size = args.size or theme.font_size

    if args.emphasis then
        return theme.font_name .. " " .. args.emphasis .. " " .. dpi(args.size)
    end
    return theme.font_name .. " " .. dpi(args.size)
end

theme.font_name = "FiraCodeNerdFont"
theme.font_size = "11"
theme.font = theme:create_font()
theme.font_bold = theme:create_font({ emphasis = "Bold" })
theme.font_italic = theme:create_font({ emphasis = "Italic" })
theme.font_bold_italic = theme:create_font({ emphasis = "Bold Italic" })

-- border
theme.border_width = dpi(1)
theme.border_radius = 0
theme.border_normal = colors.bw_2
theme.border_focus = colors.red_2
theme.border_marked = colors.bw_5
theme.useless_gap = dpi(5) -- WARNING:

-- general
theme.fg_normal = colors.bw_9
theme.fg_focus = colors.red_2
theme.fg_urgent = colors.bw_0
theme.bg_normal = colors.bw_0
theme.bg_focus = colors.bw_2
theme.bg_urgent = colors.red_2

-- taglist
theme.taglist_font = theme:create_font({ emphasis = "Bold", size = 11})
theme.taglist_fg_normal = theme.fg_normal
theme.taglist_fg_focus = theme.fg_focus
theme.taglist_fg_urgent = colors.bw_0
theme.taglist_fg_empty = colors.bw_2
theme.taglist_bg_normal = colors.bw_0
theme.taglist_bg_occupied = colors.bw_0
theme.taglist_bg_empty = colors.bw_0
theme.taglist_bg_volatile = colors.bw_0
theme.taglist_bg_focus = colors.bw_0
theme.taglist_bg_urgent = colors.red_2
theme.taglist_border_color = colors.bw_2
theme.taglist_border_width = dpi(2)
theme.taglist_underline_height = dpi(2)

-- titlebar
theme.titlebar_enabled = false

-- help popup
theme.hotkeys_border_width = dpi(30)
theme.hotkeys_border_color = colors.bw_0
theme.hotkeys_group_margin = dpi(30)
theme.hotkeys_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 20)
end

-- prompt
theme.prompt_bg = colors.bw_2
theme.prompt_fg = theme.fg_normal

-- snap
theme.snap_bg = theme.border_focus
theme.snap_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, theme.border_radius or 0)
end

-- progressbar
theme.progress = {}
theme.progressbar_bg = theme.bg_normal
theme.progressbar_fg = colors.purple_1
theme.progressbar_border_color = colors.bw_2
theme.progressbar_border_width = 0
theme.progressbar_bar_border_color = colors.bw_1
theme.progressbar_bar_border_width = theme.border_width

-- Icons
local function load_icon(dir, filename)
    local lgi_cairo_surface = gears.surface.load_silently(dir .. filename)
    return gears.color.recolor_image(lgi_cairo_surface, theme.fg_normal)
end

-- layout icons
local layout_dir = theme_dir .. "layouts/"
theme.layout_tile = load_icon(layout_dir, "tile.png")
theme.layout_fairh = load_icon(layout_dir, "fairh.png")
theme.layout_floating = load_icon(layout_dir, "floating.png")


local icon_dir                      = theme_dir .. "icons/"
theme.icon                          = {}
theme.icon.notification             = load_icon(icon_dir, "notification.svg")
theme.icon.notification_muted       = load_icon(icon_dir, "notification-muted.svg")

theme.icon.menu_up                  = load_icon(icon_dir, "menu-up.svg")
theme.icon.menu_down                = load_icon(icon_dir, "menu-down.svg")

theme.icon.speaker                  = load_icon(icon_dir, "speaker.svg")
theme.icon.headphones               = load_icon(icon_dir, "headphones.svg")
theme.icon.vol_high                 = load_icon(icon_dir, "volume-high.svg")
theme.icon.vol_mid                  = load_icon(icon_dir, "volume-mid.svg")
theme.icon.vol_low                  = load_icon(icon_dir, "volume-low.svg")
theme.icon.vol_muted                = load_icon(icon_dir, "volume-muted.svg")
theme.icon.mic                      = load_icon(icon_dir, "microphone.svg")
theme.icon.mic_muted                = load_icon(icon_dir, "microphone-muted.svg")

theme.icon.ethernet                 = load_icon(icon_dir, "ethernet.svg")
theme.icon.wlan                     = load_icon(icon_dir, "wlan.svg")

theme.icon.sync_ok                  = load_icon(icon_dir, "sync-ok.svg")
theme.icon.sync_notif               = load_icon(icon_dir, "sync-notif.svg")

theme.icon.bug                      = load_icon(icon_dir, "bug.svg")
theme.icon.error                    = load_icon(icon_dir, "error.svg")
theme.icon.deprecation              = load_icon(icon_dir, "deprecation.svg")

-- systray
theme.systray                       = {}
theme.bg_systray                    = theme.tasklist_bg_normal
theme.systray_icon_spacing          = 2 * theme.useless_gap

-- clock
theme.clock = {}
theme.clock.font = theme:create_font({ size = 10, emphasis = "SemiBold"})

-- calendar
theme.calendar                      = {}
theme.calendar.header_font          = theme:create_font({ emphasis = "Bold", size = 12 })
theme.calendar.grid_font            = theme:create_font({ size = 12})
theme.calendar.day_focus_bg         = theme.bg_urgent
theme.calendar.day_fg               = theme.fg_normal
theme.calendar.day_off_fg           = colors.bw_2

-- naughty
theme.notification_font             = theme.font
theme.notification_bg               = theme.bg_normal
theme.notification_fg               = theme.fg_normal
theme.notification_border_width     = theme.border_width
theme.notification_border_color     = theme.border_normal
--theme.notification_opacity
theme.notification_icon_size        = dpi(40)
theme.notification_width            = dpi(380)
theme.notification_height           = dpi(150)
theme.notification_margin           = dpi(20)
theme.notification_shape            = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, theme.border_radius or 0)
end

-- notification_center
theme.notification_title_font       = theme:create_font({ emphasis = "Bold", size = 14})
theme.notification_message_font     = theme.font
theme.notification_header_font      = theme:create_font({ emphasis = "Bold", size = 12})

-- TODO: need manual placing top = 1* side = 2* useless_gap
naughty.config.padding              = 2 * theme.useless_gap
naughty.config.spacing              = 2 * theme.useless_gap
naughty.config.defaults.timeout     = 5
naughty.config.defaults.margin      = theme.notification_margin
naughty.config.defaults.border_width= theme.notification_border_width


naughty.config.presets.low          = naughty.config.presets.normal
naughty.config.presets.ok           = naughty.config.presets.normal
naughty.config.presets.info         = naughty.config.presets.normal
naughty.config.presets.warn         = naughty.config.presets.normal

naughty.config.defaults = {
    --timeout = 5,
    --text = "",
    --screen = awful.screen.focused()
    --ontop = true,
    margin = theme.notification_margin,
    border_width = theme.notification_border_width,
    --position = "top_right"
}

naughty.config.presets.normal = {
    fg      = theme.notification_fg,
}


naughty.config.presets.ok = {
    fg      = colors.green_2,
    timeout = 5
}

naughty.config.presets.info = {
    fg      = colors.purple_2,
    timeout = 5
}

naughty.config.presets.low = {
    fg      = colors.aqua_2,
    timeout = 5
}

naughty.config.presets.warn = {
    fg      = colors.yellow_2,
    timeout = 0
}

naughty.config.presets.critical = {
    fg      = colors.red_2,
    timeout = 0,
}


-- exitscreen
theme.exitscreen_shutdown = colors.red_2
theme.exitscreen_reboot = colors.yellow_2
theme.exitscreen_logout = colors.green_2
theme.exitscreen_lock = colors.aqua_2
theme.exitscreen_suspend = colors.blue_2

return theme
