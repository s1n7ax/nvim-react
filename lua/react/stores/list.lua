local core = require('react.core')
local Publisher = require('react.util.publisher')

local Context = core.context

local M = {
	list = {},
	publisher = Publisher:new()
}

function M:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function M:push(value)
	table.insert(self.list, value)
	self.publisher:dispatch()
end

function M:get(index)
	self:reg_subscriber()
	return self.list[index]
end

function M:delete(index)
	table.remove(self.list, index)
	self.publisher:dispatch()
end

function M:iter()
	self:reg_subscriber()
	return ipairs(self.list)
end

function M:reg_subscriber()
	local point = Context:pointer()

	if point then
		self.publisher:add(point)
	end
end

return M
