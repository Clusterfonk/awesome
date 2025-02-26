-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local naughty = require("naughty")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local base = require("ui.popups.base")
local entry = require("ui.popups.notification_center.entry")
local notifications = require("ui.popups.notification_center.notifications")


local center = { mt = {} }

function center:eidx(delta)
    self._private.eidx = (self._private.eidx + delta - 1) % 5 + 1
    return self._private.eidx
end

function center:is_layout_full()
    return #self._private.layout.children >= self._private.list.MAX
end

function center:add_entry()
    local layout = self._private.layout
    self:eidx(1)
    if self:is_layout_full() then
        layout:remove_widgets(self._private.entries[self._private.eidx])
    end
    self._private.entries[self._private.eidx]:emit_signal("entry::init",
        self._private.list.tail.notification, self._private.list.tail.time)
    layout:insert(1, self._private.entries[self._private.eidx])
end

function center:request_add()
    if self.visible then
        if self._private.list:is_rnode_tail() then
            self:add_entry()
        end
    end
end

function center:show()
    if not self.visible then
        local layout = self._private.layout

        local current = self._private.list.lnode
        while current and current ~= self._private.list.rnode.next do
            self:eidx(1)
            self._private.entries[self._private.eidx]:emit_signal("entry::init",
                current.notification, current.time)
            layout:insert(1, self._private.entries[self._private.eidx])
            current = current.next
        end

        self.visible = true
    end
end

function center:hide()
    self._private.layout:reset()

    if self.visible then
        self.visible = false
    end
end

local function on_press(self, _, _, btn)
    if btn == 4 then
        if self._private.list:rslide() then
            local layout = self._private.layout
            local e = layout.children[self._private.list.MAX]

            layout:remove(self._private.list.MAX)
            e:emit_signal("entry::init",
              self._private.list.rnode.notification, self._private.list.rnode.time)
            layout:insert(1, e)
    end
    elseif btn == 5 then
        if self._private.list:lslide() then
            local layout = self._private.layout
            local e = layout.children[1]

            layout:remove(1)
            e:emit_signal("entry::init",
                self._private.list.lnode.notification, self._private.list.lnode.time)
            layout:insert(self._private.list.MAX, e)

        end
    end
end

function center.new(args)

    local total_height = args.screen.tiling_area.height - 20
    args.widget = wibox.widget {
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

    local ret = base(args)

    ret._private.layout = ret.widget:get_children_by_id("main_layout")[1]
    ret._private.entries = {}
    ret._private.list = notifications.new(args.num_entries or 5)
    ret._private.eidx = 1
    args.entry_height = total_height / ret._private.list.MAX

    for _ = 1, ret._private.list.MAX do
        table.insert(ret._private.entries, entry(args))
    end

    gtable.crush(ret, center, true)

    ret:connect_signal("button::press", on_press)

    -- WARNING: using request::display somehow stops drawing normal notifications
    --naughty.connect_signal("added", function(n)
    --    if n.app_name == "" then n.app_name = "System Notification" end
    --    n.widget = nil
    --    ret._private.list:append(n, os.time())
    --    ret:request_add()
    --end)

    if DEBUG then
        --TEST:
        --local gti = 1
        --local gtimer = require("gears.timer")
        --gtimer {
        --    timeout = 2,
        --    call_now = true,
        --    autostart = true,
        --    callback = function()
        --        if gti <= 10 then
        --            naughty.notification {
        --                text = "help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help help ",
        --                title = gti .. " Achtung!",
        --                icon = bt.icon.mic_muted,
        --                app_icon = bt.icon.ethernet,
        --                preset = naughty.config.presets.info
        --            }
        --            gti = gti + 1
        --        end
        --    end
        --}
    end
    return ret
end

function center.mt:__call(...)
    return center.new(...)
end

return setmetatable(center, center.mt)
