return function()
	local stack = {}

	local push = function(value)
		table.insert(stack, value)
	end

	local pop = function()
		table.remove(stack)
	end

	local pointer = function()
		return stack[#stack]
	end

	return {
		push = push,
		pop = pop,
		pointer = pointer,
	}
end
