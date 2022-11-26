---@diagnostic disable: undefined-global
local Stack = require('react.util.stack')
local Set = require('react.util.set')

local context = Stack()

local M = {}

function M.create_effect(callback)
    local execute

    execute = function()
        context.push(execute)

        callback()

        context.pop()
    end

    execute()
end

function M.create_signal(value)
    local subscribers = Set()

    local read = function()
        local point = context.pointer()

        if point then
            subscribers.add(point)
        end

        return value
    end

    local write = function(new_value)
        value = new_value

        for _, subscriber in subscribers.iter() do
            subscriber()
        end
    end

    return read, write
end

return M
