local class = require('react.util.class')
local Set = require('react.util.set')
local Publisher = require('react.util.publisher')
local Effect = require('react.core.effect')

local M = class()

M.list = Set()
M.element_publishers = Set()
M.publisher = Publisher()

function M:get(index)
	self:reg_subscriber()
	return self.list:get(index)
end

function M:add(value)
	self.list:add(value)
	self.publisher:dispatch()
end

function M:remove(index)
	self.list:remove(index)
	self.publisher:dispatch()
end

function M:iter()
	self:reg_subscriber()
	return self.list:iter()
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

function M:length()
	self:reg_subscriber()
	return self.list:length()
end

return M
