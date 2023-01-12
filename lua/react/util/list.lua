local M = {}

function M:new(list)
	local o = {
		list = list or {},
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

function M:get(index)
	return self.list[index]
end

function M:set(index, value)
	self.list[index] = value
end

function M:iter()
	return ipairs(self.list)
end

function M:add(value)
	table.insert(self.list, value)
end

function M:remove(index)
	return table.remove(self.list, index)
end

function M:remove_by_value(value)
	local index = self:find_index(value)

	if index < 0 then
		return
	end

	table.remove(self.list, index)

	return index
end

function M:remove_all()
	self.list = {}
end

function M:find_index(value)
	for index, ele in ipairs(self.list) do
		if ele == value then
			return index
		end
	end

	return -1
end

function M:has(value)
	for _, ele in ipairs(self.list) do
		if ele == value then
			return true
		end
	end

	return false
end

function M:length()
	return #self.list
end

function M:concat(list)
	if list.iter then
		for _, v in list:iter() do
			self:add(v)
		end
	else
		for _, v in ipairs(list) do
			self:add(v)
		end
	end
end

function M:join(sep)
	return table.concat(self.list, sep)
end

function M:clone()
	return M:new(M.deepcopy(self.list))
end

function M.deepcopy(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[M.deepcopy(orig_key, copies)] = M.deepcopy(
					orig_value,
					copies
				)
			end
			--  setmetatable(copy, M.deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

return M
