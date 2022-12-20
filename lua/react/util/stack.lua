local M = {}

function M:new()
	local o = { stack = {} }

	setmetatable(o, self)
	self.__index = self

	return o
end

function M:push(value)
	table.insert(self.stack, value)
end

function M:pop()
	table.remove(self.stack)
end

function M:pointer()
	return self.stack[#self.stack]
end

function M:is_empty()
	return #self.stack == 0
end

return M
