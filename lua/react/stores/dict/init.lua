local Node = require('react.stores.dict.dict-node')
local Set = require('react.util.set')

--- @param init_value any initial value of the store
--- @returns DictNode
return function(init_value)
	local publishers = {
		effects = Set:new(),
		children = {},
	}

	return Node:new({
		value = init_value,
		publishers = publishers,
	})
end
