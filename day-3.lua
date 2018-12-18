-- ;; This buffer is for text that is not saved, and for Lisp evaluation.
-- ;; To create a file, visit it with <open> and enter text in its buffer.

require("io")
require("table")
require("string")

function make2d(length, width)
   local tbl = {}
   for i=1, length do
      tbl[i] = {}
      for j=1, width do
         tbl[i][j] = 0
      end
   end
   return tbl
end

function parse_fabric_line(line)
   local tbl = {}
   local fields = {}
   for tok in string.gmatch(line, "[^%s]+") do
      table.insert(fields, tok)
   end
   tbl['fields'] = tbl
   tbl['id'] = fields[1]
   tbl['start'] = {}
   -- We expect that it is ordered (x,y)
   --print("coordinates")
   for coordinate in string.gmatch(fields[3], "[^,:]+") do
      --print(coordinate)
      table.insert(tbl['start'], coordinate)
   end
   tbl['extent'] = {}
   --print("lengths")
   for length in string.gmatch(fields[4], "[^x]+") do
      --print(length)
      table.insert(tbl['extent'], length)
   end
   return tbl
end

claims  = {}
claims_aggregate = make2d(1000, 1000)
filename = "input.txt"
for line in io.lines(filename) do
   local claim = parse_fabric_line(line)
   table.insert(claims, claim)
   -- Increment each square of the claim
   for i=claim['start'][1], claim['start'][1]+claim['extent'][1]-1 do
      -- For loop lengths are inclusive. Remember to remove one from the upper bound
      for j=claim['start'][2], claim['start'][2]+claim['extent'][2]-1 do
         claims_aggregate[i][j] = claims_aggregate[i][j] + 1
      end
   end
end

overall_count = 0
for xdim=1, #claims_aggregate do
   for ydim=1, #claims_aggregate[1] do
      if claims_aggregate[xdim][ydim] > 1 then
         overall_count = overall_count + 1
      end
   end
end

function does_overlap(claims, claim)
   local does_overlap = false
   for i=claim['start'][1], claim['start'][1]+claim['extent'][1]-1 do
      for j=claim['start'][2], claim['start'][2]+claim['extent'][2]-1 do
         if claims[i][j] > 1 then
            does_overlap = true
         end
      end
   end
   return does_overlap
end

for key, value in pairs(claims) do
   if not does_overlap(claims_aggregate, value) then
      print(value['id'])
   end
end

print(overall_count)
