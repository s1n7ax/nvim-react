--- @class Stack
--- @field private stack any[]
local M = {}

function M:new()
	local o = { stack = {} }

	setmetatable(o, self)
	self.__index = self

	return o
end

--- Adds a new value to the stack
--- @param value any value to push to the stack
function M:push(value)
	table.insert(self.stack, value)
end

--- Removes the last value from the stack
--- @returns nil
function M:pop()
	table.remove(self.stack)
end

--- Returns the current pointer of the stack
--- @returns number pointer of the stack
function M:pointer()
	return self.stack[#self.stack]
end

--- Returns whether the stack is empty or not
--- @returns boolean whether the stack is empty or not
function M:is_empty()
	return #self.stack == 0
end

return M
