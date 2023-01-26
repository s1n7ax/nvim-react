local List = require('react.util.list')

--- @class Set: List
local M = List:new()

--- Append new value to the list only if it does not exist already
--- @param value any value to append
--- @returns boolean whether the value was added or not
function M:add(value)
	if self:has(value) then
		return false
	end

	table.insert(self.list, value)

	return true
end

return M
