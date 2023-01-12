local Stack = require('react.util.stack')
local Set = require('react.util.set')

local M = {
	context = Stack:new(),
}

function M:new(callback)
	assert(
		callback and type(callback) == 'function',
		'Callback function should be passed to effect'
	)

	local o = nil

	o = {
		signals = Set:new(),
		callback = function()
			M.context:push(o)

			callback()

			M.context:pop(o)
		end,
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

function M:add_signal(signal)
	self.signals:add(signal)
end

function M:remove_signal(signal)
	self.signals:remove_by_value(signal)
end

function M:unsubscribe_signals()
	for _, signal in self.signals:iter() do
		signal:remove_effect(self)
	end

	self.signals:remove_all()
end

function M:dispatch()
	self.callback()
end

return M
