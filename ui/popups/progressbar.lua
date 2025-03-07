-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local bt = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")

local base = require("ui.popups.base")


local progress = { mt = {} }

function progress:change(val, screen, placement)
    self:show(screen, placement)
    local bar = self.widget:get_children_by_id("progressbar")[1]
    local txt = self.widget:get_children_by_id("textbox")[1]
    local new_value = math.max(0, math.min(bar.value + val, bar.max_value))

    bar.value = new_value
    txt:set_text(new_value .. "%")
end

-- does not work
function progress.update_width(self, width)
    self.widget:get_children_by_id("progressbar")[1].forced_width = width
    self:geometry({ width = width })
end

function progress.destroy(self)
    self._parent:destroy()
    progress.instance = nil

    gtimer.delayed_call(function()
        collectgarbage("collect")
        collectgarbage("collect")
    end)
end

function progress.new(args)
    args = args or {}
    args.destroy_timeout = 20
    local ret = base(args)
    rawset(ret, "_parent", { destroy = ret.destroy })
    gtable.crush(ret, progress, true)

    ret.widget = wibox.widget.base.make_widget_declarative {
        layout = wibox.layout.stack,
        {
            id            = "progressbar",
            forced_height = args.height or 25,
            forced_width  = args.width or 100,
            max_value     = args.max_value or 100,
            value         = args.value or 50,
            color         = args.color,
            widget        = wibox.widget.progressbar
        },
        {
            id     = "textbox",
            text   = "50%", -- will get the value from the daemon cached value
            valign = "center",
            halign = "center",
            widget = wibox.widget.textbox,
            font   = bt.font_bold,
        },
    }

    ret._private.bar = ret.widget:get_children_by_id("progressbar")[1]
    ret._private.txt = ret.widget:get_children_by_id("textbox")[1]

    ret:connect_signal("update::width", progress.update_width)
    local _debug = require("_debug")
    if _debug.gc_finalize then
        _debug.attach_finalizer(ret, "progressbar")
    end
    return ret
end


function progress.init(self, args)
    if args.color then
        self._private.bar.color = args.color
    end

    if args.height then
        self._private.bar.forced_height = args.height
    end

    if args.width then
        self._private.bar.forced_width = args.width
        self:geometry({ width = args.width })
    end
end

function progress.mt:__call(args)
    if progress.instance then
        return progress.instance
    end
    progress.instance = progress.new(args)
    return progress.instance
end

return setmetatable(progress, progress.mt)
