--      @license APGL-3.0 <https://www.gnu.org/licenses/>
--      @author clusterfonk
local abutton        = require("awful.button")
local ascreen        = require("awful.screen")
local awcommon       = require("awful.widget.common")
local beautiful      = require("beautiful")
local cst            = require("naughty.constants")
local default_widget = require("naughty.widget._default")
local dpi            = require("beautiful").xresources.apply_dpi
local gpcall         = require("gears.protected_call")
local gtable         = require("gears.table")
local gtimer         = require("gears.timer")
local popup          = require("awful.popup")
local wibox          = require("wibox")

local capi = {
    screen = screen
}


local nbox            = { mt = {} }
local notifications  = {}
local by_bar         = setmetatable({}, { __mode = "k" })

local function init_screen(s)
    if notifications[s] then return notifications[s] end

    notifications[s] = setmetatable({}, { __mode = "kv" })

    return notifications[s]
end

function nbox.init_bars(screen, l, m, r)
    local weak_values = setmetatable({}, { __mode = "v" })
    weak_values.left = l
    weak_values.middle = m
    weak_values.right = r

    by_bar[screen] = weak_values
end

local function disconnect(self)
    if self.widget then
        local progress = self.widget:get_children_by_id("progress")[1]
        if progress and progress.timer then
            progress.timer:stop()
            progress.timer = nil
        end
    end

    local n = self._private.notification[1]
    if n then
        n:disconnect_signal("destroyed",
            self._private.destroy_callback)

        n:disconnect_signal("property::margin",
            self._private.update)

        n:disconnect_signal("property::suspended",
            self._private.hide)

        self._private.notification[1] = nil
    end

    self._private.update = nil
    self._private.hide = nil
end

ascreen.connect_for_each_screen(init_screen)

-- Manually cleanup to help the GC.
capi.screen.connect_signal("removed", function(scr)
    for i = #notifications[scr], 1, -1 do
        -- could move them over to primary screen if its not already
        notifications[i]._private.destroy_callback()
    end
    -- By that time, all direct events should have been handled. Cleanup the
    -- leftover. Being a weak table doesn't help Lua 5.1.
    gtimer.delayed_call(function()
        notifications[scr] = nil
        by_bar[scr] = nil
    end)
end)

-- Get spacing measurements for notification positioning
local function get_spacing()
    local gap = beautiful.useless_gap
    local border = beautiful.bars.border_width

    return {
        left = gap + 4 * border,
        right = gap + 3 * border,
        top = gap,
        vertical = 2 * gap + border,
        border = border
    }
end

-- Calculate distance between a bar and the middle
local function distance_between(bar, middle)
    local bar_geo = bar:geometry()
    local middle_geo = middle:geometry()

    local bar_x = bar_geo.x
    local bar_width = bar_geo.width
    local middle_x = middle_geo.x
    local middle_width = middle_geo.width

    return (bar_x < middle_x)
        and (middle_x - bar_x - bar_width) -- left bar
        or  (bar_x - middle_x - middle_width) -- right bar
end

-- Position a main notification
local function position_main(notif, left_element, right_element, spacing)
    local geo = notif:geometry()
    local left_geo = left_element:geometry()

    geo.x = left_geo.x + left_geo.width + spacing.left
    geo.y = spacing.top
    local width = distance_between(left_element, right_element) - spacing.left - spacing.right
    local height = left_geo.height + spacing.border

    notif:geometry(geo)
    notif.minimum_width = width
    notif.maximum_width = width
    notif.minimum_height = height
    notif.maximum_height = height

    return {
        x = geo.x,
        y = geo.y,
        width = width,
        height = height
    }
end

-- Position a notification below another one
local function position_stacked(notif, above_notif, main_geo, spacing)
    local geo = notif:geometry()
    local above_geo = above_notif:geometry()

    geo.x = main_geo.x
    geo.y = above_geo.y + above_geo.height + spacing.vertical

    notif:geometry(geo)
    notif.minimum_width = main_geo.width
    notif.maximum_width = main_geo.width
    notif.minimum_height = main_geo.height
    notif.maximum_height = main_geo.height
end

-- Update notification positions starting from a specific index
local function update_position(screen, start_index)
    start_index = start_index or 1

    local bars = by_bar[screen]
    local notifs = notifications[screen]
    local spacing = get_spacing()

    -- Get references to the main notification geometries
    local left_geo, right_geo

    if notifs[2] then  -- If left main exists
        left_geo = {
            x = notifs[2]:geometry().x,
            y = notifs[2]:geometry().y,
            width = notifs[2].minimum_width
        }
    end

    if notifs[1] then  -- If right main exists
        right_geo = {
            x = notifs[1]:geometry().x,
            y = notifs[1]:geometry().y,
            width = notifs[1].minimum_width
        }
    end

    for i = start_index, #notifs do
        local notif = notifs[i]

        if i % 2 == 0 then -- left
            if i == 2 then -- left main notification
                left_geo = position_main(notif, bars.left, bars.middle, spacing)
            else
                position_stacked(notif, notifs[i-2], left_geo, spacing)
            end
        else -- right
            if i == 1 then -- right main notification
                right_geo = position_main(notif, bars.middle, bars.right, spacing)
            else
                position_stacked(notif, notifs[i-2], right_geo, spacing)
            end
        end

        notif:_apply_size_now()
    end
end

local function clear_notification_refs(w)
    if w.set_notification then
        pcall(function() w:set_notification(nil) end)
    end

    if w.get_children then
        for _, child in ipairs(w:get_children()) do
            clear_notification_refs(child)
        end
    end
end

