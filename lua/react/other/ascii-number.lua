local M = {
	-- editorconfig-checker-disable
	[0] = [[
 :::::::
:+:   :+:
+:+  :+:+
+#+ + +:+
+#+#  +#+
#+#   #+#
 #######
]],
	[1] = [[
  :::
:+:+:
  +:+
  +#+
  +#+
  #+#
#######
]],
	[2] = [[
 ::::::::
:+:    :+:
      +:+
    +#+
  +#+
 #+#
##########
]],
	[3] = [[
 ::::::::
:+:    :+:
       +:+
    +#++:
       +#+
#+#    #+#
 ########
]],
	[4] = [[
    :::
   :+:
  +:+ +:+
 +#+  +:+
+#+#+#+#+#+
      #+#
      ###
]],
	[5] = [[
::::::::::
:+:    :+:
+:+
+#++:++#+
       +#+
#+#    #+#
 ########
]],
	[6] = [[
 ::::::::
:+:    :+:
+:+
+#++:++#+
+#+    +#+
#+#    #+#
 ########
]],
	[7] = [[
:::::::::::
:+:     :+:
       +:+
      +#+
     +#+
    #+#
    ###
]],
	[8] = [[
 ::::::::
:+:    :+:
+:+    +:+
 +#++:++#
+#+    +#+
#+#    #+#
 ########
]],
	[9] = [[
 ::::::::
:+:    :+:
+:+    +:+
 +#++:++#+
       +#+
#+#    #+#
 ########
]],
	--  editorconfig-checker-enable
}

function M.get_number(num_str)
	local big_chars = {}
	local char_lengths = {}

	-- split lines
	for i = 1, #num_str do
		local n = num_str:sub(i, i)
		table.insert(big_chars, vim.split(M[tonumber(n)], '\n'))
	end

	-- calculate length of big chars
	for _, num in ipairs(big_chars) do
		local max = 0
		for _, line in ipairs(num) do
			if max < #line then
				max = #line
			end
		end

		table.insert(char_lengths, max)
	end

	-- start building the lines that includes all numbers
	local line_i = 1
	local lines = {}

	while true do
		local line = ''
		for char_i, char in ipairs(big_chars) do
			if not char[line_i] then
				goto continue
			end

			local char_len = char_lengths[char_i]
			local char_line = char[line_i]

			local char_line_str = string.format(
				string.format('%%-0%ds', char_len),
				char_line
			)

			line = line .. ' ' .. char_line_str
		end

		table.insert(lines, line)

		line_i = line_i + 1
	end

	---@diagnostic disable-next-line: unreachable-code
	::continue::
	return lines
end

return M
