package = "wcwidth"
version = "0.1-1"
source = {
   url = "git://github.com/aperezdc/lua-wcwidth",
   tag = "v0.1"
}
description = {
   summary = "Pure Lua implementation of the wcwidth() function",
   homepage = "https://github.com/aperezdc/lua-wcwidth",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      wcwidth = "wcwidth.lua",
      ["wcwidth.init"] = "wcwidth/init.lua",
      ["wcwidth.widetab"] = "wcwidth/widetab.lua",
      ["wcwidth.zerotab"] = "wcwidth/zerotab.lua"
   }
}
