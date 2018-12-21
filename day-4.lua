input = "inputs/day4.txt"

function get_guard_id_or_nil(message)
   local tok = string.gmatch(message, "#%d+")
   local guard_id = tok()
   if guard_id ~= nil then
      guard_id = string.gsub(guard_id, "#", "")
      guard_id = tonumber(guard_id)
   end
   return guard_id
end

-- Given something like "12:34" return "34"
function convert_time_to_minutes(time)
   local time_tok = string.gmatch(time, "[^:]+")
   time_tok()
   local minutes = tonumber(time_tok())
   return minutes
end

function parse_line_to_record(line)
   record = {}
   record_tokenizer = string.gmatch(line, "[^%]]+")
   date_part = record_tokenizer()
   cleaned = string.gsub(date_part, "%[", "")

   record["time"] = cleaned
   record["message"] = record_tokenizer()
   -- Convenient for finding intervals
   record["minutes"] = convert_time_to_minutes(record["time"])
   return record
end

function collect_sleeping(records)
   local guard_id = nil
   for index, value in ipairs(records) do
      local new_guard_id = get_guard_id_or_nil(value["message"])
      if new_guard_id ~= nil then
         guard_id = new_guard_id
      end
      if string.find(value["message"], "asleep") ~= nil then
         local asleep_at = value["minutes"]
         local woke_at = records[index+1]["minutes"]

         -- Increment all the minutes that the guard was asleep for
         for i=asleep_at, woke_at-1 do
            if guards[guard_id]["minutes"][i] == nil then
               guards[guard_id]["minutes"][i] = 0
            end
            guards[guard_id]["minutes"][i] = guards[guard_id]["minutes"][i] + 1
         end

         -- Add to the total minutes the guard was sleeping: [start, end)
         guards[guard_id]["total"] = guards[guard_id]["total"] + (woke_at - asleep_at)
      end
   end
end

function max_minute(minutes)
   local max, max_index = 0, nil
   for index, value in pairs(minutes) do
      if value > max then max, max_index = value, index end
   end
   return max_index, max
end

function max_sleeping_guard(guards)
   local max_gid, minutes_slept = nil, 0
   for gid, values in pairs(guards) do
      if values["total"] > minutes_slept then max_gid, minutes_slept = gid, values["total"] end
   end
   return max_gid
end

function sort(left, right)
   return left["time"] < right["time"]
end

-- Actual script follows here

records = {}
guards = {}

for line in io.lines(input) do
   local new_record = parse_line_to_record(line)
   table.insert(records, new_record)
   local gid = get_guard_id_or_nil(new_record["message"])
   if gid ~= nil then
      guards[gid] = { minutes = {}; total = 0 }
   end
end

table.sort(records, sort)
collect_sleeping(records)

sleepy_gid = max_sleeping_guard(guards)
adjusted_max_minute = max_minute(guards[sleepy_gid]["minutes"])
print("Part 1 answer: " .. sleepy_gid * adjusted_max_minute)

-- Chew up the results to solve part 2
local m_minute, max_gid, max_count = 0, 0, 0
for gid, value in pairs(guards) do
   local minute, count = max_minute(value["minutes"])
   if count > max_count then
      m_minute = minute
      max_gid = gid
      max_count = count
   end
end
print("Part 2 answer: " .. max_gid * m_minute)
