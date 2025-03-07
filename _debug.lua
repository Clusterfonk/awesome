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
    local lorem = "Lorem ipsum odor amet, consectetuer adipiscing elit. Gravida senectus est commodo dignissim sodales platea porta lobortis. Nam vehicula tellus porta aliquam cursus; rutrum facilisis auctor. Sodales duis tristique nisl sapien lacus finibus conubia condimentum. Imperdiet donec vestibulum porta etiam suscipit erat. Dapibus faucibus viverra volutpat; mauris torquent neque nam? Aporta adipiscing augue dapibus adipiscing condimentum; a sapien mollis. Fringilla habitant montes morbi molestie adipiscing aliquam consequat. Cras ipsum torquent viverra curae convallis. Ligula ullamcorper sed class integer proin mattis ut habitant. Aliquet aliquam parturient est aptent hendrerit metus ac. Inceptos nisl purus luctus mauris feugiat fermentum. Eu dapibus neque est cubilia consectetur ante iaculis ultrices. Tempor sit habitant fusce himenaeos lectus justo; cursus nisi habitasse? Auctor dui sit aenean dignissim curabitur faucibus efficitur placerat. Odio porta nunc vitae pharetra molestie. Urna himenaeos duis nisi duis adipiscing aliquam pulvinar. Viverra elit diam nam himenaeos efficitur amet sociosqu. Rutrum quam ridiculus dui lorem rutrum accumsan ac. Placerat cubilia imperdiet diam aliquet vitae libero tempus. Augue cras taciti lacus diam aptent elementum et ut velit. Posuere accumsan elementum magna nulla, efficitur semper vivamus. Nascetur habitant class orci mattis dis sagittis inceptos. Nullam egestas egestas adipiscing aliquet, volutpat dui. Habitasse elementum metus sociosqu augue fringilla nisi nunc eros interdum. Facilisi nostra mus dignissim arcu montes posuere integer. Massa vulputate non litora volutpat interdum praesent. In at penatibus nec pellentesque quis sapien metus. Malesuada feugiat placerat sociosqu est rutrum erat sollicitudin ornare. Per volutpat nunc vestibulum taciti class etiam condimentum. Luctus mi pellentesque fermentum luctus varius hac lacus. Dictum tristique semper lectus; mauris congue praesent class nam. Ligula blandit in sollicitudin curae dictum phasellus nunc aenean. Hendrerit nisl quisque vulputate sapien ligula habitant; pharetra ad faucibus. Ex donec torquent molestie dui habitant torquent dictum ligula. Magnis dapibus non non velit primis; augue cras. Turpis elementum neque massa metus aptent."
    local i = 0
    gtimer {
        timeout = 1,
        autostart = true,
        callback = function()
            if i <= 10 then
                naughty.notification {
                    preset = naughty.config.presets.critical,
                    title = 'ERROR!',
                    app_name = 'System Notification',
                    message = lorem,
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
