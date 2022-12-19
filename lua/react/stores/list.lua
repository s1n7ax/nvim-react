local Publisher = require('react.util.publisher')
local Effect = require('react.core.effect')

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

function M:get(index)
	self:reg_subscriber()
	return self.list[index]
end

function M:length()
	self:reg_subscriber()
	return #self.list
end

function M:add(value)
	table.insert(self.list, value)
	self.publisher:dispatch()
end

function M:remove(index)
	table.remove(self.list, index)
	self.publisher:dispatch()
end

function M:iter()
	self:reg_subscriber()
	return ipairs(self.list)
end

function M:reg_subscriber()
	local effect = Effect.context:pointer()

	if effect then
		effect:add_signal(self)
		self.publisher:add(effect)
	end
end

function M:remove_effect(effect)
	self.publisher:remove_by_value(effect)
end

return M
