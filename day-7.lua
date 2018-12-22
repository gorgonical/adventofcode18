require("nmg")
require("table")

input = "inputs/day7.txt"

function new_dag_node()
   return { blocks = {}, blocked_by = {}, assigned = false }
end

function contains_node(dag, step_id)
   for index, value in pairs(dag) do
      if step_id == index then return true end
   end
   return false
end

function construct_dag(input)
   local dag = {}
   for line in io.lines(input) do
      tok = string.gmatch(line, "%a+")
      tok() -- Throw away first token
      local parent_step = tok()
      for i=1, 5 do
         tok()
      end
      local child_step = tok()
      -- Add new nodes to the dag if necessary
      if not contains_node(dag, parent_step) then
         dag[parent_step] = new_dag_node()
      end
      if not contains_node(dag, child_step) then
         dag[child_step] = new_dag_node()
      end

      -- Add the dependencies to the nodes
      table.insert(dag[parent_step]["blocks"], child_step)
      table.insert(dag[child_step]["blocked_by"], parent_step)
   end
   return dag
end

-- Part 1
do
   local step_order, dag = "", construct_dag(input)
   while nmg.tables.countassoc(dag) > 0 do
      local min_id = nil
      for step_id, details in pairs(dag) do
         if nmg.tables.countassoc(details["blocked_by"]) == 0 then
            if min_id == nil or step_id < min_id then min_id = step_id end
         end
      end
      step_order = step_order .. min_id
      -- Remove the minimum step from other step's blocked_by table
      for index, blocked_step in ipairs(dag[min_id]["blocks"]) do
         local blocking_step_id = nmg.tables.find(dag[blocked_step]["blocked_by"], min_id)
         table.remove(dag[blocked_step]["blocked_by"], blocking_step_id)
      end
      -- Remove the step from the DAG
      dag[min_id] = nil
   end
   print("Part 1: " .. step_order)
end

-- Part 2
function find_available_worker(workers)
   for index, worker in pairs(workers) do
      if worker["busy_until"] == nil then return index end
   end
   return nil
end

function get_task_duration(task_id)
   local ascii_adjust = 64 -- Where the uppercase letters start in ASCII
   local base_duration = 60 -- Defined by the problem
   return string.byte(task_id) - ascii_adjust + base_duration
end

do
   local workers, time, dag = {}, 0, construct_dag(input)
   for i=1,5 do
      table.insert(workers, { task = nil, busy_until = nil, task = nil } )
   end
   while nmg.tables.countassoc(dag) > 0 do
      -- Pop tasks from workers that will finish at this time, put them into the work pool
      for index, worker in pairs(workers) do
         if worker["busy_until"] == time then
            worker["busy_until"], task_id, worker["task"] = nil, worker["task"], nil
            -- Remove the minimum step from other step's blocked_by table
            for index, blocked_step in ipairs(dag[task_id]["blocks"]) do
               local blocking_step_id = nmg.tables.find(dag[blocked_step]["blocked_by"], task_id)
               table.remove(dag[blocked_step]["blocked_by"], blocking_step_id)
            end
            -- Remove the step from the DAG
            dag[task_id] = nil
         end
      end

      -- Check repeatedly through the tasks until we find no available ones
      repeat
         local min_id, dispatched_tasks = nil, 0
         -- Check the DAG for any tasks without parent tasks that have not been
         -- assigned
         for step_id, details in pairs(dag) do
            if nmg.tables.countassoc(details["blocked_by"]) == 0 and not details["assigned"] then
               if min_id == nil or step_id < min_id then min_id = step_id end
            end
         end
         -- If we find any, try to find a worker to assign it to. If we do, we will
         -- assign it and repeat this loop
         if min_id then
            local available_id = find_available_worker(workers)
            if available_id then
               workers[available_id]["task"] = min_id
               workers[available_id]["busy_until"] = time + get_task_duration(min_id)
               dag[min_id]["assigned"] = true
               dispatched_tasks = dispatched_tasks + 1
            end
         end
      until dispatched_tasks == 0

      -- Now, set time for next loop to the minimum busy_until time.
      local min_time = nil
      for index, worker in pairs(workers) do
         if worker["busy_until"] and (min_time == nil or worker["busy_until"] < min_time)
         then min_time = worker["busy_until"] end
      end
      if min_time then time = min_time end
   end
   print("Part 2: " .. time)
end
