#! /usr/bin/env lua
--
-- wcwidth_spec.lua
-- Copyright (C) 2016 Adrian Perez <aperez@igalia.com>
--
-- Distributed under terms of the MIT license.
--

local wcwidth = require "wcwidth"
local utf8 = require "dromozoa.utf8"

local function test_phrase(input, expected_lengths, expected_total_length)
   local i = 1
   local total_length = 0
   for _, rune in utf8.codes(input) do
      local w = wcwidth(rune)
      assert.equal(expected_lengths[i], w)
      if w < 0 then
         total_length = -1
      elseif total_length >= 0 then
         total_length = total_length + w
      end
      i = i + 1
   end
   assert.equal(expected_total_length, total_length)
end

--
-- Many test cases are from:
-- https://github.com/jquast/wcwidth/blob/master/wcwidth/tests/test_core.py
--
describe("wcwidth()", function ()

   it("handles a mix of Japanese and ASCII", function ()
      -- Given a phrase of 5 and 3 Katakana ideographs, joined with 3 English
      -- ASCII punctuation characters, totaling 11, this phrase consumes 19
      -- cells of a terminal emulator.
      test_phrase("コンニチハ, セカイ!",
         { 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 1 }, 19)
   end)
   it("reports 0 width for NULL", function ()
      test_phrase("abc\0def", { 1, 1, 1, 0, 1, 1, 1 }, 6)
   end)
   it("reports width -1 for CSI", function ()
      test_phrase("\x1B[0m", { -1, 1, 1, 1 }, -1)
   end)
   it("handles combining characters", function ()
      -- Simple test combining reports total width of 4.
      test_phrase("--" .. utf8.char(0x05BF) .. "--", { 1, 1, 0, 1, 1 }, 4)
   end)
   it("handles a combining accent in 'café'", function ()
      -- Phrase cafe + COMBINING ACUTE ACCENT is café of length 4.
      test_phrase("cafe" .. utf8.char(0x0301), { 1, 1, 1, 1, 0 }, 4)
   end)
   it("handles a combining enclosing", function ()
      -- CYRILLIC CAPITAL LETTER A + COMBINING CYRILLIC HUNDRED THOUSANDS SIGN is А҈ of length 1.
      test_phrase(utf8.char(0x0410, 0x0488), { 1, 0 }, 1)
   end)
   it("handles combining spaces", function ()
      -- Balinese kapal (ship) is ᬓᬨᬮ᭄ of length 4.
      test_phrase(utf8.char(0x1B13, 0x1B28, 0x1B2E, 0x1B44), { 1, 1, 1, 1 }, 4)
   end)
end)

