-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi
local os = os

local base_popup = require("ui.popup.base")
local textbox = require("ui.widgets.textbox")
local iconbox = require("ui.widgets.iconbox")


_calendar_popup = { mt= {} }



function _calendar_popup.mt:__call(...)
    return _calendar_popup.new(...)
end

return setmetatable(_calendar_popup, _calendar_popup.mt)
