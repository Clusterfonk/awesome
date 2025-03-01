-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local gtable = require("gears.table")
local gcolor = require("gears.color")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local ibutton = require("ui.widgets.ibutton")


local sync = { mt = {} }

sync.icons = {
    normal = bt.icon.sync_ok,
    normal_focus = gcolor.recolor_image(bt.icon.sync_ok, bt.fg_focus),
    active = bt.icon.sync_notif,
    active_focus = gcolor.recolor_image(bt.icon.sync_notif, bt.fg_focus)
}

local function on_lmb_press(self, _, _, btn)
    if btn == 1 then
        print("pressed sync widget")
    end
end

local function on_remove()
end

function sync.new(args)
    args.popup = nil

    args.height = args.height
    args.icons = sync.icons

    local ret = ibutton(args)
    gtable.crush(ret, sync, true)

    ret:connect_signal("button::press", on_lmb_press)
    ret:connect_signal("bar::removed", on_remove)
    return ret
end

function sync.mt:__call(...)
    return sync.new(...)
end

return setmetatable(sync, sync.mt)
