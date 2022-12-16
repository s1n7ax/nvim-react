local Set = require('react.util.set')

local M = Set:new()

function M:dispatch(...)
    for _, subscriber in ipairs(self.list) do
        subscriber(...)
    end
end

return M
