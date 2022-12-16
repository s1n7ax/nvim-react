---@diagnostic disable: undefined-global
local Stack = require('react.util.stack')
local Publisher = require('react.util.publisher')

local M = {
    effect_context = Stack:new()
}

function M.create_effect(callback)
    local execute

    execute = function()
        M.effect_context:push(execute)

        callback()

        M.effect_context:pop()
    end

    execute()

    -- Returns the destruct function
    return function ()

    end
end

function M.create_signal(value)
    local publisher = Publisher:new()

    local read = function()
        local point = M.effect_context:pointer()

        if point then
            publisher:add(point)
        end

        return value
    end

    local write = function(new_value)
        value = new_value

        publisher:dispatch()
    end

    return read, write
end

return M
