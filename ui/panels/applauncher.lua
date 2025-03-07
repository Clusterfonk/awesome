--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Get the global keys table
local globalkeys = root.keys()

-- Improved fuzzy search function with robust string handling
local function fuzzy_match(str, pattern)
    -- Ensure both inputs are strings
    str = tostring(str or "")
    pattern = tostring(pattern or "")

    -- Convert pattern to lowercase for case-insensitive matching
    pattern = string.lower(pattern)
    str = string.lower(str)

    if #pattern == 0 then return true, 0 end

    local j, last_j = 1, 0
    local score = 0
    local consecutive = 0

    for i = 1, #pattern do
        local c = pattern:sub(i, i)
        local next_pos = string.find(str, c, j, true) -- Use true for exact match

        if not next_pos then return false, 0 end

        j = next_pos

        -- Base score is position in string (earlier is better)
        local pos_score = (#str - j) / #str
        score = score + pos_score

        -- Bonus for consecutive matches
        if j - last_j == 1 then
            consecutive = consecutive + 1
            score = score + (consecutive * 0.5)
        else
            consecutive = 0
        end

        -- Bonus for matching at start of string or after separators
        if j == 1 or (j > 1 and str:sub(j-1, j-1):match("[^%w]")) then
            score = score + 2
        end

        last_j = j
        j = j + 1
    end

    return true, score
end

-- App Launcher
local app_launcher = {}

function app_launcher.new()
    local launcher = {}
    local applications = {}
    local filtered_apps = {}
    local is_loading = false
    local current_input = ""
    local best_match = nil
    local keygrabber = nil  -- Store keygrabber reference

    -- Create the launcher wibox
    launcher.wibox = wibox({
        ontop = true,
        visible = false,
        width = 600,
        height = 50,
        bg = beautiful.bg_normal or "#222222",
        border_width = 1,
        border_color = beautiful.border_focus or "#535d6c"
    })

    -- Textbox for input
    launcher.prompt = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font or "sans 12",
        forced_width = 400
    }

    -- Textbox for autocomplete suggestion
    launcher.suggestion = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font or "sans 12",
        align = "left",
        markup = "",
        fg = "#666666" -- Gray color for suggestion
    }

    -- Status indicator widget
    launcher.status = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font or "sans 12",
        align = "right",
        text = ""
    }

    launcher.wibox:setup {
        {
            {
                widget = wibox.widget.textbox,
                text = " ",
                forced_width = 10
            },
            {
                launcher.prompt,
                launcher.suggestion,
                layout = wibox.layout.stack
            },
            launcher.status,
            layout = wibox.layout.fixed.horizontal
        },
        widget = wibox.container.margin,
        margins = 10
    }

    -- Safe function to handle .desktop files
    local function safe_get_desktop_info(app_file, callback)
        if not app_file or type(app_file) ~= "string" then
            callback("", "")
            return
        end

        awful.spawn.easy_async("grep '^Name=' /usr/share/applications/" .. app_file, function(name_stdout)
            local name = app_file:gsub("%.desktop$", "")
            local display_name = name

            -- Parse the display name if found
            if name_stdout and #name_stdout > 0 then
                display_name = name_stdout:match("^Name=(.+)") or display_name
            end

            callback(name, display_name)
        end)
    end

    -- Function to load applications asynchronously
    function launcher:load_applications()
        if is_loading or #applications > 0 then return end

        is_loading = true
        launcher.status.text = "Loading..."

        -- Get a list of .desktop files asynchronously
        awful.spawn.easy_async("ls -1 /usr/share/applications/ | grep .desktop", function(stdout)
            local app_list = {}

            if stdout then
                for app in stdout:gmatch("[^\r\n]+") do
                    table.insert(app_list, app)
                end
            end

            -- Handle case with no apps found
            if #app_list == 0 then
                is_loading = false
                launcher.status.text = "No apps found"
                return
            end

            -- Process each .desktop file asynchronously
            local apps_to_process = #app_list
            local processed = 0

            for _, app_file in ipairs(app_list) do
                -- Extract display name from .desktop file asynchronously
                safe_get_desktop_info(app_file, function(name, display_name)
                    table.insert(applications, {
                        name = name,
                        display_name = display_name,
                        desktop_file = app_file
                    })

                    processed = processed + 1

                    -- When all apps are processed
                    if processed == apps_to_process then
                        is_loading = false
                        launcher.status.text = #applications .. " apps"

                        -- Sort applications by display name
                        table.sort(applications, function(a, b)
                            return tostring(a.display_name):lower() < tostring(b.display_name):lower()
                        end)

                        -- Update filtered apps based on current input
                        self:update_filtered_apps(current_input)
                    end
                end)
            end
        end)
    end

    -- Function to update filtered apps based on user input
    function launcher:update_filtered_apps(input)
        current_input = input or ""
        filtered_apps = {}
        best_match = nil
        local best_score = -1

        if input and #input > 0 then
            for _, app in ipairs(applications) do
                local match, score = fuzzy_match(app.display_name, input)
                if match then
                    table.insert(filtered_apps, {
                        app = app,
                        score = score
                    })

                    -- Track highest scoring match
                    if score > best_score then
                        best_score = score
                        best_match = app
                    end
                end

                -- Also try matching against app name
                if not match then
                    local name_match, name_score = fuzzy_match(app.name, input)
                    if name_match then
                        table.insert(filtered_apps, {
                            app = app,
                            score = name_score
                        })

                        -- Track highest scoring match
                        if name_score > best_score then
                            best_score = name_score
                            best_match = app
                        end
                    end
                end
            end

            -- Sort filtered apps by score (descending)
            table.sort(filtered_apps, function(a, b)
                return a.score > b.score
            end)

            -- Update display
            launcher.status.text = #filtered_apps .. "/" .. #applications

            -- Update suggestion text if we have a match
            if best_match then
                -- The gray text should show what would be completed
                local completion = tostring(best_match.display_name):sub(#input + 1)
                launcher.suggestion.markup = string.format(
                    "<span color='#666666'>%s<span color='#888888'>%s</span></span>",
                    input,
                    completion
                )
            else
                launcher.suggestion.markup = ""
            end
        else
            -- If no input, show all apps
            for _, app in ipairs(applications) do
                table.insert(filtered_apps, {
                    app = app,
                    score = 0
                })
            end
            launcher.status.text = #applications .. " apps"
            launcher.suggestion.markup = ""
        end
    end

    -- Handle tab completion
    function launcher:complete()
        if not best_match then return nil end
        if best_match then
            -- Set the text to the best match
            launcher.prompt:set_text(best_match.display_name)
            launcher.suggestion.markup = ""
            current_input = best_match.display_name

            -- Update filtered apps with new input
            self:update_filtered_apps(current_input)

            return current_input
        end
        return current_input
    end

    -- Launch the selected application
    function launcher:launch_app(index)
        index = index or 1
        if filtered_apps[index] then
            awful.spawn("gtk-launch " .. filtered_apps[index].app.desktop_file)
            self:hide()
        end
    end

    -- Show the launcher
    function launcher:show()
        -- Check if already visible, close if it is
        if self.wibox.visible then
            self:hide()
            return
        end

        -- Center the launcher on the screen
        local s = awful.screen.focused()
        self.wibox.x = s.geometry.width / 2 - self.wibox.width / 2
        self.wibox.y = s.geometry.height / 4

        -- Load applications if not already loaded
        if #applications == 0 and not is_loading then
            self:load_applications()
        end

        -- Reset state
        current_input = ""
        launcher.suggestion.markup = ""

        -- Reset and show
        awful.prompt.run {
            prompt = "",
            textbox = launcher.prompt,
            done_callback = function()
                self:hide()
            end,
            changed_callback = function(input)
                self:update_filtered_apps(input)
            end,
            exe_callback = function(input)
                if #filtered_apps > 0 then
                    self:launch_app(1)
                end
            end,
            completion_callback = function()
                return self:complete()
            end,
            keypressed_callback = function(mod, key, cmd)
                if key == "Tab" then
                    -- Handle tab completion
                    self:complete()
                    return true  -- Prevent default tab handling
                elseif key == "Escape" then
                    -- Close on Escape key
                    self:hide()
                    return true
                end
                return false
            end
        }

        -- Start a separate keygrabber for the modkey+space
        keygrabber = awful.keygrabber.run(function(mod, key, event)
            if event == "release" then return end

            -- Check for Mod4+space to toggle
            if key == "space" and gears.table.hasitem(mod, "Mod4") then
                self:hide()
                return true
            elseif key == "Escape" then
                -- Also handle Escape key here as a backup
                self:hide()
                return true
            end
        end)

        self.wibox.visible = true
    end

    -- Hide the launcher
    function launcher:hide()
        -- Stop keygrabber when hiding
        if keygrabber then
            awful.keygrabber.stop(keygrabber)
            keygrabber = nil
        end
        self.wibox.visible = false
    end

    -- Add keybinding directly to global keys
    function launcher:setup_keybindings(modkey)
        modkey = modkey or "Mod4" -- Windows key by default

        -- Create the keybinding and add it to globalkeys
        --globalkeys = gears.table.join(
        --    globalkeys,
        --    awful.key({ modkey }, "space", function() self:show() end,
        --           {description = "show app launcher", group = "launcher"})
        --)

        -- Set the updated global keys
        --root.keys(globalkeys)
    end

    return launcher
end

-- Create and initialize the launcher instance
local launcher = app_launcher.new()

-- Add keybinding automatically when module is loaded
launcher:setup_keybindings()

-- Export the launcher instance
return launcher
