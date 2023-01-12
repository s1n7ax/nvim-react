local List = require('react.util.list')

local M = List:new()

function M:add(value)
	if self:has(value) then
		return false
	end

	table.insert(self.list, value)

	return true
end

return M
