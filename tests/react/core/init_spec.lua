local Effect = require('react.core.effect')

local counter = require('util.counter')
local core = require('react.core')

local create_signal = core.create_signal
local create_effect = core.create_effect

describe('core::', function()
	describe('signal::', function()
		it('create_signal should return read and write function', function()
			local signal, set_signal = create_signal(10)
			assert('function', type(signal))
			assert('function', type(set_signal))
		end)

		it('read function should return the value', function()
			local signal = create_signal(10)
			assert(10, signal)
		end)

		it('write function should update the value', function()
			local signal, set_signal = create_signal(10)
			assert(10, signal)

			set_signal(20)
			assert(20, signal)
		end)
	end)

	describe('effect::', function()
		it('should trigger the initial render on creation', function()
			local count, get_count = counter()

			create_effect(function()
				count()
			end)

			assert.equal(1, get_count())
		end)

		it('should return the effect on creation', function()
			local effect = create_effect(function() end)

			assert.is_true(getmetatable(effect) == Effect)
		end)
	end)
end)
