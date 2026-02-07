--
-- wcwidth.lua
-- Copyright (C) 2016 Adrian Perez <aperez@igalia.com>
--
-- Distributed under terms of the MIT license.
--

--
-- Divides a number by two, and rounds it up to the next odd number.
--
local halfodd = (function ()
   -- Lua 5.3 has bit shift operators and integer division.
   local ok, f = pcall(function ()
      return load("return function (x) return (x >> 1) | 1 end")()
   end)
   if ok then return f end
   -- Try using a bitwise manipulation module.
   for _, name in ipairs { "bit", "bit32" } do
      local ok, m = pcall(require, name)
      if ok then
         local rshift, bor = m.rshift, m.bor
         return function (x) return bor(rshift(x, 1), 1) end
      end
   end
   -- Fall-back using the math library.
   -- Lua 5.1 has math.mod() instead of the "%" operator.
   local floor = math.floor
   if (pcall(function () return load("return 10 % 3")() == 4 end)) then
      return function (x)
         local r = floor(x / 2)
         return (r % 2 == 0) and r + 1 or r
      end
   end
   local mod = math.mod or function (x, d)
      while x > d do x = x - d end
      return x
   end
   return function (x)
      local r = floor(x / 2)
      return mod(r, 2) == 0 and r + 1 or r
   end
end)()

local function _lookup(rune, table)
   local l, r = 1, #table
   while l <= r do
      local m = halfodd(l + r)
      -- Invariants:
      -- assert(l % 2 == 1, "lower bound index is not odd")
      -- assert(r % 2 == 0, "upper bound index is not even")
      -- assert(m % 2 == 1, "middle point index is not odd")
      if rune < table[m] then
         r = m - 1
      elseif rune > table[m + 1] then
         l = m + 2
      else
         return true
      end
   end
   return false
end

local _tab_zero = require "wcwidth.zerotab"
local _tab_wide = require "wcwidth.widetab"
local _tab_ambi = require "wcwidth.ambitab"

local function wcwidth (rune, ambiguous_width)
	-- Early return for printable ASCII characters
	if rune >= 32 and rune < 0x7F then
		return 1
	end

	if rune == 0 then
		return 0
	end

   -- C0/C1 control characters
   if rune < 32 or (0x07F <= rune and rune < 0x0A0) then
      return -1
   end

   -- Combining characters with zero width
   if _lookup(rune, _tab_zero) then
      return 0
   end

	if _lookup(rune, _tab_wide) then
		return 2
	end

	if ambiguous_width == 2 and _lookup(rune, _tab_ambi) then
		return 2
	end

	return 1
end

return wcwidth
