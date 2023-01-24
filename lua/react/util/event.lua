local Set = require('react.util.set')

local M = {}

function M:new()
	local o = {
		listeners_map = {},
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

function M:add_listener(event, listener, opt)
	if not self.listeners_map[event] then
		self.listeners_map[event] = Set:new()
	end

	if opt and not opt.once then
		self.listeners_map[event]:add(listener)
		return
	end

	local this = self

	self.listeners_map[event]:add(function(...)
		listener(...)
		this:remove_listener(event, listener)
	end)
end

function M:remove_listener(event, listener)
	self.listeners_map[event]:remove_by_value(listener)
end

function M:dispatch(event, ...)
	local info = {
		event = event,
	}

	if not self.listeners_map[event] then
		return
	end

	for _, listener in self.listeners_map[event]:iter() do
		listener(info, ...)
	end
end

return M
