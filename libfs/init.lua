local peripheral
peripheral = require("libperiph").peripheral
local ccfs = fs
local pathify
pathify = function(path)
  local _accum_0 = { }
  local _len_0 = 1
  for part in path:gmatch("[^/]+") do
    _accum_0[_len_0] = part
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
local init
init = function(dir)
  if dir == nil then
    dir = "/dev/"
  end
  ccfs.makeDir(dir)
  local periphl = peripheral(function(id, kind)
    print(kind)
    return true
  end)
end
return {
  pathify = pathify,
  init = init
}
