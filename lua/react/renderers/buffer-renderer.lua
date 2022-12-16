local Component = require('react.components.buffer-component')

local M = {}

function M:new(o)
    o = o or {
        buffer = 0
    }

    assert(o.buffer, [[A buffer should be passed to the renderer
        Ex:-

        buffer = vim.api.nvim_create_buf(true, true)

        Renderer:new({
            buffer = buffer
        })
    ]])

    setmetatable(o, self)
    self.__index = self

    return o
end

function M:render(root)
    local function on_change(range, text)
        vim.schedule(function()
            vim.api.nvim_buf_set_text(
                self.buffer,
                range.row_start,
                range.col_start,
                range.row_end,
                range.col_end,
                M.__split_lines(text)
            )
        end)
    end

    local rc = Component:new({ component = root, subscriber = on_change })

    local lines = M.__split_lines(rc:get_text())

    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, true, lines)
end

function M.__split_lines(text)
    return vim.split(text, '\n')
end

return M
