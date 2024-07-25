local class = require('react.util.class')
local Set = require('react.util.set')

---@class react.Publisher: react.Set
local Publisher = class(Set)

--- Dispatches an event to given list of subscribers
function Publisher:dispatch(...)
	for _, subscriber in ipairs(self.list) do
		subscriber:dispatch(...)
	end
end

return Publisher
