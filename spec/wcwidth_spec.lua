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
-- A number of test cases are from:
-- https://github.com/jquast/wcwidth/blob/master/tests/
--
describe("wcwidth()", function ()
   it("reports double-width for Katakana Ko", function ()
      local input = "コ"
      local rune = utf8.codepoint(input)
      assert.equal(2, wcwidth(rune))
   end)
   it("handles a mix of Japanese and ASCII", function ()
      -- Given a phrase of 5 and 3 Katakana ideographs, joined with 3 English
      -- ASCII punctuation characters, totaling 11, this phrase consumes 19
      -- cells of a terminal emulator.
      test_phrase("コンニチハ, セカイ!",
         { 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 1 }, 19)
   end)
   it("reports 0 width for NULL", function ()
      assert.equal(0, wcwidth(0x00))
      test_phrase("abc\0def", { 1, 1, 1, 0, 1, 1, 1 }, 6)
   end)
   it("reports width -1 for CSI", function ()
      assert.equal(-1, wcwidth(0x1B))
      -- XXX: Using "\x1B[0m" does *not* work in Lua 5.1 because of the \xNN
      --      syntax, so use string.char() instead to build the input string.
      test_phrase(string.char(0x1B) .. "[0m", { -1, 1, 1, 1 }, -1)
   end)
   it("handles combining characters", function ()
      -- Simple test combining reports total width of 4.
      test_phrase("--" .. utf8.char(0x05BF) .. "--", { 1, 1, 0, 1, 1 }, 4)
   end)
   it("handles a combining accent in 'café'", function ()
      -- Phrase cafe + COMBINING ACUTE ACCENT is café of length 4.
      test_phrase("cafe" .. utf8.char(0x0301), { 1, 1, 1, 1, 0 }, 4)
   end)
   it("handles a combining enclosing character", function ()
      -- CAPITAL LETTER A + COMBINING ENCLOSING CIRCLE has length 1.
      test_phrase(utf8.char(0x41, 0x20DD), { 1, 0 }, 1)
   end)
   it("handles multiple combining characters", function ()
      -- A + acute + grave
      test_phrase(utf8.char(0x41, 0x0301, 0x0300), { 1, 0, 0 }, 1)
   end)
   it("handles a 👍 emoji", function ()
      test_phrase("two 👍", { 1, 1, 1, 1, 2 }, 6)
   end)
   it("can report ambiguous-width char as either 1 or 2", function ()
      assert.equal(1, wcwidth(0x451))
      assert.equal(1, wcwidth(0x451, 1))
      assert.equal(2, wcwidth(0x451, 2))
   end)
end)

