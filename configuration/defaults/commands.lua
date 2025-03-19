-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi
local naughty = require("naughty")

local capi = {
    mouse = mouse
}


local function launcher()
    local screen = capi.mouse.screen
    local index = screen.index - 1 -- dmenu uses 0 index start

    width = math.floor(screen.geometry.width / 3)
    x = math.floor(screen.geometry.width / 2 - width / 2)
    y = dpi(24) + 1 + bt.useless_gap * 2 + 2 * bt.bars.border_width + bt.useless_gap
    l = 1

    return string.format("dmenu_run -x %d -y %d -z %d -l %d -m %d", x, y, width, l, index)
end

function toggle_keepassxc()
    -- Command to check if KeePassXC is running
    local check_cmd = "pgrep -x keepassxc"

    -- Command to start KeePassXC
    local start_cmd = "keepassxc"

    -- Function to handle the toggle logic
    local function handle_toggle(is_running)
        if is_running then
            -- KeePassXC is running, find its client and toggle visibility
            local clients = client.get()
            local keepassxc_client = nil

            -- Find the KeePassXC client
            for _, c in ipairs(clients) do
                if c.class == "KeePassXC" then
                    keepassxc_client = c
                    break
                end
            end

            if keepassxc_client then
                -- If the client is found, toggle its visibility
                if keepassxc_client.minimized then
                    -- Restore the window if minimized
                    keepassxc_client.minimized = false
                    keepassxc_client:raise()
                    keepassxc_client:emit_signal("request::activate", "key.unminimize", { raise = true })
                else
                    -- Minimize the window if visible
                    keepassxc_client.minimized = true
                end
            else
                -- If no client is found, start KeePassXC
                awful.spawn(start_cmd, false, function(exit_code)
                    if exit_code ~= 0 then
                        naughty.notification {
                            preset = naughty.config.presets.critical,
                            title = "Error",
                            app_name = 'KeepassXC',
                            message = "Failed to start KeepassXC.",
                        }
                    end
                end)
            end
        else
            -- KeePassXC is not running, start it
            awful.spawn(start_cmd, false, function(exit_code)
                if exit_code ~= 0 then
                    naughty.notification {
                        preset = naughty.config.presets.critical,
                        title = "Error",
                        app_name = 'KeepassXC',
                        message = "Failed to start KeepassXC.",
                    }
                end
            end)
        end
    end

    -- Check if KeePassXC is running
    awful.spawn.easy_async(check_cmd, function(stdout, stderr, exitreason, exitcode)
        if exitcode == 0 then
            -- KeePassXC is running
            handle_toggle(true)
        else
            -- KeePassXC is not running
            handle_toggle(false)
        end
    end)
end

-- Function to toggle Signal Desktop
local function toggle_signal()
    -- Check if Signal Desktop is already open
    local signal_clients = client.get()
    local signal_client = nil

    for _, c in pairs(signal_clients) do
        if c.class == "Signal" then
            signal_client = c
            break
        end
    end

    -- If Signal is open, close it
    if signal_client then
        signal_client:kill()
    else
        -- If Signal is not open, start it
        awful.spawn("signal-desktop", false)
    end
end

return {
    launcher = launcher,
    notes = "notes",
    pw_manager = toggle_keepassxc,
    messenger = toggle_signal,
    snipregion = "snipregion",
    terminal = "alacritty",
    text_editor = "alacritty -e nvim",
    toggle_headphone_speakers = "toggle-headphone-speakers",
    web_browser = "brave-beta",
}
