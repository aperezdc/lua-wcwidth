#! /usr/bin/env lua
--
-- wcwidth.lua
-- Copyright (C) 2016 Adrian Perez <aperez@igalia.com>
--
-- Distributed under terms of the MIT license.
--

local _tab_zero = require "wcwidth.zerotab"
local _tab_wide = require "wcwidth.widetab"

local function _lookup(rune, table)
   -- TODO: Change the linear search to binary search.
   for i = 1, #table, 2 do
      local lo, hi = table[i], table[i + 1]
      if lo <= rune and rune <= hi then
         return 1
      end
   end
   return 0
end

local function wcwidth (rune)
   if rune == 0 or
      rune == 0x034F or
      rune == 0x2028 or
      rune == 0x2029 or
      (0x200B <= rune and rune <= 0x200F) or
      (0x202A <= rune and rune <= 0x202E) or
      (0x2060 <= rune and rune <= 0x2063)
   then
      return 0
   end

   -- C0/C1 control characters
   if rune < 32 or (0x07F <= rune and rune < 0x0A0) then
      return -1
   end

   -- Combining characters with zero width
   if _lookup(rune, _tab_zero) == 1 then
      return 0
   end

   return 1 + _lookup(rune, _tab_wide)
end

return wcwidth
