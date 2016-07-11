package = "wcwidth"
version = "scm-0"
description = {
   summary = "Pure Lua implementation of the wcwidth() function",
   homepage = "https://github.com/aperezdc/lua-wcwidth",
   license = "MIT/X11",
}
source = {
   url = "git://github.com/aperezdc/lua-wcwidth",
}
dependencies = {
   "lua >= 5.1",
}
build = {
   type = "builtin",
   ["wcwidth"]         = "wcwidth.lua",
   ["wcwidth.init"]    = "wcwidth/init.lua",
   ["wcwidth.zerotab"] = "wcwidth/zerotab.lua",
   ["wcwidth.widetab"] = "wcwidth/widetab.lua",
}
