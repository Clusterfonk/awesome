-- @license apgl-3.0 <https://www.gnu.org/licenses/>
-- @author clusterfonk <https://github.com/clusterfonk>
local ascreen = require("awful.screen")
local wibox = require("wibox")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gobject = require("gears.object")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local entry = require(... .. ".entry")
local linked_list = require(... .. ".linked_list")
local base = require("ui.popups.base")


local center = { mt = {} }
center.signal = gobject {}
center.list = linked_list(5)
center.is_empty = true

function center:eidx(delta)
    self._private.eidx = (self._private.eidx + delta - 1) % 5 + 1
    return self._private.eidx
end

function center:is_layout_full()
    return #self._private.layout.children >= center.list.MAX
end

function center:add_entry()
    local layout = self._private.layout
    self:eidx(1)
    if self:is_layout_full() then
        layout:remove_widgets(self._private.entries[self._private.eidx])
    end
    self._private.entries[self._private.eidx]:emit_signal("entry::init",
        center.list.tail.notification, center.list.tail.time)
    layout:insert(1, self._private.entries[self._private.eidx])
end

local function set_is_empty(value)
    if center.is_empty == value then return end

    center.is_empty = value
    center.signal:emit_signal("property::list_empty")
end

function center.add(n, time)
    center.list:append(n, time)
    set_is_empty(false)

    if center.instance and center.instance.visible then
        if center.list:is_rnode_tail() then
            center.instance:add_entry()
        end
    end
end

function center:show()
    local layout = self._private.layout

    if not self.visible then
        local current = center.list.lnode
        while current and current ~= center.list.rnode.next do
            self:eidx(1)
            self._private.entries[self._private.eidx]:emit_signal("entry::init",
                current.notification, current.time)
            layout:insert(1, self._private.entries[self._private.eidx])
            current = current.next
        end
    end

    if #layout.children > 0 then
        self._parent.show(self)
    end
end

function center:hide()
    self._private.layout:reset()
    self._parent.hide(self)
end

local function on_press(self, _, _, btn)
    if btn == 3 then
        self._private.layout:reset()
        center.list:clear()
        set_is_empty(true)
        self:hide()
    end
    if btn == 4 then
        if center.list:rslide() then
            local layout = self._private.layout
            local e = layout.children[center.list.MAX]

            layout:remove(center.list.MAX)
            e:emit_signal("entry::init",
                center.list.rnode.notification, center.list.rnode.time)
            layout:insert(1, e)
        end
    elseif btn == 5 then
        if center.list:lslide() then
            local layout = self._private.layout
            local e = layout.children[1]

            layout:remove(1)
            e:emit_signal("entry::init",
                center.list.lnode.notification, center.list.lnode.time)
            layout:insert(center.list.MAX, e)
        end
    end
end

function center.new(args)
    args = args or {}
    args.ontop = args.ontop or true
    args.visible = args.visible or false
    args.destroy_timeout = 20

    local ret = base(args)
    rawset(ret, "_parent", {
        destroy = ret.destroy,
        show = ret.show,
        hide = ret.hide
    })
    gtable.crush(ret, center, true)

    local total_height = ascreen.focused().tiling_area.height - 20
    ret.widget = wibox.widget.base.make_widget_declarative {
        {
            {
                id = "main_layout",
                spacing = bt.useless_gap,
                layout = wibox.layout.fixed.vertical
            },
            widget = wibox.container.margin,
            margins = 10,
        },
        widget = wibox.container.constraint,
        strategy = "max",
        height = total_height,
        width = dpi(500, args.screen)
    }

    ret._private.layout = ret.widget:get_children_by_id("main_layout")[1]
    ret._private.entries = {}
    center.list.new(args.num_entries or 5)
    ret._private.eidx = 1
    args.entry_height = total_height / center.list.MAX

    for _ = 1, center.list.MAX do
        table.insert(ret._private.entries, entry(args))
    end

    ret:connect_signal("property::visible", function(self)
        if self and self.visible then
            center.signal:emit_signal("property::visible")
        end
    end)

    ret:connect_signal("button::press", on_press)

    local _debug = require("_debug")
    if _debug.gc_finalize then
        _debug.attach_finalizer(ret, "notification_center")
    end
    return ret
end

function center:destroy()
    -- Call parent destroy
    self._parent.destroy(self)
    center.instance = nil

    -- Garbage collection
    gtimer.delayed_call(function()
        collectgarbage("collect")
        collectgarbage("collect")
    end)
end

function center.mt:__call(...)
    if center.instance then
        return center.instance
    end
    center.instance = center.new(...)
    return center.instance
end

return setmetatable(center, center.mt)
