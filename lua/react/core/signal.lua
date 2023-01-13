local Effect = require('react.core.effect')
local Publisher = require('react.util.publisher')

local M = {}

function M:new(value)
	--[[
	-- @TODO https://github.com/s1n7ax/nvim-react/issues/2
	--]]
	assert(
		Effect.context:is_empty(),
		[[Creating signals or stores within an effect or component is not yet supported
		https://github.com/s1n7ax/nvim-react/issues/2]]
	)

	local o = {
		value = value,
		publisher = Publisher:new(),
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

function M:read()
	local effect = Effect.context:pointer()

	if effect then
		effect:add_signal(self)
		self.publisher:add(effect)
	end

	return self.value
end

function M:write(value)
	self.value = value
	self.publisher:dispatch()
end

function M:remove_effect(effect)
	self.publisher:remove_by_value(effect)
end

return M
