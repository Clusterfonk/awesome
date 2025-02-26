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

function progress.update_width(self, width)
    self.widget:get_children_by_id("progressbar")[1].forced_width = width
    self:geometry({ width = width })
end

function progress.destroy(self)
    self._parent.destroy(self)

    if progress.audio_instance then
        progress.audio_instance = nil
    end
    if progress.mic_instance then
        progress.mic_instance = nil
    end
    gtimer.delayed_call(function()
        collectgarbage("collect")
        collectgarbage("collect")
    end)
end

function progress.new(args)
    args = args or {}
    args.widget = {
        layout = wibox.layout.stack,
        {
            id            = "progressbar",
            forced_height = args.height - 2,
            forced_width  = 1,
            max_value     = args.max_value or 100,
            value         = 50, -- tmp value
            color         = args.color or bt.progressbar_fg,
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
    local ret = base(args)
    rawset(ret, "_parent", { destroy = ret.destroy })
    gtable.crush(ret, progress, true)

    ret:connect_signal("bar::width", progress.update_width)
    ret:connect_signal("progress::change", progress.change)
    return ret
end

function progress.mt:__call(type, ...)
    if type == "audio" then
        if progress.audio_instance then
            return progress.audio_instance
        end
        progress.audio_instance = progress.new(...)
        return progress.audio_instance
    end

    if type == "mic" then
        if progress.mic_instance then
            return progress.mic_instance
        end
        progress.mic_instance = progress.new(...)
        return progress.mic_instance
    end
end

return setmetatable(progress, progress.mt)
