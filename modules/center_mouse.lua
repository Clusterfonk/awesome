-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
require("awful.autofocus")

-- mouse.screen = screen.primary
-- local sg = mouse.screen.geometry
-- -- Move mouse to the center of the primary screen
-- mouse.coords({ x = sg.width / 2, 
--                y = sg.height / 2}, true)
     
               
-- TODO: figure out why secondary screen steals focus 
-- awful.screen.focus(screen.primary)
-- print(#mouse.screen.clients)
-- for _, c in pairs(mouse.screen.clients) do
--     c:emit_signal("focus")
--     break
-- end