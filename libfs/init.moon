-- libfs
-- Filesystem library for Pantheon
-- By daelvn
import peripheral from require "libperiph"
ccfs = fs

-- turns a path into parts
pathify = (path) -> [part for part in path\gmatch "[^/]+"]

-- initialize a libfs system
init = (dir="/dev/") ->
  -- create directory
  ccfs.makeDir dir
  -- load devices
  periphl = peripheral (id, kind) ->
    print kind
    return true

{
  :pathify
  :init
}