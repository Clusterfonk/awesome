-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")


local sg = screen.primary.geometry
-- Move mouse to the center of the primary screen
mouse.coords({ x = sg.width / 2, 
               y = sg.height / 2}, true)