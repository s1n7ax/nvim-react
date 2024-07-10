local class = require('react.util.class')
local Effect = require('react.core.effect')
local Publisher = require('react.util.publisher')
local log = require('react.util.log')

--- @class react.Signal
--- @field private value table value of the store
--- @field private publisher Publisher
local Signal = class()

function Signal:_init(value)
	local effect = Effect.context:pointer()

	-- IF there is an effect and if next render it not first render of the effect then
	-- the signals should be extracted from the effect without creating new
	-- signals
	if effect and not (effect:is_first_render()) then
		log.debug('requesting existing signal from effect')
		return effect:get_signal()
	end

	log.debug('creating signal with initial value:: ', value)

	self.value = value
	self.publisher = Publisher:new()
end

--- Returns the signal value
--- IF the signal is being read inside an effect, effect will be registered in
--- signal and vice versa
--- @public
--- @returns any signal value
function Signal:read()
	log.debug('reading signal value', self:get_value())
	local effect = Effect.context:pointer()

	if effect and effect:is_first_render() then
		log.debug('registering reader effect')
		self:add_effect(effect)
		effect:add_signal(self)
	end

	return self:get_value()
end

--- Sets the signal value
--- ON write, publisher will re-call all the effects registered for this signal
--- @param value any value to set to signal
function Signal:write(value)
	self:set_value(value)
	self.publisher:dispatch()
end

--- Returns the current value
--- @returns any
function Signal:get_value()
	return self.value
end

--- Sets the current value
--- @param value any
function Signal:set_value(value)
	self.value = value
end

--- Add an effect to the signal
--- @param effect react.Effect effect
function Signal:add_effect(effect)
	self.publisher:add(effect)
end

--- Removes an effect registered in this signal
--- @param effect react.Effect
function Signal:remove_effect(effect)
	self.publisher:remove_by_value(effect)
end

return Signal
