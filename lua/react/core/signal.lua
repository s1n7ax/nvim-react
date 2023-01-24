local Effect = require('react.core.effect')
local Publisher = require('react.util.publisher')
local log = require('react.util.log')

local M = {}

function M:new(value)
	local effect = Effect.context:pointer()

	-- IF there is an effect and if next render it not first render of the effect then
	-- the signals should be extracted from the effect without creating new
	-- signals
	if effect and not (effect:is_first_render()) then
		log.debug('requesting existing signal from effect')
		return effect:get_signal()
	end

	log.debug('creating signal with initial value:: ', value)

	local o = {
		value = value,
		publisher = Publisher:new(),
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

function M:read()
	log.debug('reading signal value', self:get_value())
	local effect = Effect.context:pointer()

	if effect and effect:is_first_render() then
		log.debug('registering reader effect')
		self:add_effect(effect)
		effect:add_signal(self)
	end

	return self:get_value()
end

function M:write(value)
	self:set_value(value)
	self.publisher:dispatch()
end

function M:get_value()
	return self.value
end

function M:set_value(value)
	self.value = value
end

function M:add_effect(effect)
	self.publisher:add(effect)
end

function M:remove_effect(effect)
	self.publisher:remove_by_value(effect)
end

return M
