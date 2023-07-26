local AbsoluteLineTask = require("nvim_training.tasks.absolute_line")
local RelativeLineTask = require("nvim_training.tasks.relative_line")
local MoveMarkTask = require("nvim_training.tasks.move_mark")
local WordForwardMovementTask = require("nvim_training.tasks.word_forward_movement")
local BufferPermutationTask = require("nvim_training.tasks.buffer_permutation")
local OpenWindowTask = require("nvim_training.tasks.open_window")
local CloseWindowTask = require("nvim_training.tasks.close_window")

local utility = require("nvim_training.utility")

local total_task_pool = { OpenWindowTask, CloseWindowTask }

local included_tags = { "movement" }
local included_tags = { "ui" }
local excluded_tags = { "abc" }

local TaskSequence = {}
TaskSequence.__index = TaskSequence

function TaskSequence:new()
	--Task index starts at 0 to deal with first task initialisation
	local base = { task_index = 0, current_level = 1, status_list = {} }
	setmetatable(base, { __index = self })

	--Todo: Rework with next tasks in mind
	local sequence_length = 15

	local current_task_pool = {}
	for key, el in pairs(total_task_pool) do
		local allowed_intersection = utility.intersection(el.base_args.tags, included_tags)
		local forbidden_intersection = utility.intersection(el.base_args.tags, excluded_tags)
		if #allowed_intersection > 0 and #forbidden_intersection == 0 then
			table.insert(current_task_pool, el)
		end
	end
	local current_task_pool = total_task_pool

	base.task_sequence = {}
	for i = 1, sequence_length do
		local current_next_task = current_task_pool[math.random(#current_task_pool)]:new()
		while current_next_task:first() do
			local attempt_to_find_next_task = current_next_task:first()
			if attempt_to_find_next_task then
				current_next_task = attempt_to_find_next_task:new()
			end
		end
		base.task_sequence[i] = current_next_task
		while current_next_task:next() do
			local next_task = current_next_task:next():new()
			i = i + 1
			base.task_sequence[i] = next_task
			current_next_task = next_task
		end
	end
	base.task_sequence = { AbsoluteLineTask:new(), AbsoluteLineTask:new(), AbsoluteLineTask:new() }

	return base
end

function TaskSequence:complete_current_task()
	self.status_list[#self.status_list + 1] = true

	if self.current_task then
		self.current_task:teardown()
	end
end

function TaskSequence:fail_current_task()
	self.status_list[#self.status_list + 1] = false
	if self.current_task then
		self.current_task:teardown()
	end
end

function TaskSequence:switch_to_next_task()
	self.task_index = self.task_index + 1
	self.current_task = self.task_sequence[self.task_index]
	self.current_task:prepare()
end

function TaskSequence:print()
	local task_list_str = ""
	for _, task_el in pairs(self.task_sequence) do
		task_list_str = task_list_str .. "\n" .. tostring(task_el.abr)
	end
	return task_list_str
end

return TaskSequence
