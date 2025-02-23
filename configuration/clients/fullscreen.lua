-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")


local capi = {
    awesome = awesome,
    client = client,
    tag = tag,
    screen = screen
}

-- Table to track the number of fullscreen clients per tag per screen
local fullscreen_count = setmetatable({}, { __mode = "k" }) -- Weak keys

-- Function to update the fullscreen count for a client's tag and screen
local function update_fullscreen_count(c, fullscreen, specific_tag)
    local s = c.screen
    local tags = specific_tag and { specific_tag } or c:tags()

    -- Initialize the fullscreen_count table for the screen if necessary
    if not fullscreen_count[s] then
        fullscreen_count[s] = setmetatable({}, { __mode = "k" }) -- Weak keys for tags
    end

    for _, t in ipairs(tags) do
        -- Initialize the fullscreen_count table for the tag if necessary
        fullscreen_count[s][t] = fullscreen_count[s][t] or 0

        if fullscreen then
            fullscreen_count[s][t] = fullscreen_count[s][t] + 1
        else
            fullscreen_count[s][t] = fullscreen_count[s][t] - 1
        end

        -- Emit a signal on the screen only if the tag is currently selected on the focused screen
        local focused_screen = awful.screen.focused()
        if s == focused_screen and t == focused_screen.selected_tag then
            s:emit_signal("fullscreen_changed", fullscreen_count[s][t] > 0)
        end
    end
end

capi.client.connect_signal("request::manage", function(c, context)
    if capi.awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        return awful.placement.no_offscreen(c)
    end

    if c.fullscreen and context == "new" then
        update_fullscreen_count(c, c.fullscreen)
    end
end)

capi.client.connect_signal("property::screen", function(c)
    if c.fullscreen then
        update_fullscreen_count(c, c.fullscreen)
    end
end)

-- Connect to client signals
capi.client.connect_signal("property::fullscreen", function(c)
    update_fullscreen_count(c, c.fullscreen)
end)

capi.client.connect_signal("request::unmanage", function(c)
    if c.fullscreen then
        update_fullscreen_count(c, c.fullscreen)
    end
end)

capi.client.connect_signal("property::minimized", function(c)
    if not c.fullscreen then return end

    if c.minimized then
        update_fullscreen_count(c, false)
    else
        update_fullscreen_count(c, c.fullscreen)
    end
end)

-- Handle view changes (switching to a different tag)
capi.tag.connect_signal("request::select", function(t, context)
    if context == "view_change" then
        local s = t.screen
        local has_fullscreen = fullscreen_count[s] and fullscreen_count[s][t] and fullscreen_count[s][t] > 0
        s:emit_signal("fullscreen_changed", has_fullscreen)
    end
end)

-- Handle tag changes (client moving to another tag)
capi.client.connect_signal("tagged", function(c) -- 2nd
    if c.fullscreen then
        update_fullscreen_count(c, c.fullscreen)
    end
    c.previous_tag = c.first_tag
end)

capi.client.connect_signal("untagged", function(c)
    if c.previous_tag and c.fullscreen then
        update_fullscreen_count(c, false, c.previous_tag)
    end
end)

-- jump to tag when client gets urgent
capi.client.connect_signal("property::urgent", function(c)
    c:jump_to()
end)
