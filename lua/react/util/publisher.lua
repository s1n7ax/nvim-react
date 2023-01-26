local Set = require('react.util.set')

---@class Publisher: Set
local M = Set:new()

--- Dispatches an event to given list of subscribers
function M:dispatch(...)
	for _, subscriber in ipairs(self.list) do
		subscriber:dispatch(...)
	end
end

return M
