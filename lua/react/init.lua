local core = require('react.core')
local Render = require('react.renderers.buffer-renderer')
local Timer = require('react.util.timer')
local AsciiNum = require('react.other.ascii-number')

local create_signal = core.create_signal

local time, set_time = create_signal(vim.split(os.date('%H-%M-%S'), '-'))

local function Root()
	local hour, min, sec = time()[1], time()[2], time()[3]

	local hour_str = AsciiNum.get_number(hour)
	local min_str = AsciiNum.get_number(min)
	local sec_str = AsciiNum.get_number(sec)

	local text = {}

	for i = 1, #hour_str do
		table.insert(
			text,
			string.format(
				'%s  |  %s  |  %s\n',
				hour_str[i],
				min_str[i],
				sec_str[i]
			)
		)
	end

	return text
end

local M = {}

local buffer, win

function M.run()
	Timer.set_interval({
		timeout = 10000,
		interval = 1000,

		on_repeat = function()
			set_time(vim.split(os.date('%H-%M-%S'), '-'))
		end,

		on_start = M.open_window,
		on_stop = M.close_window,
	})

	Render
		:new({
			buffer = buffer,
		})
		:render(Root)
end

function M.open_window()
	if not buffer or vim.api.nvim_buf_is_valid(buffer) then
		buffer = vim.api.nvim_create_buf(true, true)
	end

	win = vim.api.nvim_open_win(buffer, true, {
		relative = 'editor',
		width = 100,
		height = 20,
		row = 15,
		col = 20,
	})

	vim.api.nvim_win_set_option(win, 'cursorline', false)
	vim.api.nvim_win_set_option(win, 'cursorcolumn', false)
end

function M.close_window()
	vim.schedule(function()
		vim.api.nvim_win_close(win, true)
	end)
end

return M
