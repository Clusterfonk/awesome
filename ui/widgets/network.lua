-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")


local network = { mt = {} }

network.icons = {
    normal = bt.icon.ethernet,
    normal_focus = gcolor.recolor_image(bt.icon.ethernet, bt.fg_focus),
    active = bt.icon.wlan,
    active_focus = gcolor.recolor_image(bt.icon.wlan, bt.fg_focus)
}

local function on_lmb_press(self, _, _, btn)
    if btn == 1 then
        print("pressed network widget")
    end
end

local function on_remove()
end

function network.new(args)
    args.popup = nil

    args.height = args.height - 2 * dpi(2, args.screen)
    args.icons = network.icons

    local ret = ibutton(args)
    gtable.crush(ret, network, true)

    ret:connect_signal("button::press", on_lmb_press)
    ret:connect_signal("bar::removed", on_remove)
    return ret
end

function network.mt:__call(...)
    return network.new(...)
end

return setmetatable(network, network.mt)
