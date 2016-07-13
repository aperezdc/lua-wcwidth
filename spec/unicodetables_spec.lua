--
-- unicodetables_spec.lua
-- Copyright (C) 2016 Adrian Perez <aperez@igalia.com>
--
-- Distributed under terms of the MIT license.
--

local function check_table(t, step)
   for i = 1, #t - step, step do
      assert(t[i] <= t[i + step])
   end
end

describe("wcwidth.zerotab", function ()
   local zerotab = require "wcwidth.zerotab"
   it("is sorted", function ()
      check_table(zerotab, 1)
      check_table(zerotab, 2)
   end)
end)

describe("wcwidth.widetab", function ()
   local widetab = require "wcwidth.widetab"
   it("is sorted", function ()
      check_table(widetab, 1)
      check_table(widetab, 2)
   end)
end)
