local class = require('react.util.class')
local Component = require('react.components.buffer-component')

--- @class react.BufferRenderer
--- @field buffer number id of the buffer BufferRenderer should manage
local BufferRenderer = class()

function BufferRenderer:_init(args)
	assert(
		args.buffer,
		[[A buffer should be passed to the renderer
		Ex:-

		buffer = vim.api.nvim_create_buf(true, true)

		Renderer({
			buffer = buffer
		})
	]]
	)

	self.buffer = args.buffer
end

--- Render the given root component
--- @param root function root functional component to render
function BufferRenderer:render(root)
	local function on_change(range, text)
		vim.schedule(function()
			vim.api.nvim_buf_set_text(
				self.buffer,
				range.row_start,
				range.col_start,
				range.row_end,
				range.col_end,
				BufferRenderer.__split_lines(text)
			)
		end)
	end

	local rc = Component({ component = root, subscriber = on_change })

	local lines = BufferRenderer.__split_lines(rc:get_text())

	vim.api.nvim_buf_set_lines(self.buffer, 0, -1, true, lines)
end

--- @private
--- Returns the split text by newlines
--- @param text string text to split
--- @returns string[]
function BufferRenderer.__split_lines(text)
	return vim.split(text, '\n')
end

return BufferRenderer
