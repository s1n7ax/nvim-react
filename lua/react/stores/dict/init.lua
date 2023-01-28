local Effect = require('react.core.effect')
local Node = require('react.stores.dict.dict-node')
local Set = require('react.util.set')

--- @param init_value any initial value of the store
--- @returns DictNode
return function(init_value)
	assert(Effect.context:is_empty(), 'Store can not be created inside an effect or component')

	local publishers = {
		effects = Set:new(),
		children = {},
	}

	return Node:new({
		value = init_value,
		publishers = publishers,
	})
end