local function finish(self)
    self.visible = false
    assert(init_screen(self.screen))

    local index = 1
    for k, v in ipairs(init_screen(self.screen)) do
        if v == self then
            index = k
            table.remove(init_screen(self.screen), k)
            break
        end
    end

    update_position(self.screen, index)

    if self.widget then
        clear_notification_refs(self.widget)
    end

    disconnect(self)

    self._private.notification = {}
end

local function setup_timeout(self, notification)
    local original_timeout = notification.timeout

    local progressbar = self.widget:get_children_by_id("progress")[1]
    progressbar.max_value = original_timeout - 32 / 60
    progressbar.timer = gtimer {
        timeout   = 1 / 60, -- 60 fps
        autostart = true,
        callback  = function()
            progressbar.value = progressbar.value + (1 / 60)
        end
    }

    if notification.timeout then
        self:connect_signal("mouse::enter", function()
            self.widget:get_children_by_id("progress")[1].value = 0
            notification.timeout = 99999
            progressbar.timer:stop()
        end)
    end

    if notification.timeout then
        self:connect_signal("mouse::leave", function()
            notification.timeout = original_timeout
            progressbar.timer:start()
        end)
    end
end

-- It isn't a good idea to use the `attach` `awful.placement` property. If the
-- screen is resized or the notification is moved, it causes side effects.
-- Better listen to geometry changes and reflow.
capi.screen.connect_signal("property::geometry", function(s)
    if #notifications[s] > 0 then
        update_position(s)
    end
end)

local function generate_widget(args, n)
    local w = gpcall(wibox.widget.base.make_widget_from_value,
        args.widget_template or (n and n.widget_template) or default_widget
    )

    -- This will happen if the user-provided widget_template is invalid and/or
    -- got unexpected notifications.
    if not w then
        w = gpcall(wibox.widget.base.make_widget_from_value, default_widget)

        -- In case this happens in an error message itself, make sure the
        -- private error popup code knowns it and can revert to the fallback
        -- popup.
        if not w then
            n._private.widget_template_failed = true
        end

        return nil
    end

    -- Call `:set_notification` on all children
    awcommon._set_common_property(w, "notification", n)

    return w
end

local function init(self, notification)
    if not self.widget then
        self.widget = generate_widget(self._private, notification)
    end

    local bg = self._private.widget:get_children_by_id("background_role")[1]

    -- Make sure the border isn't set twice, favor the widget one since it is
    -- shared by the notification list and the notification box.
    if bg then
        if bg.set_notification then
            bg:set_notification(notification)
            self.border_width = dpi(1)
        else
            bg:set_bg(notification.bg)
            self.border_width = notification.border_width
        end
    end

    local s = notification.screen
    local notifs = init_screen(s)

    table.insert(notifs, self)

    self._private.update = function()
        update_position(self.screen)
    end
    self._private.hide = function(_, value)
        if value then
            finish(self)
        end
    end

    if notification.timeout and notification.timeout > 0 then
        setup_timeout(self, notification)
    end

    notification:weak_connect_signal("property::margin", self._private.update)
    notification:weak_connect_signal("property::suspended", self._private.hide)
    notification:weak_connect_signal("destroyed", self._private.destroy_callback)

    update_position(self.screen, #notifs)

    self.visible = true
end

function nbox:set_notification(notif)
    if self._private.notification[1] == notif then return end

    disconnect(self)

    init(self, notif)

    self._private.notification = setmetatable({ notif }, { __mode = "v" })

    self:emit_signal("property::notification", notif)
end

function nbox:get_notification()
    return self._private.notification[1]
end

--- Create a notification popup box.
--
-- @constructorfct naughty.layout.box
-- @tparam[opt=nil] table args
-- @tparam table args.widget_template A widget definition template which will
--  be instantiated for each box.
-- @tparam naughty.notification args.notification The notification object.
-- @tparam string args.position The position. See `naughty.notification.position`.
--@DOC_wibox_constructor_COMMON@
-- @usebeautiful beautiful.notification_position If `position` is not defined
-- in the notification object (or in this constructor).

local function new(args)
    args = args or {}

    -- Set the default wibox values
    local new_args = {
        ontop        = true,
        visible      = false,
        bg           = args.bg or beautiful.notification_bg,
        fg           = args.fg or beautiful.notification_fg,
        shape        = args.shape or beautiful.notification_shape,
        border_width = args.border_width or beautiful.notification_border_width or 1,
        border_color = args.border_color or beautiful.notification_border_color,
    }

    -- The C code needs `pairs` to work, so a full copy is required.
    gtable.crush(new_args, args, true)

    -- Add a weak-table layer for the screen.
    local weak_args = setmetatable({
        screen = args.notification and args.notification.screen or nil
    }, { __mode = "v" })

    setmetatable(new_args, { __index = weak_args })

    -- Generate the box before the popup is created to avoid the size changing
    new_args.widget = generate_widget(new_args, new_args.notification)

    -- It failed, request::fallback will be used, there is nothing left to do.
    if not new_args.widget then return nil end

    local ret = popup(new_args)
    ret._private.notification = {}
    ret._private.widget_template = args.widget_template

    gtable.crush(ret, nbox, true)

    function ret._private.destroy_callback()
        finish(ret)
        ret:emit_signal("box::destroyed")
    end

    if new_args.notification then
        ret:set_notification(new_args.notification)
    end

    ret:weak_connect_signal("destroyed", ret._private.destroy_callback)

    -- On right click, close the notification without triggering the default action
    ret:buttons(gtable.join(
        abutton({}, 1, ret._private.destroy_callback),
        abutton({}, 3, ret._private.destroy_callback)
    ))

    gtable.crush(ret, nbox, false)

    local _debug = require("_debug")
    if _debug.gc_finalize then
        _debug.attach_finalizer(ret, "notification box")
    end
    return ret
end

return setmetatable(nbox, { __call = function(_, args) return new(args) end })
