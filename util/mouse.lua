-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local setmetatable = setmetatable


local utils = { mt = {} }

function utils.set_cursor(symbol)
    root.cursor(symbol)
    local wibox = mouse.current_wibox
    if wibox then
        wibox.cursor = symbol
    end
end

return setmetatable(utils, utils.mt)
