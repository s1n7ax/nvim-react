return function()
    local list = {}

    local M = {}

    M.iter = function()
        return ipairs(list)
    end

    M.add = function(value)
        if M.has(value) then
            return false
        end

        table.insert(list, value)

        return true
    end

    M.remove = function(index)
        return table.remove(list, index)
    end

    M.remove_value = function(value)
        local index = M.find_index(value)

        if index < 0 then
            return
        end

        table.remove(list, index)

        return index
    end

    M.find_index = function(value)
        for index, ele in ipairs(list) do
            if ele == value then
                return index
            end
        end

        return -1
    end

    M.has = function(value)
        for _, ele in ipairs(list) do
            if ele == value then
                return true
            end
        end

        return false
    end

    M.get = function(index)
        return list[index]
    end

    M.set = function(index, value)
        list[index] = value
    end

    M.pop = function()
        table.remove(list)
    end

    return M
end
