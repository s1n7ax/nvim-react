local core = require('react.core')
local create_dict = require('react.stores.dict')
local counter = require('tests.util.counter')

local create_effect = core.create_effect

describe('stores::', function()
	describe('dict::', function()
		local init_value

		before_each(function()
			init_value = {
				user_info = {
					basic_info = {
						name = 's1n7ax',
						age = 30,
						address = 'Colombo, Sri Lanka'
					},
					employee_info = {
						id = '0000000001',
						designation = 'Full Stack Developer'
					}
				}
			}
		end)

		it('store should not be allowed to created inside an effect', function()
			create_effect(function()
				assert.has_error(function()
					create_dict({})
				end)

				assert.error_matches(function()
					create_dict({})
				end, 'Store can not be created inside an effect or component')
			end)
		end)

		it('initial value should be stored in the store', function()
			local store = create_dict(init_value)

			assert.equal(init_value, getmetatable(store).value)
		end)

		it('path traversal should return the correct value', function()
			local store = create_dict(init_value)

			assert.equal(
				init_value.user_info,
				getmetatable(store.user_info).value
			)
			assert.equal(
				init_value.user_info.basic_info,
				getmetatable(store.user_info.basic_info).value
			)

			assert.equal(
				init_value.user_info.basic_info.name,
				store.user_info.basic_info.name
			)
		end)

		it('re-render on update of a primitive value in the store', function()
			local store = create_dict(init_value)
			local name
			local count, get_count = counter()

			create_effect(function()
				count()
				name = store.user_info.basic_info.name
			end)

			assert.equal(1, get_count())
			assert.equal('s1n7ax', name)

			store.user_info.basic_info.name = 'changed'
			assert.equal(2, get_count())
			assert.equal('changed', name)
		end)

		it('re-renders on update of an object value in the store', function()
			local store = create_dict(init_value)
			local curr_basic_info
			local count, get_count = counter()

			create_effect(function()
				count()
				curr_basic_info = store.user_info.basic_info
			end)

			assert.equal(1, get_count())
			assert.equal(init_value.user_info.basic_info, getmetatable(curr_basic_info).value)

			store.user_info.basic_info = 'changed'
			assert.equal(2, get_count())
			assert.equal('changed', curr_basic_info)
		end)
	end)
end)
