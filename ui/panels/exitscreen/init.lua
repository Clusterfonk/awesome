-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local setmetatable = setmetatable
local awful = require("awful")
local bt = require("beautiful")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local gtable = require("gears.table")
local dpi = bt.xresources.apply_dpi

local button = require(... .. ".button")
local utable = require("utilities.table")


local capi = {
    awesome = awesome
}

local root_dir = gfs.get_configuration_dir() .. (...):gsub("%.", "/") .. "/"
local icon_dir = root_dir .. "icons/"
local shutdown_icon = icon_dir .. "shutdown.svg"
local reboot_icon = icon_dir .. "reboot.svg"
local logout_icon = icon_dir .. "logout.svg"
local lock_icon = icon_dir .. "lock.svg"
local supsend_icon = icon_dir .. "suspend.svg"

panel = { mt = {} }

local function shutdown()
    awful.spawn.with_shell("systemctl shutdown")
end

local function reboot()
    awful.spawn.with_shell("systemctl reboot")
end

local function logout()
    capi.awesome.quit()
end

local function lock()
end

local function suspend()
    awful.spawn.with_shell("systemctl suspend")
end

local function create_button(args, text)
    local button = button(args)
    button:connect_signal("mouse::enter",
    args.enter or function(b)
        text.point = {x=100, y=0}
        text:set_text(b.hover_text)
    end)
    button:connect_signal("mouse::leave",
    args.leave or function(b)
        text:set_text(" ")
    end)
    return button
end

local function create_keygrabber(self)
    return awful.keygrabber {
        keybindings = {
            awful.key{
                modifiers = {},
                key = "Escape",
                on_press =
                function()
                    self:emit_signal("toggle")
                end
            },
            awful.key{
                modifiers = {"Mod1"},
                key = "Escape",
                on_press =
                function()
                    self:emit_signal("toggle")
                end
            },
            awful.key{
                modifiers = {},
                key = "s",
                on_press = shutdown
            },
            awful.key{
                modifiers = {},
                key = "r",
                on_press = reboot
            },
            awful.key{
                modifiers = {},
                key = "q",
                on_press = logout
            },
            awful.key{
                modifiers = {},
                key = "l",
                on_press = lock
            },
            awful.key{
                modifiers = {"Shift"},
                key = "s",
                on_press = suspend
            },
        }
    }
end

local function create_widget(self, s)
    local bottom_text = wibox.widget {
        text = " ",
        font = bt.font_bold,
        widget = wibox.widget.textbox,
    }

    local icon_buttons = {
        {
            create_button({
                icon = shutdown_icon,
                hover_text = "shutdown",
                size = dpi(self.icon_size, s),
                margins = dpi(self.icon_margin, s),
                bg_focus = bt.exitscreen_shutdown,
                callback = shutdown
            }, bottom_text),
            create_button({
                icon = reboot_icon,
                hover_text = "reboot",
                size = dpi(self.icon_size, s),
                margins = dpi(self.icon_margin, s),
                bg_focus = bt.exitscreen_reboot,
                callback = reboot
            }, bottom_text),
            create_button({
                icon = logout_icon,
                hover_text = "logout",
                size = dpi(self.icon_size, s),
                margins = dpi(self.icon_margin, s),
                bg_focus = bt.exitscreen_logout,
                callback = logout
            }, bottom_text),
            create_button({
                icon = lock_icon,
                hover_text = "lock",
                size = dpi(self.icon_size, s),
                margins = dpi(self.icon_margin, s),
                bg_focus = bt.exitscreen_lock,
                callback = lock
            }, bottom_text),
            create_button({
                icon = supsend_icon,
                hover_text = "suspend",
                size = dpi(self.icon_size, s),
                margins = dpi(self.icon_margin, s),
                bg_focus = bt.exitscreen_suspend,
                callback = suspend
            }, bottom_text),
            id = 'buttons',
            spacing = dpi(self.icon_spacing, s),
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.container.place
    }
    return wibox.widget {
        {
            {
                icon_buttons,
                layout = wibox.layout.align.horizontal,
            },
            {
                    bottom_text,
                    layout = wibox.container.place
            },
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(5, s),
        },
        widget = wibox.container.margin,
        margins = self.widget_margins
    }
end

local function toggle(self)
    if self.visible then
        self.keygrabber:stop()
        self:set_widget(nil)
    else
        local s = awful.screen.focused()
        self:set_screen(s)
        self:set_widget(create_widget(self, s))
        self.keygrabber:start()
    end
    self.visible = not self.visible
end

function panel.new(args)
    args = args or {}

    panel.accent = args.accent or bt.bg_focus
    panel.fg = args.fg or bt.fg_normal
    panel.icon_size = args.icon_size or 15
    panel.icon_margin = args.icon_margin or {}
    panel.icon_spacing = args.icon_spacing or 5
    panel.widget_margins = args.widget_margins or {}

    local ret = awful.popup({
        placement = awful.placement.centered,
        bg = args.bg or bt.bg_normal,
        fg = args.fg or bt.fg_normal,
        border_color = bt.bg_urgent,
        border_width = dpi(2),
        ontop = true,
        visible = false,
        widget = {}
    })

    ret.classname = "exitscreen"
    ret.name = "exitscreen"
    ret:set_widget(nil)
    gtable.crush(ret, panel, true)

    ret.keygrabber = create_keygrabber(ret)
    ret:connect_signal("toggle", toggle, ret)
    return ret
end

function panel.mt:__call(...)
    return panel.new(...)
end

return setmetatable(panel, panel.mt)
