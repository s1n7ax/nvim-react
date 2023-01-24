local Effect = require('react.core.effect')
local Stack = require('react.util.stack')

local core = require('react.core')
local counter = require('tests.util.counter')
local errors = require('react.core.effect-error-messages')

local create_signal = core.create_signal

describe('effect::', function()
	before_each(function()
		Effect.context = Stack:new()
	end)

	it('throws when callback function is not passed', function()
		assert.has_error(function()
			Effect:new('hello')
		end)

		assert.has_error(function()
			Effect:new()
		end)

		assert.error_matches(function()
			Effect:new()
		end, 'Callback function should be passed to effect')
	end)

	it('callback runs on dispatch', function()
		local count_render, get_count = counter()

		local effect = Effect:new(function()
			count_render()
		end)

		effect:dispatch()

		assert.equal(1, get_count())
	end)

	it('adds effect/effects to the context in the correct order', function()
		local effect_1, effect_2, effect_3

		effect_1 = Effect:new(function()
			assert.same(1, #Effect.context.stack)
			assert.same(effect_1, Effect.context.stack[1])

			effect_2 = Effect:new(function()
				assert.same(2, #Effect.context.stack)
				assert.same(effect_1, Effect.context.stack[1])
				assert.same(effect_2, Effect.context.stack[2])

				effect_3 = Effect:new(function()
					assert.same(3, #Effect.context.stack)
					assert.same(effect_1, Effect.context.stack[1])
					assert.same(effect_2, Effect.context.stack[2])
					assert.same(effect_3, Effect.context.stack[3])
				end)

				effect_3:dispatch()
			end)

			effect_2:dispatch()
		end)

		effect_1:dispatch()
	end)

	it('first render status should be true on the initial render', function()
		local signal, set_signal = create_signal(0)
		local effect
		local expected_first_time = true

		effect = Effect:new(function()
			local _ = signal()
			assert.equal(expected_first_time, effect.first_render)
		end)


		effect:dispatch()

		expected_first_time = false
		assert.equal(expected_first_time, effect.first_render)

		set_signal(1)
		assert.equal(expected_first_time, effect.first_render)
	end)

	it('effect increases the pointer on signal request', function()
		local effect
		local signal_1, signal_2

		local expected_signal_pointer = 1

		effect = Effect:new(function()
			signal_1 = create_signal(0)
			signal_2 = create_signal(0)

			signal_1()
			signal_2()

			assert.equal(expected_signal_pointer, effect.signal_pointer)
		end)

		effect:dispatch()

		expected_signal_pointer = 3
		effect:dispatch()
	end)

	it('throws when requesting more signals than registered', function()
		local count_render, get_count = counter()

		local effect = Effect:new(function()
			local _ = create_signal(0)
			local _ = create_signal(0)
			local _ = create_signal(0)

			--  on the re-render, this requests a new signal
			if get_count() > 1 then
				local _ = create_signal(0)
			end

			count_render()
		end)

		effect:dispatch()

		assert.error_matches(function()
			effect:dispatch()
		end, errors.INVALID_SIGNAL_CREATION)
	end)

	it('unsubscribes signals from effect', function()
		local signal1 = create_signal(1)
		local signal2 = create_signal(1)
		local signal3 = create_signal(1)

		local effect = Effect:new(function()
			signal1()
			signal2()
			signal3()
		end)

		effect:dispatch()

		assert.equal(3, effect.signals:length())

		effect:unsubscribe_signals()
		assert.equal(0, effect.signals:length())
	end)
end)
