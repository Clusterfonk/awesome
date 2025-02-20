local lgi = require 'lgi'
local GLib = lgi.GLib
local Gio = lgi.Gio
local debug = require("utilities.debug")

-- Connect to the system bus
local bus = Gio.bus_get_sync(Gio.BusType.SYSTEM)

-- Define the D-Bus service and object path
local service = 'org.freedesktop.network1'
local object_path = '/org/freedesktop/network1'
local interface = 'org.freedesktop.network1.Manager'

-- Create a proxy for the Manager interface
local manager, err = Gio.DBusProxy.new_sync(bus, Gio.DBusProxyFlags.NONE, nil, service, object_path, interface, nil)
if err then
    print(err) -- TODO: naughty it
    return
end

local function on_signal(conn, sender, op, interface_name, signal_name, params)
    if interface_name == interface and signal_name == "PropertiesChanged" then
        local state = params.value["OperationalState"]
        print(string.format("Link %s changed state: %s", op , state or "unknown"))
    end
end

-- Async Call the ListLinks method to get all network links
manager:call('ListLinks', nil, Gio.DBusCallFlags.NONE, -1, nil, function(proxy, res)
    local result, error = proxy:call_finish(res)

    print("DBus service names:")
    for _, r in ipairs(result[1]) do
        local ifindex = r[1]  -- Interface index
        local ifname = r[2]   -- Interface name (e.g., eno1)
        local state = r[3]    -- Interface state

        if ifname == "eno1" then -- TODO: determine the currently used one
            print(state)
            local link = Gio.DBusProxy.new_sync(bus, Gio.DBusProxyFlags.NONE, nil,
                service, state, "org.freedesktop.network1.Link", nil)
            --bus:signal_subscribe(nil, "org.freedesktop.network1.Link", "PropertiesChanged", nil, nil, Gio.DBusProxyFlags.NONE, on_signal) TODO: no clue if this works
            for i, x in ipairs(link:get_cached_property_names()) do
                print(i, x)
            end
        end
    end
end)
