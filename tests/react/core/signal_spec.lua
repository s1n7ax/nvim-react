local Effect = require('react.core.effect')
local Signal = require('react.core.signal')

local counter = require('util.counter')

describe('signal::', function()
	it('correctly sets initial value', function()
		local num = Signal:new(10)
		assert.equal(10, num:read())

		local str = Signal:new('hello world')
		assert.equal('hello world', str:read())

		local bool = Signal:new(true)
		assert.equal(true, bool:read())

		local tbl = Signal:new({ name = 's1n7ax' })
		assert.same({ name = 's1n7ax' }, tbl:read())
	end)

	it('correctly changes the existing value', function()
		local signal = Signal:new(10)
		assert.same(10, signal:read())

		signal:write('hello world')
		assert.same('hello world', signal:read())

		signal:write(true)
		assert.same(true, signal:read())

		signal:write({ name = 's1n7ax' })
		assert.same({ name = 's1n7ax' }, signal:read())
	end)

	it('can be initialized outside effect', function()
		local signal = Signal:new(10)
		assert.equal(10, signal:read())
	end)

	it('can be initialized inside effect', function()
		local effect = Effect:new(function()
			local signal = Signal:new(10)
			assert(10, signal:read())
		end)

		effect:dispatch()
	end)

	it('does not register effect on read outside effect', function()
		local signal = Signal:new(10)
		signal:read()
		assert.equal(0, signal.publisher:length())
	end)

	it('register effect on read inside effect', function()
		Effect:new(function()
			local signal_1 = Signal:new(10)
			local signal_2 = Signal:new(10)
			local signal_3 = Signal:new(10)

			signal_1:read()
			signal_2:read()

			assert.equal(1, signal_1.publisher:length())
			assert.equal(1, signal_2.publisher:length())
			assert.equal(0, signal_3.publisher:length())
		end):dispatch()

		local signal_1 = Signal:new(10)
		local signal_2 = Signal:new(10)
		local signal_3 = Signal:new(10)
		Effect:new(function()
			signal_1:read()
			signal_2:read()

			assert.equal(1, signal_1.publisher:length())
			assert.equal(1, signal_2.publisher:length())
			assert.equal(0, signal_3.publisher:length())
		end):dispatch()
	end)

	it(
		'effect is registered only once when same signal is used multiple times',
		function()
			Effect:new(function()
				local signal = Signal:new(10)

				signal:read()
				signal:read()
				signal:read()

				assert.equal(1, signal.publisher:length())
			end):dispatch()

			local signal = Signal:new(10)
			Effect:new(function()
				signal:read()
				signal:read()
				signal:read()
			end):dispatch()
			assert.equal(1, signal.publisher:length())
		end
	)

	it('re-render the effect on write', function()
		local count, get_count = counter()
		local signal = Signal:new(10)

		Effect:new(function()
			signal:read()
			count()
		end):dispatch()

		assert.equal(1, get_count())

		signal:write(11)
		assert.equal(2, get_count())
	end)

	it('signal change is available in effect', function()
		local signal = Signal:new(10)
		local current_value = nil

		Effect:new(function()
			current_value = signal:read()
		end):dispatch()

		assert.same(10, current_value)

		signal:write('hello world')
		assert.same('hello world', current_value)

		signal:write(true)
		assert.same(true, current_value)

		signal:write({ name = 's1n7ax' })
		assert.same({ name = 's1n7ax' }, current_value)
	end)

	it('does not re-render when not used', function()
		local signal

		Effect:new(function()
			signal = Signal:new(10)
		end):dispatch()

		assert.equal(0, signal.publisher:length())
	end)

	it('signal returns the initially created signal on re-render', function()
		local signal_1, signal_2, signal_3

		Effect:new(function()
			signal_1 = Signal:new(10)
			signal_2 = Signal:new(20)
			signal_3 = Signal:new(30)
		end):dispatch()

		assert.same(10, signal_1:get_value())
		assert.same(20, signal_2:get_value())
		assert.same(30, signal_3:get_value())

		signal_1:write(signal_1:get_value() + 1)
		signal_2:write(signal_2:get_value() + 1)
		signal_3:write(signal_3:get_value() + 1)

		assert.same(11, signal_1:get_value())
		assert.same(21, signal_2:get_value())
		assert.same(31, signal_3:get_value())
	end)

	it('after unsubscribe, effect should be removed from signal', function()
		local signal_1 = Signal:new(10)
		local signal_2 = Signal:new(10)
		local render_count = 0

		local effect = Effect:new(function()
			signal_1:read()
			signal_2:read()

			render_count = render_count + 1
		end)
		effect:dispatch()

		assert.equal(1, render_count)

		signal_1:write(11)
		assert.equal(2, render_count)

		signal_2:write(11)
		assert.equal(3, render_count)

		effect:unsubscribe_signals()

		signal_1:write(12)
		signal_2:write(12)
		assert.equal(3, render_count)
	end)

	it('adds signal to the effect on use', function()
		local signal1 = Signal:new(10)
		local signal2 = Signal:new(10)

		local effect = Effect:new(function()
			signal1:read()
			signal2:read()
		end)

		effect:dispatch()

		assert.equal(2, effect.signals:length())
	end)
end)
