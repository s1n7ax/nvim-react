local Effect = require('react.core.effect')
local Signal = require('react.core.signal')

local M = {}

function M.create_effect(callback)
	local effect = Effect:new(callback)

	effect:dispatch()

	return effect
end

function M.create_signal(value)
	local signal = Signal:new(value)

	local read = function()
		return signal:read()
	end

	local write = function(new_value)
		signal:write(new_value)
	end

	return read, write
end

return M
