--  local ListStore = require('react.stores.list')
local core = require('react.core')
local Render = require('react.renderers.buffer-renderer')
local uv = require("luv")

--  local store = ListStore:new()

local create_signal = core.create_signal


local count, set_count = create_signal(0)
local a, set_a = create_signal('A')
local b, set_b = create_signal('B')
local c, set_c = create_signal('C')

function A()
	print('Render A')

	return {
		a()
	}
end

function B()
	print('Render B')

	return {
		b()
	}
end

function C()
	print('Render C')

	return {
		c()
	}
end

function Root()
	if count() == 0 then
		return {
			A
		}
	end

	if count() == 1 then
		return {
			B
		}
	end

	if count() > 1 then
		return {
			C
		}
	end
end

local M = {}

local buffer = nil
local win = nil

function M.run()
	M.start()

	Render:new({
		buffer = buffer
	}):render(Root)

	M.set_timeout(1000, function()
		print('set count')
		set_count(0)
	end)

	--  M.set_timeout(2000, function()
		--  set_count(0)
	--  end)

	M.set_timeout(2000, function()
		print('change a')
		set_a('AA')
	end)

	M.stop()

end





function M.start()
	if not buffer or vim.api.nvim_buf_is_valid(buffer) then
		buffer = vim.api.nvim_create_buf(true, true)
	end

	win = vim.api.nvim_open_win(buffer, true, {
		relative = 'editor',
		width = 50,
		height = 30,
		row = 15,
		col = 100,
	})
end

function M.stop()
	M.set_timeout(5000, function()
		vim.schedule(function()
			vim.api.nvim_win_close(win, true)
		end)
	end)
end

function M.set_timeout(timeout, callback)
	local timer = uv.new_timer()
	local function ontimeout()
		uv.timer_stop(timer)
		uv.close(timer)
		callback()
	end

	uv.timer_start(timer, timeout, 0, ontimeout)
	return timer
end

return M
