require("nmg")

input = "inputs/day8.txt"

function new_idgen()
   local id = -1
   return function()
      id = id + 1
      return id
   end
end

function new_node(id_gen)
   local node = {}
   node.id = id_gen()
   node.n_children = 0
   node.n_metadata = 0
   node.value = 0
   node.children = {}
   node.metadata = {}
   return node
end

local function parse_node(coro, idgen)
   local function get_next_num() return tonumber(select(2, coroutine.resume(coro))) end
   value = select(2, coroutine.resume(coro))
   if value then
      local node = new_node(idgen)
      node.n_children = tonumber(value)
      node.n_metadata = get_next_num()

      local children_to_get = node.n_children
      local metadata_to_get = node.n_metadata
      while children_to_get > 0 do
         table.insert(node.children, parse_node(coro, idgen))
         children_to_get = children_to_get - 1
      end
      while metadata_to_get > 0 do
         local metadata = get_next_num()
         sum_metadata = sum_metadata + metadata
         table.insert(node.metadata, metadata)
         metadata_to_get = metadata_to_get - 1
      end

      -- Now we can compute the value of the node since we have all the children and
      -- the metadata
      if node.n_children == 0 then
         for index, md in ipairs(node.metadata) do node.value = node.value + md end
      else
         for index, child_index in ipairs(node.metadata) do
            if node.children[child_index] then
               node.value = node.value + node.children[child_index].value
            end
         end
      end
      return node
   else return nil
   end
end

do
   sum_metadata = 0
   input_str = ""
   for lines in io.lines(input) do
      input_str = input_str .. lines
   end

   file_reader_coro = coroutine.create(function ()
         for digit in string.gmatch(input_str, "[^%s]+") do
            coroutine.yield(digit)
         end
         coroutine.yield(nil)
   end)

   idgen = new_idgen()
   tree = parse_node(file_reader_coro, idgen)

   print("Part 1: " .. sum_metadata)
   print("Part 2: " .. tree.value)
end
