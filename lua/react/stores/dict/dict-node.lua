local Effect = require('react.core.effect')
local List = require('react.util.list')
local helper = require('react.stores.dict.helper')

local M = {}

function M:new(o)
	--[[
	-- @TODO https://github.com/s1n7ax/nvim-react/issues/2
	--]]
	assert(
		Effect.context:is_empty(),
		[[Creating signals or stores within an effect or component is not yet supported
		https://github.com/s1n7ax/nvim-react/issues/2]]
	)

	assert(o.publishers, 'o.publishers should be passed')
	assert(o.value, 'o.value should be passed')

	local obj = setmetatable({}, {
		publishers = o.publishers,
		value = o.value,
		path = o.path or List:new(),
		curr_publishers_node = o.curr_publisher_node or o.publishers,

		__index = self.index,
		__newindex = self.newindex,
	})

	return obj
end

function M.index(self, key)
	local metatable = getmetatable(self)

	-- meta table info
	local publishers = metatable.publishers
	local value = metatable.value
	local parent_path = metatable.path

	local curr_path = helper.get_curr_path_by_key(parent_path, key)
	local curr_pub_node = helper.publisher_path_traversal(publishers, curr_path)
	local indexed_value = value[key]

	-- if there is an effect, add effect to store, and store to effect
	local effect = Effect.context:pointer()

	if effect then
		-- add(effect) --> store
		local effect_added = curr_pub_node.effects:add(effect)

		-- only adds the signal once
		-- this is to avoid duplicate signals being added to effects

		if effect_added then
			-- add(store) --> effect
			effect:add_signal({
				remove_effect = function(_, effect_to_remove)
					curr_pub_node.effects:remove_by_value(effect_to_remove)
				end,
			})
		end
	end

	-- if the next value is a table then create new object of dict
	if type(indexed_value) == 'table' then
		return M:new({
			publishers = publishers,
			value = indexed_value,
			path = curr_path,
			curr_publisher_node = curr_pub_node,
		})
	end

	return value
end

function M.newindex(self, key, new_value)
	local metatable = getmetatable(self)
	local value = metatable.value

	-- meta table info
	local curr_pub_node = metatable.curr_publishers_node

	-- change the value in the store
	value[key] = new_value

	-- dispatch effects under the current publisher node including itself
	-- after that, this removes the children nodes from the publishers map since
	-- they are no longer valid
	helper.dispatch_and_remove_children(curr_pub_node.children[key])
end

return M
