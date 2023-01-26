--- @class List
--- @field protected list any[]
local M = {}

--- @param list any[] | nil
function M:new(list)
	local o = {
		list = list or {},
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

--- Returns the value at given index
--- @param index number index of the param
--- @returns any
function M:get(index)
	return self.list[index]
end

--- Sets the value at given index to given value
--- @param index number index to set the value at
--- @param value any value to set
function M:set(index, value)
	self.list[index] = value
	return 0
end

--- Returns an iterator of the list
--- @returns function
function M:iter()
	return ipairs(self.list)
end

--- Append new value to the list
--- @param value any value to append
function M:add(value)
	table.insert(self.list, value)
end

--- Remove existing value from the list by index
--- @param index number
--- @returns any value that got removed from the list
function M:remove(index)
	return table.remove(self.list, index)
end

--- Remove existing value from the list by the value
--- @param value any value to remove from the list
--- @returns any value that got removed from the list
function M:remove_by_value(value)
	local index = self:find_index(value)

	if index < 0 then
		return
	end

	table.remove(self.list, index)

	return index
end

--- Remove all the values from the list
function M:remove_all()
	self.list = {}
end

--- Returns the index of a given value if exists
--- Returns -1 if the value does not exist
--- @return number
function M:find_index(value)
	for index, ele in ipairs(self.list) do
		if ele == value then
			return index
		end
	end

	return -1
end

--- Returns true if the given value exists in the list
--- @param value any value to check the existence
--- @returns boolean
function M:has(value)
	for _, ele in ipairs(self.list) do
		if ele == value then
			return true
		end
	end

	return false
end

--- Returns the size of the list
--- @returns number size of the list
function M:length()
	return #self.list
end

--- Concatenate the given list to this list
--- @param list List | any[]
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

--- Returns a string after joining the list by given string separator
--- @param separator string separator to join the list with
--- @returns string joined string
function M:join(separator)
	return table.concat(self.list, separator)
end

--- Returns a clone of the current list
--- @returns List clone of the current list
function M:clone()
	return M:new(M.deepcopy(self.list))
end

--- @private
--- @param orig table original table to copy
--- @returns table clone of the table
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
