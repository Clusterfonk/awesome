-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
---------------------------------------------------------------
--  Sections:
--      -> Launch
--      -> Standard
--      -> Layout Navigation
--      -> Layout Manipulation
--      -> Workspace Navigation
---------------------------------------------------------------
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

local cmd = require("configuration.defaults.commands")
local keys = require("configuration.keys.defaults")
local panels = require("ui.panels")

local capi = {
    awesome = awesome
}


local ALT = keys.alt
local CTRL = keys.ctrl
local MODKEY = keys.alt
local SHIFT = keys.shift
local SUPER = keys.super

awful.keyboard.append_global_keybindings({
---------------------------------------------------------------
-- => Launch
---------------------------------------------------------------
    --- Launcher
	awful.key({ MODKEY, SHIFT }, "o", function() awful.spawn(cmd.launcher()) end,
	          { description = "open launcher", group = "cmd" }),

    --- Terminal
	awful.key({ MODKEY, SHIFT }, "Return", function() awful.spawn(cmd.terminal) end,
	          { description = "open terminal", group = "cmd" }),

    --- Editor
	awful.key({ MODKEY, SHIFT }, "t", function() awful.spawn(cmd.text_editor) end,
	          { description = "open text editor", group = "cmd" }),

    --- Web browser
	awful.key({ MODKEY, SHIFT }, "b", function() awful.spawn(cmd.web_browser) end,
	          { description = "open web browser", group = "cmd" }),

    -- Notes
    awful.key({ MODKEY, SHIFT }, "w", function() awful.spawn(cmd.notes) end,
        {description = "open vimwiki", group = "cmd"}),

    -- Password Manager
    awful.key({ MODKEY, SHIFT }, "p", function() cmd.pw_manager() end,
        {description = "open password manager", group = "cmd"}),

    -- Messenger
    awful.key({ MODKEY, SHIFT }, "m", function() cmd.messenger() end,
        {description = "open messenger", group = "cmd"}),

    -- Snipregion
    awful.key({ MODKEY }, "s", function()
        awful.spawn(cmd.snipregion) end,
              {description = "Select a region to clipboard", group = "cmd"}),

    -- Toggle-Headphone-Speakers
    awful.key({ MODKEY }, "F1", function()
        awful.spawn(cmd.toggle_headphone_speakers) end,
              {description = "Toggle between Headphone and Speakers", group = "cmd"}),

    -- Zathura
    awful.key({ MODKEY }, "z", function()
        awful.spawn("zathura") end,
              {description = "open zathura", group = "cmd"}),

    -- logout panel
    awful.key({ MODKEY }, "Escape", function()
        panels.exitscreen:emit_signal("toggle") end,
              {description = "toggle logout panel", group = "cmd"}),

---------------------------------------------------------------
-- => Standard
---------------------------------------------------------------
    -- help
    awful.key({ MODKEY, CTRL, SHIFT }, "h",      hotkeys_popup.show_help,
              {description="show help", group="standard"}),
    --- restart
    awful.key({ MODKEY, CTRL        }, "r", capi.awesome.restart,
              {description = "reload awesome", group = "standard"}),

---------------------------------------------------------------
-- => Audio
---------------------------------------------------------------
    -- next
    awful.key({ }, "XF86AudioNext", function() awful.spawn.with_shell("playerctl next") end,
              {description = "Play next track", group = "Audio"}),
    -- prev
    awful.key({ }, "XF86AudioPrev", function() awful.spawn.with_shell("playerctl previous") end,
              {description = "Play previous track", group = "Audio"}),
    -- play / pause
    awful.key({ }, "XF86AudioPlay", function() awful.spawn.with_shell("playerctl play-pause") end,
              {description = "Play / Pause MPRIS-enabled media players", group = "Audio"}),
    -- stop
    awful.key({ }, "XF86AudioStop", function() awful.spawn.with_shell("playerctl stop") end,
              {description = "Stop MPRIS-enabled media players", group = "Audio"}),

---------------------------------------------------------------
-- Layout Navigation
---------------------------------------------------------------
    awful.key({ MODKEY,           }, "Tab", function ()
        awful.tag.history.restore()
    end,
              {description = "go back", group = "tag"}),

    awful.key({ MODKEY,           }, "n", function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}),

    awful.key({ MODKEY,           }, "e", function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),

    awful.key({ MODKEY,  SHIFT    }, "n", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),

    awful.key({ MODKEY,  SHIFT    }, "e", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),

    awful.key({ MODKEY,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    awful.key({ MODKEY,           }, ".", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ MODKEY,           }, ",", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

---------------------------------------------------------------
-- Layout manipulation
---------------------------------------------------------------
    awful.key({ MODKEY,           }, "i", function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),

    awful.key({ MODKEY,           }, "m", function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),

    awful.key({ MODKEY, CTRL }, "m", function () awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ MODKEY, CTRL }, "i", function () awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),

    awful.key({ MODKEY, }, "space", function () awful.layout.inc( 1) end,
              {description = "select next", group = "layout"}),

    awful.key({ MODKEY, CTRL }, "k",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal("request::activate", "key.unminimize", {raise = true})
                  end
              end,
              {description = "restore all minimized", group = "client"}),

---------------------------------------------------------------
-- workspaces
---------------------------------------------------------------
    awful.key {
        modifiers   = { MODKEY },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tags",
        on_press    = function (num)
            local screen = awful.screen.focused()
            for _, t in pairs(screen.tags) do
                if t.name == tostring(num) then
                    return t:view_only()
                end
            end
        end,
    },

    -- move client to tag
    awful.key({
		modifiers = { MODKEY, SHIFT },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tags",
		on_press = function(num)
			if client.focus then
                for _, t in pairs(client.focus.screen.tags) do
                    if t.name == tostring(num) then
                        return client.focus:move_to_tag(t)
                    end
                end
			end
		end,
	}),
})
