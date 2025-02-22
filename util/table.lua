-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local setmetatable = setmetatable
local dpi = require("beautiful").xresources.apply_dpi


utils = { mt = {} }

-- Applies dpi to a table
-- @tparam table t The table to which the dpi is applied.
-- @tparam screen s The screen to which the dpi is calculated.
-- @treturn A table containing the key-dpi_applied value-pairs
function utils.dpi(t, s)
    ret = {}
    for k, v in pairs(t) do
        ret[k] = dpi(v, s)
    end
    return ret
end

return setmetatable(utils, utils.mt)