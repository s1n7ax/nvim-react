local Stack = require('react.util.stack')
local Set = require('react.util.set')
local Event = require('react.util.event')
local EffectEvents = require('react.core.effect-events')

local errors = require('react.core.effect-error-messages')
local log = require('react.util.log')

--- @class Effect
--- @field private first_render boolean true until first render is completed
--- @field private signals Set holds all the signals associated with this effect
--- @field private signal_pointer number a signal can request previously created signals from the
--- effect. When a signal is requested, the pointer will be incremented.
--- @field private events Event event object to handle events within the effect
--- @field private callback function to be called on an render/re-render event
local M = {
	context = Stack:new(),
}

function M:new(callback)
	log.debug('creating new effect')

	assert(
		callback and type(callback) == 'function',
		'Callback function should be passed to effect'
	)

	local o = {}
	setmetatable(o, self)
	self.__index = self

	local context_push_callback = function()
		o.events:dispatch(EffectEvents.BEFORE_RENDER)

		M.context:push(o)
		callback()
		M.context:pop(o)

		o.events:dispatch(EffectEvents.AFTER_RENDER)
	end

	o.first_render = true
	o.signals = Set:new()
	o.signal_pointer = 1
	o.events = Event:new()

	-- wrap the callback only for the first render to identify the initial
	-- render
	---@diagnostic disable-next-line: duplicate-set-field
	o.callback = function()
		o.events:dispatch(EffectEvents.BEFORE_INIT_RENDER)
		context_push_callback()
		o.events:dispatch(EffectEvents.AFTER_INIT_RENDER)

		---@diagnostic disable-next-line: duplicate-set-field
		o.callback = function()
			o.events:dispatch(EffectEvents.BEFORE_RE_RENDER)
			context_push_callback()
			o.events:dispatch(EffectEvents.AFTER_RE_RENDER)
		end
	end

	o:register_default_ev_callbacks()

	return o
end

--- Returns true if the first render is not yet completed
--- IF the current render is a re-render, false will be returned
--- @returns boolean
function M:is_first_render()
	return self.first_render
end

--- Returns a previously registered signal in the effect
---
--- ------- IF Effect.context:pointer() == self THEN -------
--- In the initial render of an effect, signals will be created. However, when
--- it's being re-rendered due to for instance, a signal change, a new signal should
--- NOT be created. This behaviour is similar to react hooks. This function
--- keeps track of previously requested signals using a hook such as
--- create_signal and returns the EXACT signal created by that particular hook
---
--- Only way effect guarantees that it's returning the correct hook is by the
--- order of they were created in the initial render. Hens, you should never
--- define hooks in conditions or any way that it might change the order or the
--- total number of hooks created while in the context of the effect
---
--- ------- IF Effect.context:pointer() == nil THEN -------
--- If you are not inside of an effect, then you can train an CV model to find
--- the side of the coin flip and you can choose to create or to not create
--- based on the coin flip. No one cares.
function M:get_signal()
	log.debug('returning existing signal for the pointer', self.signal_pointer)

	if self:is_first_render() then
		log.error(errors.INVALID_SIGNAL_REQUEST_STATE)
		error(errors.INVALID_SIGNAL_REQUEST_STATE)
	end

	local signal = self.signals:get(self.signal_pointer)

	assert(signal, errors.INVALID_SIGNAL_CREATION)

	self.signal_pointer = self.signal_pointer + 1

	return signal
end

--- Add a signal to this effect
--- @param signal any signal to register
function M:add_signal(signal)
	self.signals:add(signal)
end

--- Removes a signal
--- @param signal any removes the given signal from the effect
function M:remove_signal(signal)
	self.signals:remove_by_value(signal)
end

--- Removes all signals from the effect and call remove_effect in the signal
function M:unsubscribe_signals()
	for _, signal in self.signals:iter() do
		signal:remove_effect(self)
	end

	self.signals:remove_all()
end

--- Calls effect callback
function M:dispatch()
	self.callback()
end

--- Validates that the callback has NO hooks that request signals more or less than
--- initial re-render
function M:signal_retrieve_validation()
	assert(
		(self.signal_pointer - 1) == self.signals:length(),
		errors.INVALID_SIGNAL_CREATION
	)
end

--- Register the default lifecycle events that belongs to Effects
function M:register_default_ev_callbacks()
	self.events:add_listener(EffectEvents.BEFORE_RE_RENDER, function()
		self.signal_pointer = 1
	end)

	self.events:add_listener(EffectEvents.AFTER_INIT_RENDER, function()
		self.first_render = false
	end, { once = true })

	--  self.events:add_listener(EffectEvents.AFTER_RE_RENDER, function()
	--  M:signal_retrieve_validation()
	--  end)
end

return M
