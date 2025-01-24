#!/bin/sh
# @license APGL-3.0 <https://www.gnu.org/licenses/>
# @author Clusterfonk <https://github.com/Clusterfonk>

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

run "keepassxc"
run "discord --start-minimized"
