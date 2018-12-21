input = "inputs/day5.txt"

function is_upcase(charcode)
   return charcode > 64 and charcode < 91
end

function is_lowcase(charcode)
   return charcode > 96 and charcode < 123
end

function do_characters_match(lcharcode, rcharcode)
   return math.abs(lcharcode - rcharcode) == case_difference
end

-- I don't know any better way to do this. Lua's built-in string parsing functions
-- are insufficient to read strings character-by-character.
function select_characters(lastbyte, thisbyte)
   return
      ((is_upcase(thisbyte) and is_lowcase(lastbyte)) or
       (is_lowcase(thisbyte) and is_upcase(lastbyte)))
      and
      do_characters_match(lastbyte, thisbyte)
end

-- We need to chunk the string because the string.byte() function has a stack depth
-- limitation. This number was arbitrarily chosen.
function chunk_string(str)
   local increment = 5000
   local start = 1
   local strings = {}
   repeat
      local bytes = { string.byte(str, start, start+increment) }
      for index, charcode in ipairs(bytes) do
         table.insert(strings, charcode)
      end
      start = start+increment+1
   until start > #str
   return strings
end

-- Has side-effects
function filter_bytes_table(tbl)
   repeat
      local deleted = 0
      for index, charcode in ipairs(tbl) do
         local nextcharcode = tbl[index+1] or 0
         if select_characters(charcode, nextcharcode) then
            -- Because we are removing characters from the table, the index should not change
            table.remove(tbl, index)
            table.remove(tbl, index)
            deleted = deleted + 1
         end
      end
   until deleted == 0
end

-- Filter the string of all adjacent alternate-case characters
do
   local line = ""
   for inline in io.lines(input) do
      line = inline
   end

   local tbl = chunk_string(line)
   local case_difference = 32

   filter_bytes_table(tbl)

   local reduced_string = ""
   for index, charcode in ipairs(tbl) do
      reduced_string = reduced_string .. string.char(charcode)
   end

   part1 = reduced_string
   print("Part 1: " .. #reduced_string)
end

do
   -- Create sub-strings with all other stuff removed
   local bestlen, bestpair = nil, nil
   letters = { "Aa"; "bB"; "cC"; "dD"; "eE"; "fF"; "gG"; "hH"; "iI"; "jJ"; "kK"; "lL";
               "mM"; "nN"; "oO"; "pP"; "qQ"; "rR"; "sS"; "tT"; "uU"; "vV"; "wW"; "xX";
               "yY"; "zZ"; }
   local filtered = ""
   for index, pair in ipairs(letters) do
      local filtered_str = string.gsub(part1, "[" .. pair .. "]", "")
      local filtered_tbl = chunk_string(filtered_str)
      filter_bytes_table(filtered_tbl)
      filtered = ""
      for index, charcode in ipairs(filtered_tbl) do
         filtered = filtered .. string.char(charcode)
      end
      if bestlen == nil then bestlen, bestpair = #filtered, pair
      elseif #filtered < bestlen then bestlen, bestpair = #filtered, pair
      end
   end
   print("Part 2: " .. bestlen)
end
