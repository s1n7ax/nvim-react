local class = require('react.util.class')

--- @class React.Stack
--- @field private stack any[]
local M = class()

function M:_init()
	self.stack = {}
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
