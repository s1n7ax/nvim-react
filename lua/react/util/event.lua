local Set = require('react.util.set')

--- @class Event
--- @field private listeners_map table<string, Set>
local M = {}

function M:new()
	local o = {
		listeners_map = {},
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

--- Add a listener function to a given event
--- @param event string event type to listen
--- @param listener function callback function
--- @param opt nil|{once: boolean} additional options
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

--- Remove existing listener from the listeners list for given event
--- @param event string name of the event
--- @param listener function callback function to remove
function M:remove_listener(event, listener)
	self.listeners_map[event]:remove_by_value(listener)
end

--- Dispatches an event to all the listeners for a given type of event
--- @param event string type of the event to dispatch
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
