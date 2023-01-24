local Stack = require('react.util.stack')
local Set = require('react.util.set')
local Event = require('react.util.event')
local EffectEvents = require('react.core.effect-events')

local errors = require('react.core.effect-error-messages')
local log = require('react.util.log')

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

function M:is_first_render()
	return self.first_render
end

function M:get_signal()
	log.debug('returning existing signal for the pointer', self.signal_pointer)

	if self:is_first_render() then
		return
	end

	local signal = self.signals:get(self.signal_pointer)

	debug.traceback()
	assert(signal, errors.INVALID_SIGNAL_CREATION)

	self.signal_pointer = self.signal_pointer + 1

	return signal
end

function M:add_signal(signal)
	self.signals:add(signal)
end

function M:remove_signal(signal)
	self.signals:remove_by_value(signal)
end

function M:unsubscribe_signals()
	for _, signal in self.signals:iter() do
		signal:remove_effect(self)
	end

	self.signals:remove_all()
end

function M:dispatch()
	self.callback()
end

function M:signal_retrieve_validation()
	assert(
		(self.signal_pointer - 1) == self.signals:length(),
		errors.INVALID_SIGNAL_CREATION
	)
end

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
