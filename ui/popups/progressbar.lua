-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local bt = require("beautiful")
local gtable = require("gears.table")

local base = require("ui.popups.base")


progress = { mt = {} }

function progress:change(val)
    self:show()
    local bar = self.widget.children[1]
    local txt = self.widget.children[2]
    local new_value = math.max(0, math.min(bar.value + val, bar.max_value))

    bar.value = new_value
    txt:set_text(new_value .. "%")
end

-- might need to be able to switch screens
function progress.new(args)
    args.widget = wibox.widget {
        {
            max_value     = 100,
            value         = 50,
            forced_height = args.height - 2,
            forced_width  = 174, -- TODO: maybe get the actual size from bar ?
            color         = args.color or bt.progressbar_fg,
            widget        = wibox.widget.progressbar
        },
        {
            text   = "50%", -- will get the value from the daemon cached value
            valign = "center",
            halign = "center",
            widget = wibox.widget.textbox,
            font = bt.font_bold,
        },
        layout = wibox.layout.stack,
    }
    local ret = base(args)


    ret:connect_signal("popup::increment", function(self, val) self:change(val) end)
    ret:connect_signal("popup::decrement", function(self, val) self:change(-val) end)

    gtable.crush(ret, progress, true)
    return ret
end

function progress.mt:__call(...)
    return progress.new(...)
end

return setmetatable(progress, progress.mt)
