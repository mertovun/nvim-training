-- luacheck: globals vim

local Task = require("nvim_training.task")

local MoveRandomXYTask = Task:new()
local utility = require("nvim_training.utility")

MoveRandomXYTask.base_args = { tags = { "movement", "line_based" }, autocmds = { "CursorMoved" } }

local TestMovement = require("lua.nvim_training.movements.test_movement")
function MoveRandomXYTask:prepare()
	self:load_from_json("lorem_ipsum.buffer")
	utility.replace_main_buffer_with_str(self.initial_buffer)

	self.movement = TestMovement:new()

	self.new_buffer_coordinates = self.movement:calculate_cursor_x_y()

	self.desc = "Jump to line " .. self.new_buffer_coordinates[1] .. " and char " .. self.new_buffer_coordinates[2]

	self.desc = "Move to line " .. self.new_buffer_coordinates[1] .. "and " .. self.new_buffer_coordinates[2]

	local first_highlight =
		utility.create_highlights(self.new_buffer_coordinates[1] - 1, self.new_buffer_coordinates[2], 1)
	local second_highlight =
		utility.create_highlights(self.new_buffer_coordinates[1] - 1, 0, self.new_buffer_coordinates[2] - 1)

	local new_buffer_lines =
		vim.api.nvim_buf_get_lines(0, self.new_buffer_coordinates[1], self.new_buffer_coordinates[1] + 1, false)
	local line_length = #new_buffer_lines[1]
	local third_highlight = utility.create_highlights(
		self.new_buffer_coordinates[1] - 1,
		self.new_buffer_coordinates[2] + 2,
		line_length + 1
	)
	self.highlights = { first_highlight, second_highlight, third_highlight }
end

function MoveRandomXYTask:completed()
	local current_cursor = vim.api.nvim_win_get_cursor(0)
	local x_diff = current_cursor[1] - self.new_buffer_coordinates[1]
	local y_diff = current_cursor[2] - self.new_buffer_coordinates[2]
	return x_diff == 0 and y_diff == 0
end

function MoveRandomXYTask:failed()
	return not self:completed()
end

function MoveRandomXYTask:teardown()
	for i, v in self.highlights do
		utility.clear_highlight(v)
	end
end

return MoveRandomXYTask
