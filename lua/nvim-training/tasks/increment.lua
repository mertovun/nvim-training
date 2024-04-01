
local Task = require("nvim-training.task")
local utility = require("nvim-training.utility")
local internal_config = require("nvim-training.internal_config")

local Increment = {}
Increment.__index = Increment

function Increment:new()
	local base = Task:new()
	setmetatable(base, { __index = Increment })

	self.target_x = math.random(internal_config.header_length, internal_config.header_length + 5)
	self.target_y = math.random(5, 25)
	self.autocmd = "CursorMoved"
	local function _inner_update()
		utility.set_buffer_to_lorem_ipsum_and_place_cursor_randomly()
		self.highlight = utility.create_highlight(self.target_x, self.target_y, 1)
	end
	vim.schedule_wrap(_inner_update)()

	return base
end

function Increment:teardown(autocmd_callback_data)
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	return cursor_pos[1] == self.target_x + 1 and cursor_pos[2] == self.target_y
end

function Increment:description()
	return "Move to the random highlight"
end

return Increment
