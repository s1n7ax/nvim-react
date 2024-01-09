return function(opt)
	local by = opt and opt.by or 1

	local count = 0

	return function()
		local prev_count = count
		count = count + by
		return prev_count
	end, function()
		return count
	end
end
