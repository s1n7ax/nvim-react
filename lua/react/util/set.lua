local M = {}

function M:new(list)
    local o = {
        list = list or {}
    }

    setmetatable(o, self)
    self.__index = self

    return o
end

function M:iter()
    return ipairs(self.list)
end

function M:add(value)
    if self:has(value) then
        return false
    end

    table.insert(self.list, value)

    return true
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

function M:get(index)
    return self.list[index]
end

function M:set(index, value)
    self.list[index] = value
end

function M:pop()
    table.remove(self.list)
end

function M:lenght()
    return #self.list
end

return M
