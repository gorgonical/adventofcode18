require("nmg")

input = "inputs/day5.txt"

-- I don't know any better way to do this. Lua's built-in string parsing functions
-- are insufficient to read strings character-by-character.
function do_characters_match(lastbyte, thisbyte)
   if nmg.strings.is_upcase(lastbyte) and nmg.strings.to_lowcase(lastbyte) == thisbyte then return true
   elseif nmg.strings.is_lowcase(lastbyte) and nmg.strings.to_lowcase(lastbyte) == thisbyte then return true
   else return false end
end

-- Improved part 1 using a fold
function reduce_string(str)
   local accum = ""
   for character in nmg.strings.characters(str) do
      -- Starting case
      if #accum == 0 then accum = accum .. character
      else
         -- If the characters match then delete the last character of the accumulator
         -- and don't do anything with the current character
         if do_characters_match(string.byte(accum:sub(#accum, #accum)), character:byte()) then
            accum = accum:sub(1, #accum-1)
         else -- Else, append the character to the accumulator
            accum = accum .. character
         end
      end
   end
   return accum
end

part_1 = ""
do
   local line = ""
   for inline in io.lines(input) do
      line = inline
   end

   local accum = reduce_string(line)
   print("Part 1: " .. #accum)
   part_1 = accum
end

do
   -- Create sub-strings with all other stuff removed
   local bestlen, bestpair = nil, nil
   letters = { "Aa"; "bB"; "cC"; "dD"; "eE"; "fF"; "gG"; "hH"; "iI"; "jJ"; "kK"; "lL";
               "mM"; "nN"; "oO"; "pP"; "qQ"; "rR"; "sS"; "tT"; "uU"; "vV"; "wW"; "xX";
               "yY"; "zZ"; }
   for index, pair in ipairs(letters) do
      local filtered = string.gsub(part_1, "[" .. pair .. "]", "")
      local reduced = reduce_string(filtered)
      if bestlen == nil then bestlen, bestpair = #reduced, pair
      elseif #reduced < bestlen then bestlen, bestpair = #reduced, pair
      end
   end
   print("Part 2: " .. bestlen)
end
