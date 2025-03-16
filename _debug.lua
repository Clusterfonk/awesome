--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
local _debug = { mt = {} }
_debug.is_enabled = os.getenv("AWMTT_DEBUG") ~= nil

-- Settings:
if _debug.is_enabled then
    _debug.gc_statistics = false
    _debug.gc_finalize = true
    _debug.multiscreen = false
    _debug.notifications = true
end

if _debug.is_enabled then
    local weak_objects = setmetatable({}, { __mode = "k" }) -- Ephemeron table

    function _debug.attach_finalizer(obj, msg)
        local gc_proxy = setmetatable({}, {
            __gc = function()
                print(msg .. " has been garbage-collected")
            end
        })
        -- Associate gc_proxy with GOject
        weak_objects[obj] = gc_proxy
    end

    function _debug.find_global_var(partial_name)
        for name, value in pairs(_G) do
            if name:find(partial_name) and not name:match("^[a-z]+$") then
                print("Found:", name, "=", value)
            end
        end
    end

    function _debug.output_local_vars(scope)
        local i = 1
        while true do
            -- level 1 refers to the current function's scope
            local name, value = debug.getlocal(scope or 1, i)
            if not name then break end
            print(name, value)
            i = i + 1
        end
    end
end


if _debug.notifications then
    local gtimer = require("gears.timer")
    local naughty = require("naughty")
    local bt = require("beautiful")

    function generateLoremIpsum()
        local loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in \n reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

        -- Generate a random length between 10 and 500
        local length = math.random(10, 500)

        -- Ensure the length does not exceed the length of the Lorem Ipsum text
        length = math.min(length, #loremIpsum)

        -- Extract a substring of the specified length
        local randomText = loremIpsum:sub(1, length)

        return randomText
    end

    local i = 0
    gtimer {
        timeout = 1,
        autostart = true,
        callback = function()
            if i <= 10 then
                naughty.notification {
                    preset = naughty.config.presets.critical,
                    title = 'TEST ' .. i .. "!",
                    app_name = 'System Notification',
                    message = generateLoremIpsum(),
                    icon = bt.icon.wlan,
                }
            end
            i = i + 1
        end
    }
end

-- this is more of a test
if _debug.multiscreen then
    local gtimer = require("gears.timer")
    gtimer {
        timeout = 5,
        autostart = true,
        single_shot = true,
        callback = function()
            local geo = capi.screen[1].geometry
            local new_width = math.ceil(geo.width / 2)
            local new_width2 = geo.width - new_width
            capi.screen[1]:fake_resize(geo.x, geo.y, new_width, geo.height)
            capi.screen.fake_add(geo.x + new_width, geo.y, new_width2, geo.height)
        end,
    }

    gtimer {
        timeout = 14,
        autostart = true,
        single_shot = true,
        callback = function()
            if capi.screen[2] then
                capi.screen[2]:fake_remove()
                local geo = capi.screen[1].geometry
                local new_width = geo.width * 2
                capi.screen[1]:fake_resize(geo.x, geo.y, new_width, geo.height)
            end
        end,
    }
end

_debug.mt.__index = function(_, _) return false end
return setmetatable(_debug, _debug.mt)
