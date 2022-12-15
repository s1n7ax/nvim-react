---@diagnostic disable: undefined-global
local Component = require('react.component')

local function split_lines(text)
    local lines = {}

    for str in string.gmatch(text, "([^\n]+)") do
        table.insert(lines, str)
    end

    return lines
end

function Render(buffer, root)

    local function on_change(range, content)
        vim.schedule(function()
            vim.api.nvim_buf_set_text(
                buffer,
                range.row_start,
                range.col_start,
                range.row_end,
                range.col_end,
                split_lines(content)
            )
        end)
    end

    local rc = Component:new({ component = root, subscriber = on_change })

    local lines = split_lines(rc:get_text())

    vim.api.nvim_buf_set_lines(buffer, 0, 0, true, lines)
end

return Render
