lua-wcwidth
===========

When writing output to a fixed-width output system (such as a terminal), the
displayed length of a string does not always match the number of characters
(also known as [runes](https://swtch.com/plan9port/unix/man/rune3.html), or
code points) contained by the string. Some characters occupy two spaces
(full-wide characters), and others occupy none.

POSIX.1-2001 and POSIX.1-2008 specify the
[wcwidth(3)](http://man7.org/linux/man-pages/man3/wcwidth.3.html) function
which can be used to know how many spaces (or *cells*) must be used to display
a Unicode code point. This [Lua](http://lua.org) contains a portable and
standalone implementation based on the Unicode Standard release files.

This module is useful mainly for implementing programs which must produce
output to terminals, while handling proper alignment for double-width and
zero-width Unicode code points.

Usage
-----

The following snippet defines a function which can determine the display width
for a string:

```lua
local wcwidth, utf8 = require "wcwidth", require "utf8"

local function display_width(s)
  local len = 0
  for _, rune in utf8.codes(s) do
    local l = wcwidth(rune)
    if l >= 0 then
      len = len + 1
    end
  end
  return len
end
```

The function above can be used to print any UTF-8 string properly
right-aligned to a terminal:

```lua
local function alignright(s, cols)
  local numspaces = cols - display_width(s)
  local spaces = ""
  while numspaces > 0 do
    numspaces = numspaces - 1
    spaces = spaces .. " "
  end
  return spaces .. s
end

print(alignright("コンニチハ", 80))
```

Documentation
-------------

The `wcwidth()` function takes a Unicode code point as argument, and returns
one of the following values:

* `-1`: Width cannot be determined (the code point is not printable).
* `0`: The code point does not advance the cursor (e.g. `NULL`, or a combining
  character).
* `2`: The character is East Asian wide (`W`) or East Asian full-width (`F`),
  and is displayed using two spaces.
* `1`: All the rest of characters, which take a single space.


Installation
------------

[LuaRocks](https://luarocks.org) is recommended for installation.

The development version can be installed with:

```sh
luarocks install --server=https://luarocks.org/dev wcwidth
```

Unicode Tables
--------------

The `update-tables` script downloads the following resources from the [Unicode
Consortium website](http://unicode.org):

* http://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt
* http://www.unicode.org/Public/UNIDATA/extracted/DerivedGeneralCategory.txt

With them, it generates the following files:

* [wcwidth/widetab.lua](./wcwidth/widetab.lua)
* [wcwidth/zerotab.lua](./wcwidth/zerotab.lua)

The most current version of `wcwidth` uses the following versions of the above
Unicode Standard release files:

* `EastAsianWidth-9.0.0.txt, Date: 2016-05-27, 17:00:00 GMT [KW, LI], © 2016 Unicode®, Inc.`
* `DerivedGeneralCategory-9.0.0.txt, Date: 2016-06-01, 10:34:26 GMT, © 2016 Unicode®, Inc.`

