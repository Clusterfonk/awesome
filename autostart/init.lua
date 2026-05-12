-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>

local awful = require('awful')

local start_lockfile = "/tmp/awesome-started.lock"

if not io.open(start_lockfile, "r") then
    awful.spawn.with_shell("$XDG_CONFIG_HOME/awesome/autostart/autostart.sh")
    io.open(start_lockfile, "w"):close()
end


