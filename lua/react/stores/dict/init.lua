local Node = require('react.stores.dict.dict-node')
local Set = require('react.util.set')

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
