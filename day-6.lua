require("nmg")
input = "inputs/day6.txt"

function manhattan_distance(p1, p2)
   return (math.abs(p1["x"] - p2["x"]) + math.abs(p1["y"] - p2["y"]))
end

do
   local coordinates = {}
   local tallies = {}
   local region_size = 0
   for line in io.lines(input) do
      line = string.gsub(line, "%s", "")
      local sep = string.find(line, ",")
      local x = string.sub(line, 1, sep-1)
      local y = string.sub(line, sep+1, #line)
      table.insert(coordinates, { x = tonumber(x); y = tonumber(y)})
      table.insert(tallies, 0)
   end
   -- Now find the minimum enclosing rectangle. That's just the rectangle with points
   -- of max/min x, max/min y
   local xmax, xmin, ymax, ymin = coordinates[1]["x"], coordinates[1]["x"],
                                  coordinates[1]["y"], coordinates[1]["y"]

   for index, coordinate in ipairs(coordinates) do
      if coordinate["x"] > xmax then xmax = coordinate["x"] end
      if coordinate["x"] < xmin then xmin = coordinate["x"] end
      if coordinate["y"] > ymax then ymax = coordinate["y"] end
      if coordinate["y"] < ymin then ymin = coordinate["y"] end
   end

   -- Remove all coordinates that are the closest to the bounding box, they are
   -- infinite
   local edge_points = {}
   -- Top and bottom edges
   for x=xmin, xmax do
      local top_point = { x = x, y = ymin }
      local bottom_point = { x = x, y = ymax }
      table.insert(edge_points, top_point)
      table.insert(edge_points, bottom_point)
   end
   -- Left and right edges
   for y=ymin, ymax do
      local top_point = { x = xmin, y = y }
      local bottom_point = { x = xmax, y = y }
      table.insert(edge_points, top_point)
      table.insert(edge_points, bottom_point)
   end
   for index, edge_point in ipairs(edge_points) do
      local distances = {}
      for index, coordinate in ipairs(coordinates) do
         local distance = manhattan_distance(edge_point, coordinate)
         table.insert(distances, distance)
      end
      -- Find the minimum of the distances, and if it isn't tied, add one to
      -- that coordinates' tally, denoted by its index. We only care about area
      -- anyway.
      local min_distance, min_index = nmg.array.minimum(distances)
      if nmg.array.count(distances, min_distance) == 1 then
         coordinates[min_index]["infinite"] = true
      end

   end

   for x=xmin, xmax do
      for y=ymin, ymax do
         local point = { x = tonumber(x), y = tonumber(y) }
         -- For all the coordinate points, find distance
         local distances = {}
         for index, coordinate in ipairs(coordinates) do
            local distance = manhattan_distance(point, coordinate)
            table.insert(distances, distance)

         end
         -- Find the minimum of the distances, and if it isn't tied, add one to
         -- that coordinates' tally, denoted by its index. We only care about area
         -- anyway.
         local min_distance, min_index = nmg.array.minimum(distances)
         if nmg.array.count(distances, min_distance) == 1
            and not coordinates[min_index]["infinite"]
         then
            tallies[min_index] = tallies[min_index] + 1
         end
         if nmg.array.sum(distances) < 10000 then
            region_size = region_size + 1
         end
      end
   end
   print("Part 1: " .. nmg.array.maximum(tallies))
   print("Part 2: " .. region_size)
end
