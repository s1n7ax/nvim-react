local uv = require('luv')

local M = {}

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

function M.set_interval(args)
	local timeout = args.timeout
	local interval = args.interval
	local on_repeat = args.on_repeat
	local on_stop = args.on_stop
	local on_start = args.on_start

	local timer = uv.new_timer()

	M.set_timeout(timeout, function()
		uv.timer_stop(timer)
		uv.close(timer)
		on_stop()
	end)

	local function ontimeout()
		on_repeat()
	end

	on_start()
	uv.timer_start(timer, 0, interval, ontimeout)
	return timer
end

return M
