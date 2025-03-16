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


-- 1: neutral
-- 2: faded
local colors    = {
    black_1     = "#302302f",
    black_2     = "#928374",
    red_1       = "#cc241d",
    red_2       = "#fb4934",
    green_1     = "#98971a",
    green_2     = "#b8bb26",
    yellow_1    = "#d79921",
    yellow_2    = "#fabd2f",
    blue_1      = "#458588",
    blue_2      = "#83a598",
    purple_1    = "#b16286",
    purple_2    = "#d3869b",
    aqua_1      = "#689d6a",
    aqua_2      = "#8ec07c",
    white_1     = "#a89984",
    white_2     = "#ebdbb2",
    orange_1    = "#d65d0e",
    orange_2    = "#fe8019",
    gray        = "#928374",

    bg_0        = "#282828",
    bg_0_h      = "#1d2021",
    bg_0_s      = "#32302f",
    bg_1        = "#3c3836",
    bg_2        = "#504945",
    bg_3        = "#665c54",
    bg_4        = "#7c6f64",
    fg_0        = "#fbf1c7",
    fg_1        = "#ebdbb2",
    fg_2        = "#d5c4a1",
    fg_3        = "#bdae93",
    fg_4        = "#a89984",
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
theme.border_normal = colors.bg_2
theme.border_focus = colors.bg_4
theme.useless_gap = dpi(5)

-- general
theme.fg_normal = colors.fg_1
theme.fg_focus = colors.red_2
theme.fg_urgent = colors.bg_0_s
theme.bg_normal = colors.bg_0_s
theme.bg_focus = colors.bg_2
theme.bg_urgent = colors.red_2

-- bars
theme.bars = {}
theme.bars.border_width = dpi(2)
theme.bars.border_color = colors.bg_3
theme.bars.bg_normal    = theme.bg_normal
theme.bars.fg_normal    = theme.fg_normal

-- taglist
theme.taglist_font = theme:create_font({ emphasis = "Bold", size = 11})
theme.taglist_fg_normal = theme.bars.fg_normal
theme.taglist_fg_focus = theme.fg_focus
theme.taglist_fg_urgent = colors.bg_0_s
theme.taglist_fg_empty = colors.bg_2
theme.taglist_bg_normal = colors.bg_0_s
theme.taglist_bg_occupied = colors.bg_0_s
theme.taglist_bg_empty = colors.bg_0_s
theme.taglist_bg_volatile = colors.bg_0_s
theme.taglist_bg_focus = colors.bg_0_s
theme.taglist_bg_urgent = colors.red_2
theme.taglist_underline_height = dpi(2)

-- titlebar
theme.titlebar_enabled = false

-- help popup
theme.hotkeys_bg = theme.bg_normal
theme.hotkeys_fg = theme.fg_normal
theme.hotkeys_border_width = theme.border_width
theme.hotkeys_border_color = theme.border_focus
theme.hotkeys_modifiers_fg = colors.blue_2
theme.hotkeys_label_bg = theme.bg_focus
theme.hotkeys_label_fg = theme.bg_normal
theme.hotkeys_font = theme.font_bold
theme.hotkeys_description_font = theme.font
theme.hotkeys_group_margin = dpi(30)

-- snap
theme.snap_bg = colors.red_2
theme.snap_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, theme.border_radius or 0)
end

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
theme.icon.notification_dnd         = load_icon(icon_dir, "notification-dnd.svg")
theme.icon.notification_unread_dnd  = load_icon(icon_dir, "notification-unread-dnd.svg")
theme.icon.notification_unread      = load_icon(icon_dir, "notification-unread.svg")

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
theme.systray_max_rows              = 20

-- clock
theme.clock = {}
theme.clock.font = theme:create_font({ size = 10, emphasis = "SemiBold"})

-- calendar
theme.calendar                      = {}
theme.calendar.header_font          = theme:create_font({ emphasis = "Bold", size = 12 })
theme.calendar.grid_font            = theme:create_font({ size = 12})
theme.calendar.day_focus_bg         = theme.bg_urgent
theme.calendar.day_fg               = theme.fg_normal
theme.calendar.day_off_fg           = colors.bg_2

-- progressbar
theme.progressbar = {}
theme.progressbar_bg = theme.bg_normal
theme.progressbar_fg = colors.purple_1
theme.progressbar_border_color = colors.bg_2
theme.progressbar_border_width = 0
theme.progressbar_bar_border_color = colors.bg_1
theme.progressbar_bar_border_width = theme.border_width

-- audio
theme.progressbar.audio_bg          = colors.aqua_1
-- mic
theme.progressbar.mic_bg            = colors.purple_1

-- naughty
theme.notification_font             = theme.font
theme.notification_bg               = theme.bg_normal
theme.notification_fg               = theme.fg_normal
theme.notification_border_width     = theme.bars.border_width
theme.notification_border_color     = theme.bars.border_color
theme.notification_progress_color   = colors.bg_1
theme.notification_icon_size        = dpi(40)
theme.notification_width            = dpi(100)
theme.notification_height           = dpi(150)
theme.notification_margin           = dpi(20)
theme.notification_spacing          = theme.useless_gap
theme.notification_max_width        = dpi(444) - theme.useless_gap
theme.notification_max_height       = dpi(30) -- GET it from bars
theme.notification_shape            = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, theme.border_radius or 0)
end

-- notification_center
theme.notification_dnd              = false
theme.notification_title_font       = theme:create_font({ emphasis = "Bold", size = 14})
theme.notification_message_font     = theme.font
theme.notification_header_font      = theme:create_font({ emphasis = "Bold", size = 12})

-- naughty.config
naughty.config.spacing = 2 * theme.useless_gap

naughty.config.defaults = {
    margin = theme.notification_margin,
    border_width = theme.taglist_border_width,
}

naughty.config.presets.normal = {
    fg      = theme.notification_fg,
    timeout = 5
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
theme.exitscreen = {}
theme.exitscreen.border_color = theme.border_normal
theme.exitscreen.shutdown = colors.red_2
theme.exitscreen.reboot = colors.yellow_2
theme.exitscreen.logout = colors.green_2
theme.exitscreen.lock = colors.aqua_2
theme.exitscreen.suspend = colors.blue_2

return theme
